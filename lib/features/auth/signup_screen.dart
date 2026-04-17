import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'package:chefmind/features/auth/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  
  bool _obscureConfirm = true;
  String? _error;
  String _dietaryType = 'omnivore';
  final List<String> _allergies = [];
  

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _usernameCtrl.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authServiceProvider).signUp(
        _emailCtrl.text.trim(),
        _passwordCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        dietaryType: _dietaryType,
        allergies: _allergies,
      );
      // ✅ Manually navigate after successful signup
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  IconButton(
                    onPressed: () => context.go('/login'),
                    icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
                    padding: EdgeInsets.zero,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Create Account 🍳',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ).animate().fadeIn().slideX(begin: -0.2, end: 0),

                  const SizedBox(height: 4),

                  Text(
                    'Set up your ChefMind profile',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 28),

                  // Username
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter a username' : null,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 14),

                  // Email
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Enter your email' : null,
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 14),

                  // Password
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
                    validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 14),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_outlined, color: AppColors.primary),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textSecondaryLight,
                        ),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Confirm your password' : null,
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 24),

                  // Dietary Type
                  Text(
                    'Dietary Type',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimaryLight,
                    ),
                  ).animate().fadeIn(delay: 600.ms),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['omnivore', 'vegetarian', 'vegan', 'ketogenic', 'paleo']
                        .map((type) => GestureDetector(
                              onTap: () => setState(() => _dietaryType = type),
                              child: AnimatedContainer(
                                duration: 200.ms,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _dietaryType == type
                                      ? AppColors.primary
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _dietaryType == type
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                  ),
                                  boxShadow: _dietaryType == type
                                      ? [BoxShadow(
                                          color: AppColors.primary.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        )]
                                      : [],
                                ),
                                child: Text(
                                  type,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _dietaryType == type
                                        ? Colors.white
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ).animate().fadeIn(delay: 650.ms),

                  const SizedBox(height: 20),

                  // Allergies
                  Text(
                    'Allergies (select all that apply)',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.textPrimaryLight,
                    ),
                  ).animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['gluten', 'dairy', 'nuts', 'eggs', 'shellfish']
                        .map((a) => GestureDetector(
                              onTap: () => setState(() {
                                if (_allergies.contains(a)) {
                                  _allergies.remove(a);
                                } else {
                                  _allergies.add(a);
                                }
                              }),
                              child: AnimatedContainer(
                                duration: 200.ms,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: _allergies.contains(a)
                                      ? AppColors.expiryRed.withOpacity(0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _allergies.contains(a)
                                        ? AppColors.expiryRed
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Text(
                                  a,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: _allergies.contains(a)
                                        ? AppColors.expiryRed
                                        : AppColors.textSecondaryLight,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ).animate().fadeIn(delay: 750.ms),

                  const SizedBox(height: 24),

                  // Error
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.expiryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.expiryRed.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.expiryRed, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error!,
                              style: GoogleFonts.poppins(
                                color: AppColors.expiryRed, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().shake(),

                  // Sign up button
                  CustomButton(
                    label: 'Create Account',
                    onPressed: _signUp,
                    isLoading: _loading,
                  ).animate().fadeIn(delay: 800.ms),

                  const SizedBox(height: 16),

                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/login'),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Already have an account? ',
                              style: GoogleFonts.poppins(
                                color: AppColors.textSecondaryLight,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: 'Log In',
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
                  ).animate().fadeIn(delay: 900.ms),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}