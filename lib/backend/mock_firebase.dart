import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class MockFirebase extends ChangeNotifier {
  static final MockFirebase _instance = MockFirebase._internal();
  factory MockFirebase() => _instance;
  MockFirebase._internal();

  List<dynamic> _products = [];
  List<dynamic> _categoriesData = [];
  List<dynamic> _vendors = [];
  List<dynamic> _reviews = [];
  List<dynamic> _users = [];
  List<dynamic> _promotions = [];
  List<dynamic> _notifications = [];
  List<Map<String, dynamic>> _cartItems = [];
  bool _isInitialized = false;

  List<String> favoriteIds = [];
  List<String> recentSearches = [];
  Map<String, dynamic>? _authenticatedUser;

  List<dynamic> get allProducts => _products;
  List<dynamic> get promotions => _promotions;

  /// Call this inside main() or at the start of your app
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Load products, reviews, categories, vendors
      final dbStr = await rootBundle.loadString('lib/backend/products.json');
      final dbData = jsonDecode(dbStr);

      if (dbData is Map) {
        _products = List<dynamic>.from(dbData['products'] ?? []);
        _categoriesData = List<dynamic>.from(dbData['categories'] ?? []);
        _vendors = List<dynamic>.from(dbData['vendors'] ?? []);
        _reviews = List<dynamic>.from(dbData['reviews'] ?? []);
        _notifications = List<dynamic>.from(dbData['notifications'] ?? []);
        _users = List<dynamic>.from(dbData['users'] ?? []);
        _promotions = List<dynamic>.from(dbData['promotions'] ?? []);
      }
      
      // Load users & promotions from users.json
      try {
        final usersStr = await rootBundle.loadString('lib/backend/users.json');
        final uData = jsonDecode(usersStr);
        if (uData is Map) {
          _users = List<dynamic>.from(uData['users'] ?? []);
          _promotions = List<dynamic>.from(uData['promotions'] ?? []);
        }
      } catch (e) {
        // ignore if missing or malformed
      }

      try {
        final u1 = _users.firstWhere((u) => u['id'] == 'u1');
        favoriteIds = List<String>.from(u1['favorites'] ?? []);
        
        // Initialize addresses if not present
        if (u1['addresses'] == null) {
          u1['addresses'] = [
            {
              "id": "addr_1",
              "label": "Maison",
              "fullName": "Falcon Thought",
              "street": "Quartier Bastos, Rue 1234",
              "city": "Yaoundé",
              "region": "Centre",
              "phone": "+237 699 123 456",
              "isDefault": true
            }
          ];
        }
      } catch (e) {
        favoriteIds = [];
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint('MockFirebase Initialization Error: $e');
    }
  }

  // Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 600));
  }

  // --- PRODUCTS ---
  
  Future<List<dynamic>> getProducts() async {
    await _delay();
    return List.from(_products);
  }

  Future<void> addProduct(Map<String, dynamic> product) async {
    await _delay();
    // Simulate ID generation
    product['id'] = 'p_${DateTime.now().millisecondsSinceEpoch}';
    _products.add(product);
  }

  Future<Map<String, dynamic>?> getProductById(String id) async {
    await _delay();
    try {
      final p = _products.firstWhere((p) => p['id'].toString() == id);
      return Map<String, dynamic>.from(p);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getVendorById(String id) async {
    await _delay();
    try {
      final v = _vendors.firstWhere((v) => v['id'].toString() == id);
      return Map<String, dynamic>.from(v);
    } catch (e) {
      return null;
    }
  }

  Future<List<dynamic>> getVendors() async {
    await _delay();
    return List.from(_vendors);
  }

  Future<List<dynamic>> getSuggestedTailors() async {
    await _delay();
    if (_vendors.isEmpty) return [];

    // 1. Get all vendors with their publication count
    List<Map<String, dynamic>> vendorsWithCount = _vendors.map((v) {
      final count = _products.where((p) => p['vendorId'] == v['id']).length;
      return {...(v as Map<String, dynamic>), 'publicationCount': count};
    }).toList();

    // 2. Sort by publication count desc
    vendorsWithCount.sort((a, b) => (b['publicationCount'] as int).compareTo(a['publicationCount'] as int));

    // 3. Take top 3
    final List<dynamic> result = [];
    final int topCount = vendorsWithCount.length < 3 ? vendorsWithCount.length : 3;
    for (int i = 0; i < topCount; i++) {
      result.add(vendorsWithCount[i]);
    }

    // 4. From the rest (or all if we want duplicates? No, usually distinct), pick 2 random
    final List<dynamic> remaining = vendorsWithCount.where((v) => !result.contains(v['id'])).toList(); // Bug fix: check against ID
    
    if (remaining.isNotEmpty) {
      final random = math.Random();
      final int randCount = remaining.length < 2 ? remaining.length : 2;
      
      // Shuffle remaining and take 2
      remaining.shuffle(random);
      for (int i = 0; i < randCount; i++) {
        result.add(remaining[i]);
      }
    }

    return result;
  }

  Future<List<dynamic>> getFavoriteVendors() async {
    await _delay();
    return _vendors.where((v) => favoriteIds.contains(v['id'].toString())).toList();
  }

  Future<List<dynamic>> getReviewsByProductId(String productId) async {
    await _delay();
    return _reviews.where((r) => r['productId'].toString() == productId).toList();
  }

  Future<void> addReview(Map<String, dynamic> review) async {
    await _delay();
    review['id'] = 'r${DateTime.now().millisecondsSinceEpoch}';
    review['date'] = DateTime.now().toString().split(' ')[0];
    review['likes'] = 0;
    _reviews.insert(0, review);
    notifyListeners();
  }

  // --- NOTIFICATIONS ---

  int get unreadNotificationsCount => _notifications.where((n) => n['userId'] == 'u1' && !(n['isRead'] ?? false)).length;

  Future<List<dynamic>> getNotifications() async {
    await _delay();
    return _notifications.where((n) => n['userId'] == 'u1').toList();
  }

  Future<void> markNotificationAsRead(String id) async {
    await _delay();
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i]['id'] == id) {
        _notifications[i]['isRead'] = true;
        notifyListeners();
        break;
      }
    }
  }

  Future<void> markAllAsRead() async {
    await _delay();
    for (var n in _notifications) {
      if (n['userId'] == 'u1') n['isRead'] = true;
    }
    notifyListeners();
  }

  Future<void> clearAllNotifications() async {
    await _delay();
    _notifications.removeWhere((n) => n['userId'] == 'u1');
    notifyListeners();
  }

  Future<bool> sendTestNotification({
    required String type,
    required String title,
    required String message,
  }) async {
    await _delay();
    final user = currentUser;
    if (user == null) return false;

    final prefs = user['preferences'] ?? {};
    
    // Check if push is enabled generally
    if (!(prefs['push_notifications'] ?? true)) {
      debugPrint('Notification skipped: Push disabled');
      return false;
    }

    // Check specific categories if needed
    if (type == 'promo' && !(prefs['promotions'] ?? true)) {
      debugPrint('Notification skipped: Promotions disabled');
      return false;
    }

    final newNotif = {
      'id': 'n${DateTime.now().millisecondsSinceEpoch}',
      'userId': 'u1',
      'type': type,
      'title': title,
      'message': message,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    _notifications.insert(0, newNotif);
    notifyListeners();
    return true;
  }

  // --- AUTH / USER ---
  Map<String, dynamic>? get currentUser => _authenticatedUser ?? _users.cast<Map<String, dynamic>?>().firstWhere(
    (u) => u?['id'] == 'u1', 
    orElse: () => null
  );

  bool get isAuthenticated => _authenticatedUser != null;

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    await _delay();
    
    // Simulation: Error for specific email to test "Login - Error.jpg"
    if (email == 'error@kouture.com') {
      throw Exception('Identifiants invalides. Veuillez réessayer.');
    }

    try {
      final user = _users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
      );
      _authenticatedUser = Map<String, dynamic>.from(user);
      notifyListeners();
      return _authenticatedUser!;
    } catch (e) {
      throw Exception('Email ou mot de passe incorrect.');
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _delay();

    // Simulation: Email already exists
    if (_users.any((u) => u['email'] == email)) {
      throw Exception('Cet email est déjà utilisé par un autre compte.');
    }

    final newUser = {
      'id': 'u${DateTime.now().millisecondsSinceEpoch}',
      'name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
      'avatar': 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(fullName)}&background=FF8C8C&color=fff',
      'favorites': [],
      'addresses': [],
      'preferences': {},
    };

    // Note: In a real app, we'd add it to the list, but here we'll just return it
    // and wait for OTP verification to "officially" add/log in.
    return newUser;
  }

  Future<bool> verifyOtp(String code) async {
    await _delay();
    // Simulate valid OTP (any 6 digit code for mock)
    if (code.length == 6) {
      // In a real mock flow, we'd log the user in here
      return true;
    }
    return false;
  }

  void logout() {
    _authenticatedUser = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getUser(String id) async {
    await _delay();
    try {
      return _users.firstWhere((u) => u['id'] == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _delay();
    for (int i = 0; i < _users.length; i++) {
      if (_users[i]['id'] == id) {
        final updatedUser = Map<String, dynamic>.from(_users[i]);
        data.forEach((key, value) {
          updatedUser[key] = value;
        });
        _users[i] = updatedUser;
        
        // Save to disk for local persistence
        _saveToDisk();
        
        notifyListeners(); // Notify UI to rebuild
        break;
      }
    }
  }

  void _saveToDisk() {
    try {
      // Use relative path which is safer for local dev
      final file = File('lib/backend/users.json');
      final data = {
        'users': _users,
        'promotions': _promotions,
      };
      file.writeAsStringSync(jsonEncode(data));
    } catch (e) {
      // Silently fail persistence for local sessions
    }
  }

  // --- FAVORITES ---
  
  bool isFavorite(String id) => favoriteIds.contains(id);

  void toggleFavorite(String id) {
    if (favoriteIds.contains(id)) {
      favoriteIds.remove(id);
    } else {
      favoriteIds.add(id);
    }
    notifyListeners();
    // Simulate updating the user in db
    updateUser('u1', {'favorites': favoriteIds});
  }

  // --- SEARCH ---

  void addSearchQuery(String query) {
    if (query.trim().isEmpty) return;
    recentSearches.remove(query); // Remove if exists to put at the top
    recentSearches.insert(0, query);
    if (recentSearches.length > 10) {
      recentSearches.removeLast();
    }
    notifyListeners();
  }

  void clearRecentSearches() {
    recentSearches.clear();
    notifyListeners();
  }

  void removeRecentSearch(String query) {
    recentSearches.remove(query);
    notifyListeners();
  }

  Future<List<dynamic>> searchProducts(String query) async {
    await _delay();
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _products.where((p) {
      final name = p['name'].toString().toLowerCase();
      final tags = (p['tags'] as List?)?.map((t) => t.toString().toLowerCase()).toList() ?? [];
      return name.contains(q) || tags.any((t) => t.contains(q));
    }).toList();
  }

  Future<List<dynamic>> getRecommendedProducts() async {
    await _delay();
    final user = currentUser;
    if (user == null || user['preferences'] == null) {
      return _products.where((p) => p['isFeatured'] == true).toList();
    }

    final prefs = user['preferences'] as Map<String, dynamic>;
    final stylePref = (prefs['styles'] as List?)?.map((s) => s.toString().toLowerCase()).toList() ?? [];
    final materialPref = (prefs['materials'] as List?)?.map((m) => m.toString().toLowerCase()).toList() ?? [];
    final occasionPref = (prefs['occasions'] as List?)?.map((o) => o.toString().toLowerCase()).toList() ?? [];

    // Scoring system per product
    List<Map<String, dynamic>> scoredProducts = _products.map((p) {
      int score = 0;
      final tags = (p['tags'] as List?)?.map((t) => t.toString().toLowerCase()).toList() ?? [];
      final category = p['category'].toString().toLowerCase();

      // Style scoring
      for (var s in stylePref) {
        if (tags.contains(s) || category.contains(s)) score += 3;
      }
      
      // Material scoring
      for (var m in materialPref) {
        if (tags.contains(m) || p['description'].toString().toLowerCase().contains(m)) score += 2;
      }

      // Occasion scoring
      for (var o in occasionPref) {
        if (tags.contains(o)) score += 5; // Heavy weight on occasion
      }

      return {...(p as Map<String, dynamic>), '_score': score};
    }).toList();

    // Sort by score and return top results
    scoredProducts.sort((a, b) => (b['_score'] as int).compareTo(a['_score'] as int));
    
    // Filter out items with very low score if there are enough high score items
    final results = scoredProducts.where((p) => p['_score'] > 0).toList();
    if (results.isEmpty) return _products.where((p) => p['isFeatured'] == true).toList();
    
    return results;
  }

  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    await _delay();
    final user = currentUser;
    if (user != null) {
      final currentPrefs = Map<String, dynamic>.from(user['preferences'] ?? {});
      preferences.forEach((key, value) {
        currentPrefs[key] = value;
      });
      await updateUser('u1', {'preferences': currentPrefs});
    }
  }

  // --- CART ---

  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(Map<String, dynamic> product, {String? size, String? color, int quantity = 1}) {
    // Check if item already in cart with same size/color
    final existingIndex = _cartItems.indexWhere((item) => 
      item['productId'] == product['id'] && 
      item['size'] == size && 
      item['color'] == color
    );

    if (existingIndex != -1) {
      _cartItems[existingIndex]['quantity'] += quantity;
    } else {
      _cartItems.add({
        'id': 'cart_${DateTime.now().millisecondsSinceEpoch}',
        'productId': product['id'],
        'product': product, // Store minimal product info
        'quantity': quantity,
        'size': size ?? (product['sizes'] != null && (product['sizes'] as List).isNotEmpty ? product['sizes'][0] : 'unique'),
        'color': color ?? (product['colors'] != null && (product['colors'] as List).isNotEmpty ? product['colors'][0] : null),
      });
    }
    notifyListeners();
  }

  void removeFromCart(String cartItemId) {
    _cartItems.removeWhere((item) => item['id'] == cartItemId);
    notifyListeners();
  }

  void updateCartQuantity(String cartItemId, int delta) {
    final index = _cartItems.indexWhere((item) => item['id'] == cartItemId);
    if (index != -1) {
      final newQty = _cartItems[index]['quantity'] + delta;
      if (newQty > 0) {
        _cartItems[index]['quantity'] = newQty;
        notifyListeners();
      } else {
        removeFromCart(cartItemId);
      }
    }
  }

  double get cartSubtotal {
    double total = 0;
    for (var item in _cartItems) {
      final price = (item['product']['price'] as num).toDouble();
      total += price * item['quantity'];
    }
    return total;
  }

  double get cartShipping => _cartItems.isEmpty ? 0 : 2500.0; // Fixed shipping for mock
  double get cartTotal => cartSubtotal + cartShipping;

  // --- FILTER METADATA ---

  Future<List<String>> getCategoriesList() async {
    // If we have categoriesData from JSON, use it, otherwise extract from products
    if (_categoriesData.isNotEmpty) {
      return _categoriesData.map((c) => c['name'].toString()).toList();
    }
    return _products.map((p) => p['category'].toString()).toSet().toList();
  }

  Future<List<String>> getUniqueSizes() async {
    final sizes = <String>{};
    for (var p in _products) {
      final pSizes = p['sizes'] as List?;
      if (pSizes != null) {
        for (var s in pSizes) {
          sizes.add(s.toString());
        }
      }
    }
    // Simple sort for sizes if they look like standard ones
    final list = sizes.toList()..sort();
    return list;
  }

  Future<List<String>> getUniqueColors() async {
    final colors = <String>{};
    for (var p in _products) {
      final pColors = p['colors'] as List?;
      if (pColors != null) {
        for (var c in pColors) {
          colors.add(c.toString());
        }
      }
    }
    return colors.toList();
  }

  // --- ORDERS ---
  List<Map<String, dynamic>> _orders = [];
  List<Map<String, dynamic>> get allOrders => _orders;

  Future<void> createOrder(List<Map<String, dynamic>> items, double total) async {
    await _delay();
    final newOrder = {
      'id': 'KT-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      'userId': 'u1',
      'items': List.from(items),
      'total': total,
      'status': 'En attente', // Initial status
      'date': DateTime.now().toIso8601String(),
      'shippingAddress': 'Bastos, Rue 1234, Yaoundé, CMR',
      'paymentMethod': 'Orange Money', // Mock default
    };
    _orders.insert(0, newOrder);
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getOrderById(String id) async {
    await _delay();
    try {
      return _orders.firstWhere((o) => o['id'] == id);
    } catch (e) {
      return null;
    }
  }

  void updateOrderStatus(String orderId, String newStatus) {
    for (int i = 0; i < _orders.length; i++) {
      if (_orders[i]['id'] == orderId) {
        _orders[i]['status'] = newStatus;
        notifyListeners();
        break;
      }
    }
  }

  // --- CHAT ---
  final Map<String, List<Map<String, dynamic>>> _chatMessages = {
    'chat1': [
      {'senderId': 'v1', 'text': 'Bonjour! Comment puis-je vous aider aujourd\'hui?', 'time': '10:00'},
      {'senderId': 'u1', 'text': 'Bonjour, je voudrais savoir si cet ensemble est disponible en XXL.', 'time': '10:05'},
    ],
  };

  List<Map<String, dynamic>> getChatMessages(String chatId) {
    return _chatMessages[chatId] ?? [];
  }

  Future<void> sendMessage(String chatId, String text) async {
    await _delay();
    if (!_chatMessages.containsKey(chatId)) {
      _chatMessages[chatId] = [];
    }
    _chatMessages[chatId]!.add({
      'senderId': 'u1',
      'text': text,
      'time': '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
    });
    notifyListeners();
  }

  Future<List<dynamic>> getChatList() async {
    await _delay();
    return [
      {
        'id': 'chat1',
        'name': 'Maison de Couture X',
        'avatar': 'https://images.unsplash.com/photo-1558171813-36e0ab20d8dc?w=200',
        'lastMessage': 'Votre commande est prête!',
        'time': '10:30',
        'unread': 2,
      },
      {
        'id': 'chat2',
        'name': 'Tailleur Elite',
        'avatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
        'lastMessage': 'Pouvez-vous confirmer vos mesures?',
        'time': 'Hier',
        'unread': 0,
      },
    ];
  }

  Future<List<dynamic>> getProductsByVendor(String vendorId) async {
    await _delay();
    return _products.where((p) => p['vendorId'] == vendorId).toList();
  }

  // --- ADDRESSES ---

  Future<List<Map<String, dynamic>>> getAddresses() async {
    await _delay();
    final user = currentUser;
    if (user == null) return [];
    return List<Map<String, dynamic>>.from(user['addresses'] ?? []);
  }

  Future<void> addAddress(Map<String, dynamic> address) async {
    await _delay();
    final user = currentUser;
    if (user == null) return;

    final addresses = List<Map<String, dynamic>>.from(user['addresses'] ?? []);
    
    // Assign unique ID
    address['id'] = 'addr_${DateTime.now().millisecondsSinceEpoch}';

    // If it's the first address or set as default, handle default logic
    if (addresses.isEmpty) {
      address['isDefault'] = true;
    } else if (address['isDefault'] == true) {
      for (var a in addresses) {
        a['isDefault'] = false;
      }
    } else {
      address['isDefault'] = false;
    }

    addresses.add(address);
    user['addresses'] = addresses;
    
    notifyListeners();
    _saveToDisk();
  }

  Future<void> deleteAddress(String id) async {
    await _delay();
    final user = currentUser;
    if (user == null) return;

    final addresses = List<Map<String, dynamic>>.from(user['addresses'] ?? []);
    final wasDefault = addresses.any((a) => a['id'] == id && (a['isDefault'] ?? false));
    
    addresses.removeWhere((a) => a['id'] == id);

    // If we deleted the default address and there are others left, make the first one default
    if (wasDefault && addresses.isNotEmpty) {
      addresses[0]['isDefault'] = true;
    }

    user['addresses'] = addresses;
    notifyListeners();
    _saveToDisk();
  }

  Future<void> setDefaultAddress(String id) async {
    await _delay();
    final user = currentUser;
    if (user == null) return;

    final addresses = List<Map<String, dynamic>>.from(user['addresses'] ?? []);
    for (var a in addresses) {
      a['isDefault'] = (a['id'] == id);
    }

    user['addresses'] = addresses;
    notifyListeners();
    _saveToDisk();
  }
}
