import 'package:flutter/material.dart';
import '../../backend/translator.dart';
import '../payment/payment_processing_screen.dart';

class OrangeMoneyScreen extends StatefulWidget {
  const OrangeMoneyScreen({super.key});

  static const String routeName = '/orange-money';

  @override
  State<OrangeMoneyScreen> createState() => _OrangeMoneyScreenState();
}

class _OrangeMoneyScreenState extends State<OrangeMoneyScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  static const Color _orange = Color(0xFFFF6600);
  static const Color _salmon = Color(0xFFFF8C8C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Orange Money', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: _orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.phone_android_outlined, size: 50, color: _orange),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                Translator.t('pay_with_orange_money'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                Translator.t('orange_money_desc'),
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: Translator.t('phone_number'),
                  hintText: Translator.t('phone_number_hint'),
                  prefixIcon: const Icon(Icons.phone),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: _salmon, width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return Translator.t('phone_required');
                  if (value.length < 9) return Translator.t('invalid_number');
                  return null;
                },
              ),
              const SizedBox(height: 30),
              _buildInstructions(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushNamed(context, PaymentProcessingScreen.routeName);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D0D26),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: Text(Translator.t('confirm_payment'), 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _orange.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _orange.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: _orange, size: 20),
              const SizedBox(width: 10),
              Text(Translator.t('instructions'), style: const TextStyle(fontWeight: FontWeight.bold, color: _orange)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            Translator.t('orange_money_instructions'),
            style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
