import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as di;
import 'package:firebase_core/firebase_core.dart';

import 'services/theme_service.dart';
import 'services/auth_service.dart';
import 'services/job_service.dart';
import 'services/storage_service.dart';
import 'models/job_model.dart';
import 'models/user_model.dart';
import 'screens/splash_screen.dart';
import 'screens/applications/apply_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => JobService()),
      ],
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          return MaterialApp(
            title: 'Job Board',
            debugShowCheckedModeBanner: false,
            theme: themeService.lightTheme,
            darkTheme: themeService.darkTheme,
            themeMode: themeService.themeMode,
            home: StreamBuilder<UserModel?>(
              stream: Provider.of<AuthService>(context, listen: false).authStateChanges,
              builder: (context, snapshot) {
                return const SplashScreen();
              },
            ),
          );
        },
      ),
    );
  }
}