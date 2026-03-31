import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../auth/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    final isLoggedIn = authState.valueOrNull != null;
    if (isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7F5), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 120,
                height: 120,
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 700.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 500.ms),

              const SizedBox(height: 20),

              // ChefMind text
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Chef',
                      style: GoogleFonts.poppins(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF00B4A6),
                      ),
                    ),
                    TextSpan(
                      text: 'Mind',
                      style: GoogleFonts.poppins(
                        fontSize: 38,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFF6B35),
                      ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 500.ms)
                  .slideY(
                    begin: 0.3,
                    end: 0,
                    delay: 500.ms,
                    duration: 500.ms,
                    curve: Curves.easeOut,
                  ),

              const SizedBox(height: 8),

              // Tagline
              Text(
                'Cook smarter with AI ✨',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.3,
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 500.ms),

              const SizedBox(height: 60),

              // Loading bar
              Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    color: Color(0xFF00B4A6),
                  ),
                ),
              ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}