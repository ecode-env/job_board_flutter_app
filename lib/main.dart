import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:job_board_flutter_app/services/theme_service.dart';
import 'package:job_board_flutter_app/services/auth_service.dart';
import 'package:job_board_flutter_app/services/job_service.dart';
import 'package:job_board_flutter_app/models/user_model.dart';
import 'package:job_board_flutter_app/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

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