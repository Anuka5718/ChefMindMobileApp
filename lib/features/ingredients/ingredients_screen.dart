import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_colors.dart';
import 'ingredient_model.dart';
import 'ingredient_repository.dart';

class IngredientsScreen extends ConsumerWidget {
  const IngredientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientsProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'My Pantry',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () => context.push('/add-ingredient'),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ingredientsAsync.when(
        loading: () => _buildShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ingredients) {
          if (ingredients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.kitchen, size: 72, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Your pantry is empty',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your first ingredient',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/add-ingredient'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Ingredient'),
                  ),
                ],
              ),
            );
          }

          // Group by category
          final fridge = ingredients.where((i) => i.category == 'fridge').toList();
          final freezer = ingredients.where((i) => i.category == 'freezer').toList();
          final pantry = ingredients.where((i) => i.category == 'pantry').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // Summary chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SummaryChip(
                      label: '${ingredients.length} Total',
                      icon: Icons.kitchen,
                      color: AppColors.primary,
                    ),
                    _SummaryChip(
                      label: '${ingredients.where((i) => i.expiryStatus == 'red').length} Expiring',
                      icon: Icons.warning_amber,
                      color: AppColors.expiryRed,
                    ),
                    _SummaryChip(
                      label: '${ingredients.where((i) => i.expiryStatus == 'green').length} Fresh',
                      icon: Icons.check_circle,
                      color: AppColors.expiryGreen,
                    ),
                  ],
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 16),

              if (fridge.isNotEmpty) ...[
                _CategoryHeader(title: 'Fridge', icon: Icons.kitchen, color: AppColors.primary),
                ...fridge.asMap().entries.map((e) =>
                    _IngredientTile(ingredient: e.value, index: e.key)),
                const SizedBox(height: 8),
              ],
              if (freezer.isNotEmpty) ...[
                _CategoryHeader(title: 'Freezer', icon: Icons.ac_unit, color: const Color(0xFF6C63FF)),
                ...freezer.asMap().entries.map((e) =>
                    _IngredientTile(ingredient: e.value, index: e.key)),
                const SizedBox(height: 8),
              ],
              if (pantry.isNotEmpty) ...[
                _CategoryHeader(title: 'Pantry', icon: Icons.shelves, color: AppColors.accent),
                ...pantry.asMap().entries.map((e) =>
                    _IngredientTile(ingredient: e.value, index: e.key)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          height: 70,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _CategoryHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientTile extends ConsumerWidget {
  final Ingredient ingredient;
  final int index;

  const _IngredientTile({required this.ingredient, required this.index});

  Color get _badgeColor {
    if (ingredient.expiryStatus == 'red') return AppColors.expiryRed;
    if (ingredient.expiryStatus == 'amber') return AppColors.expiryAmber;
    return AppColors.expiryGreen;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(ingredient.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.expiryRed,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => ref
          .read(ingredientRepositoryProvider)
          .deleteIngredient(ingredient.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  ingredient.name[0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient.name,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${ingredient.quantity} ${ingredient.unit} • ${ingredient.category}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _badgeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _badgeColor.withOpacity(0.3)),
              ),
              child: Text(
                ingredient.daysUntilExpiry <= 0
                    ? 'Today'
                    : '${ingredient.daysUntilExpiry}d',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _badgeColor,
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
    );
  }
}