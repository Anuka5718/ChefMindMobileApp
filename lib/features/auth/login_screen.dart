import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'package:chefmind/features/auth/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
      );
      // ✅ Manually navigate after successful login
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = 'Invalid email or password. Please try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter your email address first to reset password.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.expiryAmber,
        ),
      );
      return;
    }

    try {
      await ref.read(authServiceProvider).sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Password reset email sent!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: AppColors.expiryGreen,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = 'Failed to send reset email. Please check your email and try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7F5), Color(0xFFFFFFFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.08),

                  // Logo + Title
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 80,
                          height: 80,
                        ).animate().scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 500.ms,
                          curve: Curves.elasticOut,
                        ),
                        const SizedBox(height: 12),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'Chef',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              TextSpan(
                                text: 'Mind',
                                style: GoogleFonts.poppins(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.accent,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  Text(
                    'Welcome back 👋',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 4),

                  Text(
                    'Sign in to continue cooking smarter',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 32),

                  // Email field
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondaryLight,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter your password' : null,
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 650.ms),

                  const SizedBox(height: 12),

                  // Error message
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.expiryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.expiryRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.expiryRed, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: GoogleFonts.poppins(
                                color: AppColors.expiryRed,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().shake(),

                  // Login button
                  CustomButton(
                    label: 'Log In',
                    onPressed: _login,
                    isLoading: _loading,
                  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 16),

                  // Sign up link
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/signup'),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondaryLight,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: 'Sign Up',
                              style: GoogleFonts.poppins(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),
          
        ),
      ),
    );
  }
}