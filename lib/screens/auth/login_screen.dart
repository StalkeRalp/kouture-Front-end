import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/mock_firebase.dart';
import '../../backend/translator.dart';
import '../../widgets/auth_background.dart';
import '../main_navigation_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import '../../widgets/responsive_helper.dart';
import 'package:hugeicons/hugeicons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();

    // Listen to changes to update button color
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool get _isFormComplete => _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);
    
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await MockFirebase().signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushNamedAndRemoveUntil(context, MainNavigationScreen.routeName, (route) => false);
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
        body: AuthBackground(
          child: SafeArea(
            child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.w(24)),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: context.h(60)),
                    
                    // 🏷️ Header Design matching Login.jpg
                    Text(
                      Translator.t('welcome_back'),
                      style: TextStyle(
                        fontSize: context.sp(32),
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0D0D26),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: context.h(8)),
                    Text(
                      _errorMessage ?? Translator.t('search_hint').replaceFirst('...', ''),
                      style: TextStyle(
                        fontSize: context.sp(16),
                        color: _errorMessage != null ? Colors.red : Colors.grey[600],
                        fontWeight: _errorMessage != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    
                    SizedBox(height: context.h(48)),
                    
                    // 📧 Email Field
                    _buildFieldLabel(Translator.t('email')),
                    _buildTextField(
                      controller: _emailController,
                      hint: Translator.t('email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'L\'email est requis';
                        if (!value.contains('@')) return 'Format d\'email invalide';
                        return null;
                      },
                    ),
                    
                    SizedBox(height: context.h(24)),
                    
                    // 🔒 Password Field
                    _buildFieldLabel(Translator.t('password')),
                    _buildTextField(
                      controller: _passwordController,
                      hint: Translator.t('password'),
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Le mot de passe est requis';
                        return null;
                      },
                    ),
                    
                    SizedBox(height: context.h(12)),
                    
                    // 🔄 Forgot Password
                    Row(
                      children: [
                        Text(
                          '${Translator.t('forgot_password')} ',
                          style: TextStyle(color: Colors.grey[600], fontSize: context.sp(13)),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, ForgotPasswordScreen.routeName),
                          child: Text(
                            Translator.t('retry'),
                            style: TextStyle(
                              color: Color(0xFF0D0D26),
                              fontWeight: FontWeight.bold,
                              fontSize: context.sp(13),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: context.h(16)),

                    // 💡 Hint de simulation
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(10)),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(context.w(10)),
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedInformationCircle, size: context.w(16), color: Color(0xFF856404)),
                          SizedBox(width: context.w(8)),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: context.sp(12), color: Color(0xFF664D03)),
                                children: [
                                  TextSpan(text: 'Simulation — Email : '),
                                  TextSpan(
                                    text: 'falcon@kouture.com',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '  •  MDP : '),
                                  TextSpan(
                                    text: 'kouture2024',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.h(24)),

                    // 🚀 Login Button (Signature Rose / Primary Style)
                    SizedBox(
                      width: double.infinity,
                      height: context.h(56),
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormComplete ? const Color(0xFFFF8C8C) : const Color(0xFFD9D9D9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(context.w(28)),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                'Login',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: context.sp(16),
                                ),
                              ),
                      ),
                    ),
                    
                    SizedBox(height: context.h(32)),
                    
                    // ➖ Or Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                          child: Text(
                            'Or',
                            style: TextStyle(color: Colors.grey[400], fontSize: context.sp(13)),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 📱 Social Buttons
                    _buildSocialButton(
                      label: 'Login with Google',
                      icon: HugeIcons.strokeRoundedSmartPhone01,
                      color: const Color(0xFFDB4437),
                    ),
                    SizedBox(height: context.h(16)),
                    _buildSocialButton(
                      label: 'Login with Facebook',
                      icon: HugeIcons.strokeRoundedFacebook01,
                      color: const Color(0xFF4267B2),
                      isFilled: true,
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // ➕ Join Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(color: Colors.grey[600], fontSize: context.sp(14)),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, RegisterScreen.routeName),
                            child: Text(
                              'Join',
                              style: TextStyle(
                              color: Color(0xFF0D0D26),
                              fontWeight: FontWeight.bold,
                              fontSize: context.sp(14),
                              decoration: TextDecoration.underline,
                            ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.h(40)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: context.sp(16),
          color: Color(0xFF0D0D26),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool hasError = _errorMessage != null;
    
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      validator: validator,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: context.sp(16)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: context.sp(15)),
        suffixIcon: isPassword
            ? IconButton(
                icon: HugeIcon(icon: _isPasswordVisible ? HugeIcons.strokeRoundedViewOff : HugeIcons.strokeRoundedView, color: Colors.grey[400], size: context.w(24)),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: context.w(16), vertical: context.h(16)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: hasError ? Colors.red : const Color(0xFF0D0D26), width: 1.5),
        ),
        errorStyle: const TextStyle(height: 0), // Hide default error text to use manual one
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required dynamic icon,
    required Color color,
    bool isFilled = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: context.h(56),
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          backgroundColor: isFilled ? color : Colors.white,
          foregroundColor: isFilled ? Colors.white : Colors.black,
          side: isFilled ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.w(28)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(icon: icon, size: context.w(24), color: isFilled ? Colors.white : color),
            SizedBox(width: context.w(12)),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: context.sp(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}