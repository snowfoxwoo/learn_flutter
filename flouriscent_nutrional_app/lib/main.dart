import 'package:flouriscent_nutrional_app/screens/food_diary_screen.dart';
import 'package:flouriscent_nutrional_app/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? true;

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(isDark: isDark),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flouriscent',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,

      // home: HomeScreen();
      routes: {
        '/': (context) => const HomeScreen(),
        '/food-diary': (context) => const FoodDiaryScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
