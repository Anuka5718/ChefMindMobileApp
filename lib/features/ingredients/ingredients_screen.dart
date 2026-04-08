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
        title: Text('My Pantry',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
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
                  Text('Your pantry is empty',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text('Tap + to add your first ingredient',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.grey)),
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

          final fridge =
              ingredients.where((i) => i.category == 'fridge').toList();
          final freezer =
              ingredients.where((i) => i.category == 'freezer').toList();
          final pantry =
              ingredients.where((i) => i.category == 'pantry').toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SummaryChip(
                        label: '${ingredients.length} Total',
                        icon: Icons.kitchen,
                        color: AppColors.primary),
                    _SummaryChip(
                        label:
                            '${ingredients.where((i) => i.expiryStatus == 'red').length} Expiring',
                        icon: Icons.warning_amber,
                        color: AppColors.expiryRed),
                    _SummaryChip(
                        label:
                            '${ingredients.where((i) => i.expiryStatus == 'green').length} Fresh',
                        icon: Icons.check_circle,
                        color: AppColors.expiryGreen),
                  ],
                ),
              ).animate().fadeIn(),

              const SizedBox(height: 8),
              Text(
                'Tap any ingredient to edit it',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textSecondaryLight),
              ).animate().fadeIn(),

              const SizedBox(height: 12),

              if (fridge.isNotEmpty) ...[
                _CategoryHeader(
                    title: 'Fridge',
                    icon: Icons.kitchen,
                    color: AppColors.primary),
                ...fridge.asMap().entries.map((e) =>
                    _IngredientTile(ingredient: e.value, index: e.key)),
                const SizedBox(height: 8),
              ],
              if (freezer.isNotEmpty) ...[
                _CategoryHeader(
                    title: 'Freezer',
                    icon: Icons.ac_unit,
                    color: const Color(0xFF6C63FF)),
                ...freezer.asMap().entries.map((e) =>
                    _IngredientTile(ingredient: e.value, index: e.key)),
                const SizedBox(height: 8),
              ],
              if (pantry.isNotEmpty) ...[
                _CategoryHeader(
                    title: 'Pantry',
                    icon: Icons.shelves,
                    color: AppColors.accent),
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
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ─── Edit Bottom Sheet ────────────────────────────────────────────────────────

void showEditIngredientSheet(BuildContext context, WidgetRef ref,
    Ingredient ingredient) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditIngredientSheet(ingredient: ingredient),
  );
}

class _EditIngredientSheet extends ConsumerStatefulWidget {
  final Ingredient ingredient;
  const _EditIngredientSheet({required this.ingredient});

  @override
  ConsumerState<_EditIngredientSheet> createState() =>
      _EditIngredientSheetState();
}

