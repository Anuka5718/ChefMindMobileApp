import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../shared/widgets/custom_button.dart';
import 'ingredient_model.dart';
import 'ingredient_repository.dart';

class AddIngredientScreen extends ConsumerStatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  ConsumerState<AddIngredientScreen> createState() =>
      _AddIngredientScreenState();
}

class _AddIngredientScreenState extends ConsumerState<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  String _unit = 'g';
  String _category = 'fridge';
  DateTime _expiry = DateTime.now().add(const Duration(days: 7));
  bool _saving = false;

  final List<String> _units = ['g', 'kg', 'ml', 'L', 'pcs', 'cups', 'tbsp'];
  final List<Map<String, dynamic>> _categories = [
    {'name': 'fridge', 'icon': Icons.kitchen, 'color': AppColors.primary},
    {'name': 'freezer', 'icon': Icons.ac_unit, 'color': const Color(0xFF6C63FF)},
    {'name': 'pantry', 'icon': Icons.shelves, 'color': AppColors.accent},
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _quantityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiry,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _expiry = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final ingredient = Ingredient(
      id: '',
      name: _nameCtrl.text.trim(),
      quantity: double.tryParse(_quantityCtrl.text) ?? 1,
      unit: _unit,
      category: _category,
      expiryDate: _expiry,
    );
    await ref.read(ingredientRepositoryProvider).addIngredient(ingredient);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Ingredient',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name field
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ingredient Name',
                  prefixIcon: Icon(Icons.restaurant, color: AppColors.primary),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Enter a name' : null,
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),

              // Quantity + Unit row
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.numbers, color: AppColors.primary),
                      ),
                      validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.bgDarkCard : Colors.white,
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
                                        style: GoogleFonts.poppins(fontSize: 14)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _unit = v!),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Category
              Text(
                'Storage Location',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 12),

              Row(
                children: _categories
                    .map((cat) => Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _category = cat['name']),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _category == cat['name']
                                    ? (cat['color'] as Color).withOpacity(0.15)
                                    : (isDark ? AppColors.bgDarkCard : Colors.white),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _category == cat['name']
                                      ? cat['color'] as Color
                                      : (isDark
                                          ? const Color(0xFF30363D)
                                          : Colors.grey.shade200),
                                  width: _category == cat['name'] ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    cat['icon'] as IconData,
                                    color: _category == cat['name']
                                        ? cat['color'] as Color
                                        : AppColors.textSecondaryLight,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat['name'] as String,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: _category == cat['name']
                                          ? cat['color'] as Color
                                          : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 24),

              // Expiry date
              Text(
                'Expiry Date',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 12),

              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.bgDarkCard : Colors.white,
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
                          Text(
                            'Expires on',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Text(
                            '${_expiry.day}/${_expiry.month}/${_expiry.year}',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
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
                          '${_expiry.difference(DateTime.now()).inDays}d',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 450.ms),

              const SizedBox(height: 32),

              CustomButton(
                label: 'Save Ingredient',
                onPressed: _save,
                isLoading: _saving,
                icon: Icons.check,
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}