import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../backend/mock_firebase.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  String? _errorMessage;
  bool _isSuccess = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
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
    _fullNameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _phoneController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _confirmPasswordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {});
  }

  bool get _isFormComplete {
    return _fullNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _agreeToTerms;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        setState(() => _errorMessage = 'Please agree to the Terms & Conditions');
        return;
      }

      setState(() => _isLoading = true);

      try {
        await MockFirebase().signUp(
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text,
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSuccess = true;
          });
          
          // Simulation feedback success matching "Sign Up - Success.jpg"
          await Future.delayed(const Duration(seconds: 2));
          
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/otp-verification');
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) return _buildSuccessOverlay();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    
                    const Text(
                      'Create an account',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0D0D26),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage ?? 'Join the world of premium tailoring.',
                      style: TextStyle(
                        fontSize: 16,
                        color: _errorMessage != null ? Colors.red : Colors.grey[600],
                        fontWeight: _errorMessage != null ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    _buildFieldLabel('Full Name'),
                    _buildTextField(
                      controller: _fullNameController,
                      hint: 'Enter your full name',
                      validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildFieldLabel('Email'),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null || !value.contains('@') ? 'Invalid email' : null,
                    ),

                    const SizedBox(height: 20),

                    _buildFieldLabel('Phone Number'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: 'Enter your phone number',
                      keyboardType: TextInputType.phone,
                      validator: (value) => value == null || value.length < 8 ? 'Invalid number' : null,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    _buildFieldLabel('Password'),
                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Create a password',
                      isPassword: true,
                      validator: (value) => value == null || value.length < 6 ? 'Too short' : null,
                    ),

                    const SizedBox(height: 20),

                    _buildFieldLabel('Confirm Password'),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      hint: 'Confirm your password',
                      isPassword: true,
                      isConfirm: true,
                      validator: (value) => value != _passwordController.text ? 'Mismatch' : null,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 🔘 Terms & Conditions Checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _agreeToTerms,
                            onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
                            activeColor: const Color(0xFF0D0D26),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'I agree to the Terms & Conditions and Privacy Policy',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // 🚀 Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFormComplete ? const Color(0xFFFF8C8C) : const Color(0xFFD9D9D9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // ➖ Or Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text('Or', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    _buildSocialButton(
                      label: 'Join with Google',
                      icon: Icons.g_mobiledata,
                      color: const Color(0xFFDB4437),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: const Text(
                              'Login',
                              style: TextStyle(
                                color: Color(0xFF0D0D26),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF1FFF1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, size: 80, color: Colors.green),
            ),
            const SizedBox(height: 32),
            const Text(
              'Account Created!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D0D26)),
            ),
            const SizedBox(height: 12),
            const Text(
              'We have sent a verification code to you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D0D26)),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    bool isPassword = false,
    bool isConfirm = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final bool hasError = _errorMessage != null;
    
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !(isConfirm ? _isConfirmPasswordVisible : _isPasswordVisible),
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[300], fontSize: 14),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  (isConfirm ? _isConfirmPasswordVisible : _isPasswordVisible) ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                   setState(() {
                     if (isConfirm) _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                     else _isPasswordVisible = !_isPasswordVisible;
                   });
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        errorStyle: const TextStyle(height: 0),
      ),
    );
  }

  Widget _buildSocialButton({required String label, required IconData icon, required Color color}) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey[300]!),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}