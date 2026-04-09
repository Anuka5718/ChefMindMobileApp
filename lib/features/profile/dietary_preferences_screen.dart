import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'package:chefmind/features/auth/auth_provider.dart';

class DietaryPreferencesScreen extends ConsumerStatefulWidget {
  const DietaryPreferencesScreen({super.key});

  @override
  ConsumerState<DietaryPreferencesScreen> createState() => _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState extends ConsumerState<DietaryPreferencesScreen> {
  final _calorieCtrl = TextEditingController();
  bool _saving = false;
  bool _loading = true;
  String _dietaryType = 'omnivore';
  List<String> _allergies = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _dietaryType = data['dietaryType'] ?? 'omnivore';
          _allergies = List<String>.from(data['allergies'] ?? []);
          _calorieCtrl.text = data['weeklyCalorieTarget']?.toString() ?? '';
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _calorieCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final target = int.tryParse(_calorieCtrl.text.trim());
    try {
      await ref.read(authServiceProvider).updateDietaryPreferences(
            _dietaryType,
            _allergies,
            target,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dietary preferences updated!'),
            backgroundColor: AppColors.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dietary Preferences')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Dietary Preferences',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dietary Type
            Text(
              'Dietary Type',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimaryLight,
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['omnivore', 'vegetarian', 'vegan', 'ketogenic', 'paleo']
                  .map((type) => GestureDetector(
                        onTap: () => setState(() => _dietaryType = type),
                        child: AnimatedContainer(
                          duration: 200.ms,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _dietaryType == type ? AppColors.primary : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _dietaryType == type ? AppColors.primary : Colors.grey.shade300,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _dietaryType == type ? Colors.white : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 32),

            // Allergies
            Text(
              'Allergies',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimaryLight,
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 12),

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
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _allergies.contains(a)
                                ? AppColors.expiryRed.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _allergies.contains(a) ? AppColors.expiryRed : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            a,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: _allergies.contains(a)
                                  ? AppColors.expiryRed
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 32),

            // Weekly Calorie Target
            Text(
              'Weekly Calorie Target',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppColors.textPrimaryLight,
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
            
            const SizedBox(height: 8),
            Text(
              'Set a goal to help ChefMind keep your meals on track!',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            ).animate().fadeIn(delay: 450.ms),
            
            const SizedBox(height: 12),

            TextFormField(
              controller: _calorieCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'e.g. 14000',
                prefixIcon: Icon(Icons.local_fire_department_outlined, color: AppColors.primary),
                suffixText: 'kcal',
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 48),

            CustomButton(
              label: 'Save Preferences',
              onPressed: _save,
              isLoading: _saving,
              icon: Icons.check,
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
