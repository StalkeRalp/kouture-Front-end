import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  static const String routeName = '/add-address';

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String _label = 'Maison';
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  bool _isDefault = false;

  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      final newAddress = {
        'label': _label,
        'fullName': _nameController.text,
        'phone': _phoneController.text,
        'street': _streetController.text,
        'city': _cityController.text,
        'region': _regionController.text,
        'isDefault': _isDefault,
      };

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator(color: _salmon)),
      );

      await MockFirebase().addAddress(newAddress);

      if (mounted) {
        Navigator.pop(context); // Pop loading
        Navigator.pop(context); // Go back to list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adresse ajoutée avec succès')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nouvelle Adresse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type d\'adresse',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildTypeChip('Maison', Icons.home_filled),
                  const SizedBox(width: 12),
                  _buildTypeChip('Travail', Icons.work),
                  const SizedBox(width: 12),
                  _buildTypeChip('Autre', Icons.location_on),
                ],
              ),
              const SizedBox(height: 32),
              _buildTextField(
                controller: _nameController,
                label: 'Nom Complet',
                hint: 'ex: Jean Dupont',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _phoneController,
                label: 'Téléphone',
                hint: 'ex: +237 600 000 000',
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _streetController,
                label: 'Adresse / Rue',
                hint: 'ex: Rue de la Paix, Bastos',
                icon: Icons.map_outlined,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cityController,
                      label: 'Ville',
                      hint: 'ex: Yaoundé',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildTextField(
                      controller: _regionController,
                      label: 'Région',
                      hint: 'ex: Centre',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Définir comme adresse par défaut',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                ),
                subtitle: const Text('Utilisée automatiquement lors du paiement'),
                value: _isDefault,
                onChanged: (val) => setState(() => _isDefault = val),
                activeColor: _salmon,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _salmon,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'ENREGISTRER L\'ADRESSE',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon) {
    final isSelected = _label == label;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _label = label);
      },
      selectedColor: _salmon,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? _salmon : Colors.transparent),
      ),
      elevation: 0,
      pressElevation: 0,
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
            prefixIcon: icon != null ? Icon(icon, color: _salmon, size: 20) : null,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _salmon, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ce champ est requis';
            }
            return null;
          },
        ),
      ],
    );
  }
}
