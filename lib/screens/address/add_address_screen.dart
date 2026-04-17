import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  API utilisée : Nominatim (OpenStreetMap)
//  ✅ Gratuit, sans clé API, sans limite stricte (1 req/s recommandé)
//  ✅ Reverse geocoding : coordonnées → adresse
//  ✅ Forward geocoding  : texte → coordonnées
//  Doc : https://nominatim.org/release-docs/latest/api/Reverse/
// ─────────────────────────────────────────────────────────────────────────────

// ─── Modèle d'adresse ────────────────────────────────────────────────────────
class AddressModel {
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String neighborhood;
  final String city;
  final String region;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const AddressModel({
    required this.label,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.neighborhood,
    required this.city,
    required this.region,
    required this.isDefault,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() => {
        'label': label,
        'fullName': fullName,
        'phone': phone,
        'street': street,
        'neighborhood': neighborhood,
        'city': city,
        'region': region,
        'isDefault': isDefault,
        'latitude': latitude,
        'longitude': longitude,
      };
}

// ─── Service Nominatim amélioré ───────────────────────────────────────────────────────
class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const Map<String, String> _headers = {
    'User-Agent': 'KoutureClientApp/1.0 (contact@kouture.app)',
    'Accept-Language': 'fr,en',
  };

  /// Reverse geocoding avec plus de détails
  static Future<Map<String, String>?> reverseGeocode(LatLng coords) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/reverse'
        '?format=jsonv2'
        '&lat=${coords.latitude}'
        '&lon=${coords.longitude}'
        '&zoom=18'
        '&addressdetails=1'
        '&namedetails=1',
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data == null || data['address'] == null) return null;

      final addr = data['address'] as Map<String, dynamic>;

      return {
        'street': _extractStreet(addr),
        'streetNumber': addr['house_number']?.toString() ?? '',
        'neighborhood': _extractNeighborhood(addr),
        'city': _extractCity(addr),
        'region': _extractRegion(addr),
        'postcode': addr['postcode']?.toString() ?? '',
        'country': addr['country']?.toString() ?? '',
        'displayName': data['display_name'] ?? '',
        'fullAddress': _buildFullAddress(addr),
      };
    } on TimeoutException {
      debugPrint('Nominatim: timeout');
      return null;
    } catch (e) {
      debugPrint('Nominatim error: $e');
      return null;
    }
  }

  /// Forward geocoding : recherche d'adresse par texte
  static Future<List<Map<String, dynamic>>> searchAddress(String query) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=jsonv2'
        '&addressdetails=1'
        '&limit=5'
        '&countrycodes=cm', // Cameroon par défaut
      );

      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      debugPrint('Search error: $e');
      return [];
    }
  }

  static String _extractStreet(Map<String, dynamic> addr) {
    final street = _firstNonEmpty([
      addr['road'],
      addr['pedestrian'],
      addr['footway'],
      addr['path'],
      addr['street'],
    ]);
    
    final number = addr['house_number']?.toString() ?? '';
    return number.isNotEmpty ? '$number $street' : street;
  }

  static String _extractNeighborhood(Map<String, dynamic> addr) {
    return _firstNonEmpty([
      addr['neighbourhood'],
      addr['quarter'],
      addr['suburb'],
      addr['city_district'],
      addr['residential'],
    ]);
  }

  static String _extractCity(Map<String, dynamic> addr) {
    return _firstNonEmpty([
      addr['city'],
      addr['town'],
      addr['village'],
      addr['municipality'],
      addr['county'],
    ]);
  }

  static String _extractRegion(Map<String, dynamic> addr) {
    return _firstNonEmpty([
      addr['state'],
      addr['state_district'],
      addr['region'],
      addr['county'],
    ]);
  }

  static String _buildFullAddress(Map<String, dynamic> addr) {
    final parts = <String>[];
    
    final street = _extractStreet(addr);
    if (street.isNotEmpty) parts.add(street);
    
    final neighborhood = _extractNeighborhood(addr);
    if (neighborhood.isNotEmpty) parts.add(neighborhood);
    
    final city = _extractCity(addr);
    if (city.isNotEmpty) parts.add(city);
    
    final region = _extractRegion(addr);
    if (region.isNotEmpty) parts.add(region);
    
    final country = addr['country']?.toString() ?? '';
    if (country.isNotEmpty) parts.add(country);
    
    return parts.join(', ');
  }

  static String _firstNonEmpty(List<dynamic> values) =>
      values.firstWhere(
        (v) => v != null && (v as String).isNotEmpty,
        orElse: () => '',
      ) as String;
}