class _EditIngredientSheetState
    extends ConsumerState<_EditIngredientSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _quantityCtrl;
  late String _unit;
  late String _category;
  late DateTime _expiry;
  bool _saving = false;

  final List<String> _units = ['g', 'kg', 'ml', 'L', 'pcs', 'cups', 'tbsp'];
  final List<Map<String, dynamic>> _categories = [
    {'name': 'fridge', 'icon': Icons.kitchen, 'color': AppColors.primary},
    {
      'name': 'freezer',
      'icon': Icons.ac_unit,
      'color': const Color(0xFF6C63FF)
    },
    {'name': 'pantry', 'icon': Icons.shelves, 'color': AppColors.accent},
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl =
        TextEditingController(text: widget.ingredient.name);
    _quantityCtrl = TextEditingController(
        text: widget.ingredient.quantity.toString());
    _unit = widget.ingredient.unit;
    _category = widget.ingredient.category;
    _expiry = widget.ingredient.expiryDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry.isBefore(DateTime.now())
          ? DateTime.now()
          : _expiry,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    final qty = double.tryParse(_quantityCtrl.text);
    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid quantity')),
      );
      return;
    }

    setState(() => _saving = true);

    final updated = Ingredient(
      id: widget.ingredient.id,
      name: _nameCtrl.text.trim(),
      quantity: qty,
      unit: _unit,
      category: _category,
      expiryDate: _expiry,
    );

    await ref
        .read(ingredientRepositoryProvider)
        .updateIngredient(updated);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingredient updated!'),
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: Text('Delete ingredient?',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: Text(
            'Remove "${widget.ingredient.name}" from your pantry?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete',
                style: TextStyle(color: AppColors.expiryRed)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(ingredientRepositoryProvider)
          .deleteIngredient(widget.ingredient.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final daysLeft = _expiry.difference(DateTime.now()).inDays;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDarkSecondary : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title row
              Row(
                children: [
                  Text('Edit Ingredient',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  IconButton(
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.expiryRed),
                    tooltip: 'Delete ingredient',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ingredient Name',
                  prefixIcon:
                      Icon(Icons.restaurant, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 14),

              // Quantity + Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon:
                            Icon(Icons.numbers, color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.bgDarkCard
                            : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF30363D)
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _unit,
                          isExpanded: true,
                          items: _units
                              .map((u) => DropdownMenuItem(
                                    value: u,
                                    child: Text(u,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14)),
                                  ))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _unit = v!),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category
              Text('Storage Location',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                children: _categories
                    .map((cat) => Expanded(
                          child: GestureDetector(
                            onTap: () => setState(
                                () => _category = cat['name']),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                color: _category == cat['name']
                                    ? (cat['color'] as Color)
                                        .withOpacity(0.15)
                                    : (isDark
                                        ? AppColors.bgDarkCard
                                        : Colors.white),
                                borderRadius:
                                    BorderRadius.circular(12),
                                border: Border.all(
                                  color: _category == cat['name']
                                      ? cat['color'] as Color
                                      : (isDark
                                          ? const Color(0xFF30363D)
                                          : Colors.grey.shade200),
                                  width:
                                      _category == cat['name'] ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(cat['icon'] as IconData,
                                      color: _category == cat['name']
                                          ? cat['color'] as Color
                                          : AppColors
                                              .textSecondaryLight,
                                      size: 22),
                                  const SizedBox(height: 4),
                                  Text(
                                    cat['name'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: _category == cat['name']
                                          ? cat['color'] as Color
                                          : AppColors
                                              .textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Expiry date
              Text('Expiry Date',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.bgDarkCard : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF30363D)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Expires on',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color:
                                      AppColors.textSecondaryLight)),
                          Text(
                            '${_expiry.day}/${_expiry.month}/${_expiry.year}',
                            style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          daysLeft <= 0 ? 'Today' : '${daysLeft}d',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Cancel',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : Text('Save Changes',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Supporting widgets (unchanged) ──────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  const _SummaryChip(
      {required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: color)),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  const _CategoryHeader(
      {required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: color)),
        ],
      ),
    );
  }
}

class _IngredientTile extends ConsumerWidget {
  final Ingredient ingredient;
  final int index;
  const _IngredientTile(
      {required this.ingredient, required this.index});

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
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            title: Text('Delete ingredient?',
                style:
                    GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            content: Text(
                'Remove "${ingredient.name}" from your pantry?',
                style: GoogleFonts.poppins()),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel')),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Delete',
                    style: TextStyle(color: AppColors.expiryRed)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => ref
          .read(ingredientRepositoryProvider)
          .deleteIngredient(ingredient.id),
      child: GestureDetector(
        // ← TAP TO EDIT
        onTap: () => showEditIngredientSheet(context, ref, ingredient),
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
                        color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ingredient.name,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    Text(
                        '${ingredient.quantity} ${ingredient.unit} • ${ingredient.category}',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              // Edit hint icon
              const Icon(Icons.edit_outlined,
                  size: 16, color: AppColors.textSecondaryLight),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: _badgeColor.withOpacity(0.3)),
                ),
                child: Text(
                  ingredient.daysUntilExpiry <= 0
                      ? 'Today'
                      : '${ingredient.daysUntilExpiry}d',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _badgeColor),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0),
    );
  }
}