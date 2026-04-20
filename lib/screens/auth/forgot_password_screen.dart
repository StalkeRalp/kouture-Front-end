import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/mock_firebase.dart';
import '../../widgets/auth_background.dart';
import 'package:hugeicons/hugeicons.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String routeName = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSent = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool get _isFormComplete => _emailController.text.isNotEmpty;

  Future<void> _handleSend() async {
    if (_emailController.text.isEmpty) return;

    // Validation email basique
    final email = _emailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Veuillez entrer une adresse email valide.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ Connexion réelle au backend simulé
      await MockFirebase().sendPasswordResetEmail(email);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSent = true;
        });
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
            icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowLeft01, color: Color(0xFF0D0D26), size: 20),
            onPressed: () => Navigator.pop(context),
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
                Text(
                  _isSent ? 'Email envoyé !' : 'Mot de passe oublié',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D0D26),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),

                // 📄 Sous-titre
                Text(
                  _isSent
                      ? 'Un lien de réinitialisation a été envoyé à ${_emailController.text.trim()}. Vérifiez votre boîte mail.'
                      : 'Entrez votre adresse email pour recevoir un lien de réinitialisation de votre mot de passe.',
                  style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
                ),

                const SizedBox(height: 40),

                if (!_isSent) ...[
                  // 📧 Champ Email
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF0D0D26),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 16),
                    decoration: InputDecoration(
                      hintText: 'Entrez votre adresse email',
                      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: _errorMessage != null ? Colors.red : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: _errorMessage != null ? Colors.red : const Color(0xFF0D0D26),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),

                  // ❌ Message d'erreur
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedAlertCircle, size: 14, color: Colors.red),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // 💡 Hint de simulation
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle, size: 16, color: Color(0xFF856404)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Simulation : utilisez falcon@kouture.com.',
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // 🚀 Bouton Envoyer
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isLoading || !_isFormComplete) ? null : _handleSend,
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
                              'Envoyer le lien',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                ] else ...[
                  // ✅ Succès — icône + bouton retour
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF0F0),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFF8C8C).withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: HugeIcon(icon: HugeIcons.strokeRoundedMailOpen01, size: 64,
                            color: Color(0xFFFF8C8C),),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFF8C8C),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Retour à la connexion',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
