import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Remote Config (fetches Gemini API key)
  final remoteConfig = RemoteConfigService();
  await remoteConfig.initialise();

  runApp(
    const ProviderScope(
      child: ChefMindApp(),
    ),
  );
}

class ChefMindApp extends ConsumerWidget {
  const ChefMindApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme mode — rebuilds when toggled
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'ChefMind',
      debugShowCheckedModeBanner: false,

      // Light & dark themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      // Router
      routerConfig: appRouter,
    );
  }
}