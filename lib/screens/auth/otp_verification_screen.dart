import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/mock_firebase.dart';
import '../../widgets/auth_background.dart';
import '../main_navigation_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  static const String routeName = '/otp-verification';

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());

  int _timerSeconds = 60;
  Timer? _timer;
  bool _isLoading = false;
  String? _errorMessage;

  // E-mail de l'utilisateur en cours d'inscription (ou phone masqué si vide)
  String get _targetInfo {
    final pendingEmail = MockFirebase().pendingUserEmail;
    if (pendingEmail != null && pendingEmail.isNotEmpty) {
      // Masquer partiellement l'email ex: fa***@kouture.com
      final parts = pendingEmail.split('@');
      if (parts.length == 2) {
        final name = parts[0];
        final domain = parts[1];
        final masked = name.length > 2
            ? '${name.substring(0, 2)}${'*' * (name.length - 2)}@$domain'
            : '$name@$domain';
        return masked;
      }
      return pendingEmail;
    }
    return '+237 6•• •• •• 89';
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
    for (var controller in _controllers) {
      controller.addListener(_updateButtonState);
    }
    for (var node in _focusNodes) {
      node.addListener(() => setState(() {}));
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
      setState(() => _errorMessage = 'Veuillez entrer le code à 6 chiffres.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // verifyOtp gère automatiquement la finalisation de l'inscription
      // si un _pendingUser est présent dans MockFirebase
      final success = await MockFirebase().verifyOtp(code);

      if (mounted) {
        setState(() => _isLoading = false);

        if (success) {
          // Si aucun utilisateur n'était en attente, c'est une vérification
          // depuis une connexion existante — on s'assure d'être connecté
          if (!MockFirebase().isAuthenticated) {
            await MockFirebase().signIn('falcon@kouture.com', 'kouture2024');
          }
          if (mounted) {
            Navigator.pushReplacementNamed(context, MainNavigationScreen.routeName);
          }
        } else {
          setState(() => _errorMessage = 'Code invalide. Veuillez réessayer.');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0D0D26), size: 20),
            onPressed: () {
              // Annuler l'inscription en cours si on revient en arrière
              MockFirebase().cancelPendingRegistration();
              Navigator.pop(context);
            },
          ),
        ),
        body: AuthBackground(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // 🏷️ Titre
                const Text(
                  'Vérification',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D0D26),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // 📧 Sous-titre dynamique
                Text.rich(
                  TextSpan(
                    text: 'Nous avons envoyé un code de vérification à ',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                    children: [
                      TextSpan(
                        text: _targetInfo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D0D26),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // 💡 Indication de simulation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3CD),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: Color(0xFF856404)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Simulation : entrez n\'importe quel code à 6 chiffres.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 🔢 6 Cases OTP
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => _buildOtpBox(index)),
                ),

                // ❌ Message d'erreur
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, size: 16, color: Colors.red),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 40),

                // 🚀 Bouton Vérifier
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_isFormComplete) ? null : _handleVerify,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormComplete
                          ? const Color(0xFFFF8C8C)
                          : const Color(0xFFD9D9D9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Vérifier',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 32),

                // ⏳ Timer & Renvoi
                Center(
                  child: _timerSeconds > 0
                      ? Text(
                          'Renvoyer le code dans 00:${_timerSeconds.toString().padLeft(2, '0')}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Vous n\'avez pas reçu de code ? ',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            ),
                            GestureDetector(
                              onTap: _startTimer,
                              child: const Text(
                                'Renvoyer',
                                style: TextStyle(
                                  color: Color(0xFFFF8C8C),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    final isFocused = _focusNodes[index].hasFocus;
    final hasValue = _controllers[index].text.isNotEmpty;

    return Container(
      width: 48,
      height: 58,
      decoration: BoxDecoration(
        color: isFocused
            ? const Color(0xFFFFF0F0)
            : hasValue
                ? const Color(0xFFFFF0F0)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused
              ? const Color(0xFFFF8C8C)
              : hasValue
                  ? const Color(0xFFFF8C8C).withValues(alpha: 0.5)
                  : Colors.grey[200]!,
          width: isFocused ? 2 : 1,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFFF8C8C).withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              ]
            : [],
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
            setState(() {});
          },
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D0D26),
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
