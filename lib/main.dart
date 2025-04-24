import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final bool hasSeenWelcome = prefs.getBool('hasSeenWelcomeScreen') ?? false;


  runApp(MyApp(hasSeenWelcome: hasSeenWelcome));
}

class MyApp extends StatelessWidget {
  final bool hasSeenWelcome;


  const MyApp({super.key, required this.hasSeenWelcome});

  @override
  Widget build(BuildContext context) {

    final Color corPrimaria = Colors.green;
    final Color corTextoPrimario = Colors.white;

    return MaterialApp(
      title: 'Descarte Consciente',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(
          seedColor: corPrimaria,
          primary: corPrimaria,
          onPrimary: corTextoPrimario,
          // todo: adicionar + opções de temas e modo noturno
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: corPrimaria,
          foregroundColor: corTextoPrimario,
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          iconTheme: IconThemeData(color: corTextoPrimario),
          actionsIconTheme: IconThemeData(color: corTextoPrimario),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: corPrimaria,
            foregroundColor: corTextoPrimario,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        sliderTheme: SliderThemeData(
          activeTrackColor: corPrimaria,
          inactiveTrackColor: corPrimaria.withOpacity(0.3),
          thumbColor: corPrimaria,
          overlayColor: corPrimaria.withAlpha(0x29),
          valueIndicatorColor: Colors.green.shade700,
          activeTickMarkColor: Colors.transparent,
          inactiveTickMarkColor: Colors.transparent,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Remove o banner de debug
      home: hasSeenWelcome ? const HomeScreen() : const WelcomeScreen(),

    );
  }
}
