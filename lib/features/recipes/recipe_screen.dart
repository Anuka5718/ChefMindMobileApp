import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../ingredients/ingredient_repository.dart';
import 'recipe_model.dart';
import 'huggingface_recipe_service.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  const RecipeScreen({super.key});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen> {
  String _dietaryType = 'None';
  List<String> _allergies = [];
  List<Recipe>? _recipes;
  bool _loading = false;
  String? _error;

  Future<void> _generate() async {
    setState(() {
      _loading = true;
      _error = null;
      _recipes = null;
    });
    try {
      final ingredients = ref.read(ingredientsProvider).valueOrNull ?? [];
      if (ingredients.isEmpty) {
        setState(() {
          _error = 'Add some ingredients first!';
          _loading = false;
        });
        return;
      }
      final recipes =
          await ref.read(huggingFaceRecipeServiceProvider).generateRecipes(
                ingredients: ingredients,
                dietaryType: _dietaryType,
                allergies: _allergies,
              );
      setState(() => _recipes = recipes);
    } catch (e) {
      setState(
          () => _error = 'Could not generate recipes. Please try again.\n$e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'AI Recipes',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Generate button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _generate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: Text(
                  'What can I cook?',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate().fadeIn().slideY(begin: -0.2, end: 0),

            const SizedBox(height: 20),

            // Loading
            if (_loading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 20),
                      Text(
                        'Asking Gemini AI...',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondaryLight,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crafting recipes from your ingredients ✨',
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondaryLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error
            if (_error != null && !_loading)
              Expanded(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.expiryRed.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: AppColors.expiryRed.withOpacity(0.3)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.expiryRed, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: AppColors.expiryRed, fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _generate,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Empty state
            if (_recipes == null && !_loading && _error == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.restaurant,
                          size: 56,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Ready to cook?',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the button above and let\nGemini AI suggest recipes!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: AppColors.textSecondaryLight,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ).animate().fadeIn().scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.0, 1.0),
                      ),
                ),
              ),

            // Recipe cards
            if (_recipes != null && !_loading)
              Expanded(
                child: ListView.builder(
                  itemCount: _recipes!.length,
                  itemBuilder: (_, i) => _RecipeCard(
                    recipe: _recipes![i],
                    index: i,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int index;

  const _RecipeCard({required this.recipe, required this.index});

  Color get _difficultyColor {
    if (recipe.difficulty == 'Easy') return AppColors.expiryGreen;
    if (recipe.difficulty == 'Medium') return AppColors.expiryAmber;
    return AppColors.expiryRed;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/recipe-detail', extra: recipe),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF30363D)
                : Colors.grey.shade100,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    recipe.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _difficultyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: _difficultyColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    recipe.difficulty,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _difficultyColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.timer,
                    size: 14, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  '${recipe.cookTimeMins} min',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.local_fire_department,
                    size: 14, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Text(
                  '${recipe.calories} kcal',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textSecondaryLight),
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.textSecondaryLight),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: recipe.ingredientsUsed
                  .take(3)
                  .map((ing) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ing,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1, end: 0),
    );
  }
}
