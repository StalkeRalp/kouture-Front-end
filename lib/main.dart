import 'package:flutter/material.dart';
import 'app_router.dart';
import 'backend/mock_firebase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MockFirebase().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kouture',
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFFFF8C8C),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF8C8C),
          primary: const Color(0xFFFF8C8C),
          secondary: const Color(0xFFFDECEC),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFFFF8C8C),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      initialRoute: AppRouter.initial,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
