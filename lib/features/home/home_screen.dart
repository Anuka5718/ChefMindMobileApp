import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../auth/auth_provider.dart';
import '../ingredients/ingredient_model.dart';
import '../ingredients/ingredient_repository.dart';
import '../ingredients/ingredients_screen.dart';
import '../recipes/recipe_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    _DashboardTab(),
    IngredientsScreen(),
    RecipeScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: AnimatedSwitcher(
        duration: 300.ms,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor:
          isDark ? AppColors.bgDarkSecondary : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'ChefMind',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Cook smarter with AI ✨',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Menu items
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            _DrawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            _DrawerItem(
              icon: Icons.info_outline,
              label: 'About ChefMind',
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog(context);
              },
            ),

            const Spacer(),

            const Divider(),

            // Logout
            _DrawerItem(
              icon: Icons.logout,
              label: 'Log Out',
              color: AppColors.expiryRed,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authServiceProvider).logout();
                if (context.mounted) context.go('/login');
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 32, height: 32),
            const SizedBox(width: 10),
            Text(
              'ChefMind',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'ChefMind is an AI-powered recipe generator that helps you cook smarter using ingredients you already have.\n\nPowered by Google Gemini AI.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen_outlined),
            activeIcon: Icon(Icons.kitchen),
            label: 'Pantry',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Dashboard Tab
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ingredientsAsync = ref.watch(ingredientsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Chef',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              TextSpan(
                text: 'Mind',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ingredientsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (ingredients) {
          final urgent = ingredients.where((i) => i.daysUntilExpiry <= 3).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              // Welcome card
              _WelcomeCard().animate().fadeIn().slideY(begin: -0.1, end: 0),

              const SizedBox(height: 20),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total Items',
                      value: '${ingredients.length}',
                      icon: Icons.kitchen,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Expiring Soon',
                      value: '${urgent.length}',
                      icon: Icons.warning_amber,
                      color: AppColors.expiryAmber,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Fresh Items',
                      value:
                          '${ingredients.where((i) => i.expiryStatus == 'green').length}',
                      icon: Icons.check_circle,
                      color: AppColors.expiryGreen,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Use It Now section
              if (urgent.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber,
                            color: AppColors.expiryAmber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Use It Now',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${urgent.length} items',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.expiryAmber,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 12),

                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: urgent.length,
                    itemBuilder: (_, i) => _ExpiryCard(
                      ingredient: urgent[i],
                      index: i,
                    ),
                  ),
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 24),
              ],

              // All ingredients header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Ingredients',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'See all',
                      style: GoogleFonts.poppins(
                        color: AppColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 8),

              if (ingredients.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(Icons.kitchen,
                            size: 56, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          'Your pantry is empty',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add ingredients to get started',
                          style: GoogleFonts.poppins(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...ingredients
                    .take(5)
                    .toList()
                    .asMap()
                    .entries
                    .map((e) => _SimpleIngredientTile(
                          ingredient: e.value,
                          index: e.key,
                        )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/add-ingredient'),
        backgroundColor: AppColors.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Ingredient',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting + '! 👋',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "What's cooking\ntoday?",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.push('/recipes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Get Recipes ✨',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/logo.png',
            width: 90,
            height: 90,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpiryCard extends StatelessWidget {
  final Ingredient ingredient;
  final int index;

  const _ExpiryCard({required this.ingredient, required this.index});

  Color get _color {
    if (ingredient.expiryStatus == 'red') return AppColors.expiryRed;
    if (ingredient.expiryStatus == 'amber') return AppColors.expiryAmber;
    return AppColors.expiryGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            ingredient.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            ingredient.daysUntilExpiry <= 0
                ? 'Expires today!'
                : '${ingredient.daysUntilExpiry}d left',
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: _color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 80).ms).slideX(begin: 0.2, end: 0);
  }
}

class _SimpleIngredientTile extends StatelessWidget {
  final Ingredient ingredient;
  final int index;

  const _SimpleIngredientTile({
    required this.ingredient,
    required this.index,
  });

  Color get _badgeColor {
    if (ingredient.expiryStatus == 'red') return AppColors.expiryRed;
    if (ingredient.expiryStatus == 'amber') return AppColors.expiryAmber;
    return AppColors.expiryGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF30363D)
              : Colors.grey.shade100,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                ingredient.name[0].toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 16,
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
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${ingredient.quantity} ${ingredient.unit} • ${ingredient.category}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              ingredient.daysUntilExpiry <= 0
                  ? 'Today'
                  : '${ingredient.daysUntilExpiry}d',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _badgeColor,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 60).ms).slideX(begin: 0.1, end: 0);
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? AppColors.textPrimaryLight;
    return ListTile(
      leading: Icon(icon, color: itemColor),
      title: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: itemColor,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}