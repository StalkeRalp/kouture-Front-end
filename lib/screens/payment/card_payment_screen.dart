import 'package:flutter/material.dart';
import '../../backend/translator.dart';
import '../payment/payment_processing_screen.dart';
import 'package:hugeicons/hugeicons.dart';

class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({super.key});

  static const String routeName = '/card-payment';

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  static const Color _salmon = Color(0xFFFF8C8C);
  static const Color _darkNavy = Color(0xFF0D0D26);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(Translator.t('bank_card_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Colors.black, size: 24.0),
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
              _buildCreditCardPreview(),
              const SizedBox(height: 40),
              
              _buildTextField(Translator.t('card_name'), _nameController, HugeIcons.strokeRoundedUser),
              const SizedBox(height: 20),
              
              _buildTextField(Translator.t('card_number'), _cardNumberController, HugeIcons.strokeRoundedCreditCard, keyboardType: TextInputType.number),
              const SizedBox(height: 20),
              
              Row(
                children: [
                   Expanded(child: _buildTextField(Translator.t('expiry'), _expiryController, HugeIcons.strokeRoundedCalendar01, hint: 'MM/YY')),
                   const SizedBox(width: 20),
                   Expanded(child: _buildTextField(Translator.t('cvv'), _cvvController, HugeIcons.strokeRoundedLock, obscure: true)),
                ],
              ),
              
              const SizedBox(height: 100),
              
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
                    backgroundColor: _darkNavy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: Text(Translator.t('pay_now'), 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCardPreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_darkNavy, _darkNavy.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: _darkNavy.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              HugeIcon(icon: HugeIcons.strokeRoundedNfc, color: Colors.white, size: 30),
              Text('VISA', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic)),
            ],
          ),
          const Spacer(),
          const Text('•••• •••• •••• ••••', style: TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(Translator.t('cardholder'), style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  const SizedBox(height: 4),
                  const Text('FALCON THOUGHT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(Translator.t('expiry'), style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  const SizedBox(height: 4),
                  const Text('12/28', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, dynamic icon, {TextInputType? keyboardType, bool obscure = false, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: HugeIcon(icon: icon, size: 20, color: Colors.black),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: _salmon, width: 1.5)),
          ),
          validator: (value) => (value == null || value.isEmpty) ? Translator.t('required_field') : null,
        ),
      ],
    );
  }
}
