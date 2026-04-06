import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/signup_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/ingredients/ingredients_screen.dart';
import 'features/ingredients/add_ingredient_screen.dart';
import 'features/recipes/recipe_screen.dart';
import 'features/recipes/recipe_detail_screen.dart';
import 'features/recipes/recipe_model.dart';
import 'features/profile/profile_screen.dart';
import 'features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  redirect: (context, state) {
    final container = ProviderScope.containerOf(context);
    final authState = container.read(authStateProvider);
    final isLoggedIn = authState.valueOrNull != null;
    final isSplash = state.matchedLocation == '/splash';
    final onAuthPage = state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup';

    if (isSplash) return null;
    if (!isLoggedIn && !onAuthPage) return '/login';
    if (isLoggedIn && onAuthPage) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (_, __) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/ingredients',
      builder: (_, __) => const IngredientsScreen(),
    ),
    GoRoute(
      path: '/add-ingredient',
      builder: (_, __) => const AddIngredientScreen(),
    ),
    GoRoute(
      path: '/recipes',
      builder: (_, __) => const RecipeScreen(),
    ),
    GoRoute(
      path: '/recipe-detail',
      builder: (context, state) {
        final recipe = state.extra as Recipe;
        return RecipeDetailScreen(recipe: recipe);
      },
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);