import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'services/remote_config_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final remoteConfig = RemoteConfigService();
  await remoteConfig.initialise();

  final notificationService = NotificationService();
  await notificationService.initialise();

  runApp(const ProviderScope(child: ChefMindApp()));
}

class ChefMindApp extends ConsumerStatefulWidget {
  const ChefMindApp({super.key});

  @override
  ConsumerState<ChefMindApp> createState() => _ChefMindAppState();
}

class _ChefMindAppState extends ConsumerState<ChefMindApp> {
  @override
  void initState() {
    super.initState();
    // ✅ Listen to Firebase auth changes
    // When user logs out, immediately redirect to login
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        appRouter.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'ChefMind',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}