// ─── Écran principal amélioré ─────────────────────────────────────────────────────────
class AddAddressScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? prefillAddress;
  
  const AddAddressScreen({super.key, this.initialLocation, this.prefillAddress});

  static const String routeName = '/add-address';

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  // Formulaire
  final _formKey = GlobalKey<FormState>();
  String _label = 'Maison';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isDefault = false;

  // Carte
  final MapController _mapController = MapController();
  LatLng _pinLocation = const LatLng(4.0511, 9.7679); // Douala par défaut
  bool _isMapMoving = false;
  bool _isFetchingAddress = false;
  bool _locationPermissionDenied = false;
  Timer? _debounceTimer;
  
  // État de l'UI
  bool _showFullAddress = false;
  bool _isSatelliteView = false;
  double _mapZoom = 16.0;
  
  // Recherche d'adresse
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  Timer? _searchDebounce;
  OverlayEntry? _searchOverlay;
  final LayerLink _layerLink = LayerLink();
  
  // Animation du pin
  late AnimationController _pinAnimController;
  late Animation<double> _pinBounce;
  late Animation<double> _pinScale;

  // Couleurs
  static const Color _salmon = Color(0xFFFF6B6B);
  static const Color _salmonLight = Color(0xFFFFE5E5);
  static const Color _darkNavy = Color(0xFF1A1A2E);
  static const Color _grey100 = Color(0xFFF8F8F8);
  static const Color _grey200 = Color(0xFFF0F0F0);
  static const Color _grey400 = Color(0xFFBDBDBD);
  static const Color _textPrimary = Color(0xFF1A1A2E);
  static const Color _textSecondary = Color(0xFF6B7280);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Animations du pin
    _pinAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _pinBounce = Tween<double>(begin: 0.0, end: -16.0).animate(
      CurvedAnimation(
        parent: _pinAnimController,
        curve: const ElasticOutCurve(0.8),
      ),
    );
    
    _pinScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pinAnimController,
        curve: Curves.easeOut,
      ),
    );

    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    if (widget.initialLocation != null) {
      setState(() => _pinLocation = widget.initialLocation!);
      _mapController.move(widget.initialLocation!, 16.0);
      _fetchAndFillAddress(widget.initialLocation!);
    } else {
      await _requestLocationAndCenter();
    }
    
    if (widget.prefillAddress != null) {
      await _searchAndSelectAddress(widget.prefillAddress!);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _saveCurrentState();
    }
  }

  void _saveCurrentState() {
    // Sauvegarde l'état actuel si nécessaire
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pinAnimController.dispose();
    _debounceTimer?.cancel();
    _searchDebounce?.cancel();
    _mapController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _removeSearchOverlay();
    super.dispose();
  }

  void _removeSearchOverlay() {
    _searchOverlay?.remove();
    _searchOverlay = null;
  }

  // ─── Recherche d'adresse avancée ─────────────────────────────────────────────────────

  Future<void> _searchAndSelectAddress(String query) async {
    setState(() => _isSearching = true);
    
    final results = await NominatimService.searchAddress(query);
    
    if (results.isNotEmpty && mounted) {
      final first = results.first;
      final lat = double.parse(first['lat']?.toString() ?? '0');
      final lon = double.parse(first['lon']?.toString() ?? '0');
      final location = LatLng(lat, lon);
      
      setState(() {
        _pinLocation = location;
        _isSearching = false;
      });
      
      _mapController.move(location, 17.0);
      await _fetchAndFillAddress(location);
    } else {
      setState(() => _isSearching = false);
    }
  }

  void _showSearchOverlay() {
    _removeSearchOverlay();
    
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final size = renderBox.size;
    
    _searchOverlay = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: Offset(16, 65),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildSearchResults(),
            ),
          ),
        ),
      ),
    );
    
    overlay.insert(_searchOverlay!);
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(color: _salmon),
        ),
      );
    }
    
    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, color: _grey400, size: 40),
            const SizedBox(height: 8),
            Text(
              'Aucun résultat',
              style: TextStyle(color: _textSecondary),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        final displayName = result['display_name']?.toString() ?? '';
        
        return ListTile(
          leading: const Icon(Icons.location_on, color: _salmon, size: 20),
          title: Text(
            displayName.split(',').first,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            displayName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12, color: _textSecondary),
          ),
          onTap: () async {
            _searchController.text = displayName;
            _removeSearchOverlay();
            _searchFocusNode.unfocus();
            
            final lat = double.parse(result['lat']?.toString() ?? '0');
            final lon = double.parse(result['lon']?.toString() ?? '0');
            final location = LatLng(lat, lon);
            
            setState(() {
              _pinLocation = location;
              _searchResults = [];
            });
            
            _mapController.move(location, 17.0);
            await _fetchAndFillAddress(location);
          },
        );
      },
    );
  }

  // ─── Géolocalisation améliorée ─────────────────────────────────────────────────────

  Future<void> _requestLocationAndCenter() async {
    final hasPermission = await _checkAndRequestPermission();
    if (!hasPermission) {
      _fetchAndFillAddress(_pinLocation);
      return;
    }

    if (mounted) setState(() => _isFetchingAddress = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(const Duration(seconds: 10));

      final latLng = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() => _pinLocation = latLng);
        
        // Animation fluide vers la position
        _mapController.move(latLng, 16.0);
        
        // Récupère l'adresse
        await _fetchAndFillAddress(latLng);
        
        // Animation de confirmation
        _showSnack('📍 Position trouvée !', isSuccess: true);
      }
    } catch (e) {
      debugPrint('Location error: $e');
      if (mounted) {
        setState(() => _isFetchingAddress = false);
        _showSnack('Impossible de vous localiser', isError: true);
      }
    }
  }

  Future<bool> _checkAndRequestPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (mounted) {
        setState(() => _locationPermissionDenied = true);
        _showLocationDialog();
      }
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) setState(() => _locationPermissionDenied = true);
      return false;
    }
    return true;
  }

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.location_off, color: Colors.orange.shade700),
            const SizedBox(width: 8),
            const Text('Localisation désactivée'),
          ],
        ),
        content: const Text(
          'Activez la localisation pour trouver automatiquement votre adresse.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Plus tard',
              style: TextStyle(color: _textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _salmon,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Activer'),
          ),
        ],
      ),
    );
  }

  // ─── Reverse geocoding amélioré ────────────────────────────────────────────────────

  Future<void> _fetchAndFillAddress(LatLng coords) async {
    if (!mounted) return;
    setState(() => _isFetchingAddress = true);

    final result = await NominatimService.reverseGeocode(coords);

    if (!mounted) return;
    setState(() => _isFetchingAddress = false);

    if (result != null) {
      setState(() {
        // Remplissage intelligent des champs
        if (_streetController.text.isEmpty || !_isManuallyEdited) {
          _streetController.text = result['street'] ?? '';
        }
        if (_neighborhoodController.text.isEmpty || !_isManuallyEdited) {
          _neighborhoodController.text = result['neighborhood'] ?? '';
        }
        if (_cityController.text.isEmpty || !_isManuallyEdited) {
          _cityController.text = result['city'] ?? '';
        }
        if (_regionController.text.isEmpty || !_isManuallyEdited) {
          _regionController.text = result['region'] ?? '';
        }
        if (_postalCodeController.text.isEmpty || !_isManuallyEdited) {
          _postalCodeController.text = result['postcode'] ?? '';
        }
        if (_countryController.text.isEmpty || !_isManuallyEdited) {
          _countryController.text = result['country'] ?? '';
        }
        
        _fullAddressPreview = result['fullAddress'] ?? result['displayName'] ?? '';
        _isManuallyEdited = false;
      });
      
      _showSnack('✓ Adresse trouvée', isSuccess: true);
    } else {
      _showSnack('Adresse introuvable', isError: true);
    }
  }

  bool _isManuallyEdited = false;
  String _fullAddressPreview = '';

  void _onFieldEdited() {
    setState(() => _isManuallyEdited = true);
  }

  // ─── Événements carte améliorés ─────────────────────────────────────────────────────

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveStart) {
      setState(() => _isMapMoving = true);
      _pinAnimController.forward();
      _debounceTimer?.cancel();
      _removeSearchOverlay();
    } else if (event is MapEventMove) {
      final newCenter = _mapController.camera.center;
      setState(() => _pinLocation = newCenter);
    } else if (event is MapEventMoveEnd) {
      final newCenter = _mapController.camera.center;
      setState(() {
        _pinLocation = newCenter;
        _isMapMoving = false;
      });
      _pinAnimController.reverse();

      // Debounce pour ne pas surcharger l'API
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 800), () {
        _fetchAndFillAddress(_pinLocation);
      });
    }
  }

  void _zoomIn() {
    final newZoom = (_mapController.camera.zoom + 1).clamp(5.0, 19.0);
    _mapController.move(_pinLocation, newZoom);
    setState(() => _mapZoom = newZoom);
  }

  void _zoomOut() {
    final newZoom = (_mapController.camera.zoom - 1).clamp(5.0, 19.0);
    _mapController.move(_pinLocation, newZoom);
    setState(() => _mapZoom = newZoom);
  }

  // ─── Sauvegarde améliorée ──────────────────────────────────────────────────────────

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('Veuillez remplir tous les champs requis', isError: true);
      return;
    }

    // Validation supplémentaire
    if (_pinLocation.latitude == 0 && _pinLocation.longitude == 0) {
      _showSnack('Veuillez sélectionner un emplacement sur la carte', isError: true);
      return;
    }

    // Feedback haptique
    HapticFeedback.mediumImpact();

    final address = AddressModel(
      label: _label,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      street: _streetController.text.trim(),
      neighborhood: _neighborhoodController.text.trim(),
      city: _cityController.text.trim(),
      region: _regionController.text.trim(),
      isDefault: _isDefault,
      latitude: _pinLocation.latitude,
      longitude: _pinLocation.longitude,
    );

    // Affiche un loader stylisé
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: _salmon),
              const SizedBox(height: 16),
              Text(
                'Enregistrement...',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _fullAddressPreview,
                style: TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await MockFirebase().addAddress(address.toMap());

      if (mounted) {
        Navigator.pop(context); // ferme loader
        Navigator.pop(context); // retour
        
        // Affiche un succès animé
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check, color: Color(0xFF22C55E), size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    Translator.t('address_added_success'),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1A1A2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showSnack('Erreur lors de l\'enregistrement', isError: true);
    }
  }

  // ─── Helpers UI améliorés ──────────────────────────────────────────────────────────

  void _showSnack(String msg, {bool isError = false, bool isSuccess = false}) {
    if (!mounted) return;
    
    Color bgColor = _darkNavy;
    IconData icon = Icons.info_outline;
    
    if (isError) {
      bgColor = Colors.redAccent;
      icon = Icons.error_outline;
    } else if (isSuccess) {
      bgColor = const Color(0xFF22C55E);
      icon = Icons.check_circle_outline;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: bgColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  // ─── BUILD PRINCIPAL ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            Stack(
              children: [
                _buildMap(),
                // ── Pin central animé ──
                Center(
                  child: AnimatedBuilder(
                    animation: _pinAnimController,
                    builder: (_, __) => Transform.translate(
                      offset: Offset(0, _pinBounce.value - 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.scale(
                            scale: _pinScale.value,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _salmon.withOpacity(0.4),
                                    blurRadius: _isMapMoving ? 16 : 8,
                                    spreadRadius: _isMapMoving ? 2 : 0,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.location_pin, size: 40, color: _salmon),
                            ),
                          ),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: _isMapMoving ? 14 : 10,
                            height: _isMapMoving ? 5 : 4,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_showFullAddress) _buildAddressPreview(),
              ],
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
              left: 0,
              right: 0,
              child: _buildSearchBar(),
            ),
            _buildFormSheet(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        Translator.t('new_address'),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: _textPrimary,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _grey100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: _textPrimary, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _showFullAddress ? _salmonLight : _grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.info_outline_rounded,
              color: _showFullAddress ? _salmon : _textSecondary,
              size: 18,
            ),
          ),
          onPressed: () => setState(() => _showFullAddress = !_showFullAddress),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isSatelliteView ? _salmonLight : _grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.satellite_alt_rounded,
              color: _isSatelliteView ? _salmon : _textSecondary,
              size: 18,
            ),
          ),
          onPressed: () => setState(() => _isSatelliteView = !_isSatelliteView),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          onTap: () {
            if (_searchResults.isNotEmpty) {
              _showSearchOverlay();
            }
          },
          decoration: InputDecoration(
            hintText: 'Rechercher une adresse...',
            hintStyle: TextStyle(color: _grey400, fontSize: 14),
            prefixIcon: const Icon(Icons.search, color: _salmon, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      _removeSearchOverlay();
                      setState(() => _searchResults = []);
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String query) async {
    _searchDebounce?.cancel();
    
    if (query.length < 3) {
      setState(() => _searchResults = []);
      _removeSearchOverlay();
      return;
    }
    
    _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() => _isSearching = true);
      _showSearchOverlay();
      
      final results = await NominatimService.searchAddress(query);
      
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

  // ─── Carte améliorée ───────────────────────────────────────────────────────────────

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _pinLocation,
        initialZoom: 16.0,
        minZoom: 5.0,
        maxZoom: 19.0,
        onMapEvent: _onMapEvent,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: _isSatelliteView
              ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
              : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.kouture',
          maxZoom: 19,
          tileProvider: NetworkTileProvider(),
          retinaMode: MediaQuery.of(context).devicePixelRatio > 2.0,
        ),
        
        if (!_isMapMoving)
          CircleLayer(
            circles: [
              CircleMarker(
                point: _pinLocation,
                radius: 80,
                color: _salmon.withOpacity(0.08),
                borderColor: _salmon.withOpacity(0.3),
                borderStrokeWidth: 2,
                useRadiusInMeter: true,
              ),
            ],
          ),
          
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddressPreview() {
    if (_isFetchingAddress) {
      return Positioned(
        bottom: MediaQuery.of(context).size.height * 0.45 + 10,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: _salmon, strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Recherche de l\'adresse...',
                  style: TextStyle(color: _textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_fullAddressPreview.isEmpty) return const SizedBox();
    
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.45 + 10,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: 4,
        child: InkWell(
          onTap: () => setState(() => _showFullAddress = false),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _salmonLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.location_on, color: _salmon, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Adresse sélectionnée',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _showFullAddress = false),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _fullAddressPreview,
                  style: TextStyle(
                    color: _textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Petite barre de drag
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(child: _buildForm(scrollController)),
            ],
          ),
        );
      },
    );
  }

  // ─── Formulaire ──────────────────────────────────────────────────────────

  Widget _buildForm(ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type d'adresse
            Text(
              Translator.t('address_type'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTypeSelector(),
            const SizedBox(height: 28),

            // Nom complet
            _buildTextField(
              controller: _nameController,
              label: Translator.t('full_name'),
              hint: Translator.t('full_name_hint'),
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 16),

            // Téléphone
            _buildTextField(
              controller: _phoneController,
              label: Translator.t('phone'),
              hint: Translator.t('phone_hint'),
              icon: Icons.phone_android_rounded,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]'))],
            ),
            const SizedBox(height: 16),

            // Rue (auto-rempli)
            _buildTextField(
              controller: _streetController,
              label: Translator.t('street_address'),
              hint: Translator.t('street_hint'),
              icon: Icons.signpost_outlined,
            ),
            const SizedBox(height: 16),

            // Quartier
            _buildTextField(
              controller: _neighborhoodController,
              label: Translator.t('neighborhood') ?? 'Quartier',
              hint: Translator.t('neighborhood_hint') ?? 'Votre quartier',
              icon: Icons.holiday_village_outlined,
            ),
            const SizedBox(height: 16),

            // Ville + Région sur la même ligne
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: Translator.t('city'),
                    hint: Translator.t('city_hint'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _regionController,
                    label: Translator.t('region'),
                    hint: Translator.t('region_hint'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Code Postal + Pays
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _postalCodeController,
                    label: 'Code Postal',
                    hint: 'Ex: 12345',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _countryController,
                    label: 'Pays',
                    hint: 'Cameroun',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Adresse par défaut
            _buildDefaultSwitch(),
            const SizedBox(height: 32),

            // Bouton sauvegarder
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      ('Maison', Translator.t('home'), Icons.home_rounded),
      ('Travail', Translator.t('work'), Icons.work_rounded),
      ('Autre', Translator.t('other'), Icons.location_on_rounded),
    ];

    return Row(
      children: types
          .map((t) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: t.$1 != 'Autre' ? 10 : 0),
                  child: _buildTypeChip(t.$1, t.$2, t.$3),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildTypeChip(String internalLabel, String displayLabel, IconData icon) {
    final isSelected = _label == internalLabel;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _label = internalLabel);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _salmon : _grey100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _salmon : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _salmon.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : _grey400),
            const SizedBox(height: 4),
            Text(
              displayLabel,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : _textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: _textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: (val) => _onFieldEdited(),
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: _textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            prefixIcon: icon != null
                ? Icon(icon, color: _salmon, size: 20)
                : null,
            filled: true,
            fillColor: _grey100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _salmon, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            errorStyle: const TextStyle(fontSize: 11),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return Translator.t('field_required');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDefaultSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _grey100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          Translator.t('set_as_default'),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: _textPrimary,
          ),
        ),
        subtitle: Text(
          Translator.t('set_as_default_desc'),
          style: const TextStyle(fontSize: 12, color: _textSecondary),
        ),
        value: _isDefault,
        onChanged: (val) {
          HapticFeedback.selectionClick();
          setState(() => _isDefault = val);
        },
        activeColor: _salmon,
        dense: true,
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: _saveAddress,
      style: ElevatedButton.styleFrom(
        backgroundColor: _salmon,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        shadowColor: _salmon.withOpacity(0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline_rounded, size: 20),
          const SizedBox(width: 8),
          Text(
            Translator.t('save_address'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}