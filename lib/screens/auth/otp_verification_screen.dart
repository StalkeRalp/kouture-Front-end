import 'dart:async';
import 'package:flutter/material.dart';
import '../../backend/mock_firebase.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  static const String routeName = '/otp-verification';

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  
  int _timerSeconds = 60;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Listen to all OTP controllers to update button state
    for (var controller in _controllers) {
      controller.addListener(_updateButtonState);
    }
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool get _isFormComplete => _controllers.every((c) => c.text.isNotEmpty);

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timerSeconds = 60;
      _errorMessage = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  Future<void> _handleVerify() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await MockFirebase().verifyOtp(code);
    
    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        // Automatically sign in the mock user u1
        await MockFirebase().signIn('falcon@kouture.com', 'kouture2024');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/main-nav');
        }
      } else {
        setState(() => _errorMessage = 'Invalid code. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0D0D26), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Verification',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0D0D26)),
            ),
            const SizedBox(height: 12),
            const Text.rich(
              TextSpan(
                text: 'Nous avons envoyé un code de vérification au ',
                children: [
                   TextSpan(text: '+237 6•• •• •• 89', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D0D26))),
                ],
              ),
              style: TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
            ),
            
            const SizedBox(height: 48),
            
            // 🔢 6 OTP Boxes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) => _buildOtpBox(index)),
            ),
            
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 24),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
              ),
            
            const SizedBox(height: 48),
            
            // 🚀 Verify Button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleVerify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFormComplete ? const Color(0xFFFF8C8C) : const Color(0xFFD9D9D9),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('VÉRIFIER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 2)),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // ⏳ Timer & Resend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _timerSeconds > 0 
                      ? 'Renvoyer le code dans 00:${_timerSeconds.toString().padLeft(2, '0')}'
                      : 'Vous n\'avez pas reçu de code ? ',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (_timerSeconds == 0)
                  TextButton(
                    onPressed: _startTimer,
                    child: const Text(
                      'Renvoyer',
                      style: TextStyle(color: Color(0xFFFF8C8C), fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focusNodes[index].hasFocus ? const Color(0xFF0D0D26) : Colors.grey[200]!,
          width: _focusNodes[index].hasFocus ? 2 : 1,
        ),
      ),
      child: Center(
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          onChanged: (value) {
            if (value.length == 1 && index < 5) {
              _focusNodes[index + 1].requestFocus();
            } else if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            setState(() {}); // Update border color
          },
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0D0D26)),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
