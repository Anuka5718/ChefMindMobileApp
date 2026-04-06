import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import 'recipe_model.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({super.key, required this.recipe});

  Color get _difficultyColor {
    if (recipe.difficulty == 'Easy') return AppColors.expiryGreen;
    if (recipe.difficulty == 'Medium') return AppColors.expiryAmber;
    return AppColors.expiryRed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios,
                    size: 16, color: AppColors.primary),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const Icon(Icons.restaurant,
                          size: 56, color: Colors.white),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          recipe.name,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meta info row
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.timer,
                        label: '${recipe.cookTimeMins} min',
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      _MetaChip(
                        icon: Icons.local_fire_department,
                        label: '${recipe.calories} kcal',
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 10),
                      _MetaChip(
                        icon: Icons.bar_chart,
                        label: recipe.difficulty,
                        color: _difficultyColor,
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Ingredients used
                  Text(
                    'Ingredients You Have ✅',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 10),

                  ...recipe.ingredientsUsed.asMap().entries.map((e) =>
                      _IngredientRow(
                        name: e.value,
                        available: true,
                        index: e.key,
                      )),

                  if (recipe.ingredientsMissing.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'You\'ll Also Need 🛒',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: 10),
                    ...recipe.ingredientsMissing.asMap().entries.map((e) =>
                        _IngredientRow(
                          name: e.value,
                          available: false,
                          index: e.key,
                        )),
                  ],

                  const SizedBox(height: 24),

                  // Steps
                  Text(
                    'Instructions 👨‍🍳',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 12),

                  ...recipe.steps.asMap().entries.map((e) =>
                      _StepCard(step: e.value, number: e.key + 1)),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final String name;
  final bool available;
  final int index;

  const _IngredientRow({
    required this.name,
    required this.available,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: available
            ? AppColors.expiryGreen.withOpacity(0.08)
            : AppColors.expiryRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: available
              ? AppColors.expiryGreen.withOpacity(0.3)
              : AppColors.expiryRed.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.check_circle : Icons.shopping_cart,
            size: 18,
            color: available ? AppColors.expiryGreen : AppColors.expiryRed,
          ),
          const SizedBox(width: 10),
          Text(
            name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final int number;

  const _StepCard({required this.step, required this.number});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF30363D)
              : Colors.grey.shade100,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step,
              style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (number * 80).ms).slideY(begin: 0.1, end: 0);
  }
}