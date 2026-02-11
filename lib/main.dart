import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import all your pages
import 'pages/Login.dart';
import 'pages/SignUp.dart';
import 'pages/Dashboard.dart';
import 'pages/DocumentAnalysis.dart';
import 'pages/LegalChat.dart';
import 'pages/GenerateLetter.dart';
import 'pages/HistoryPage.dart';
import 'pages/ProfilePage.dart';
import 'pages/KnowYourRights.dart';
import 'layout/MobileLayout.dart';

void main() {
  runApp(const PocketLawyerApp());
}

class PocketLawyerApp extends StatelessWidget {
  const PocketLawyerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Lawyer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF162235),
          primary: const Color(0xFF162235),
          secondary: const Color(0xFF4A5568), // subtle accent
          surface: const Color(0xFFF1F4F9),
          background: const Color(0xFFFFFFFF),
          error: const Color(0xFFEF4444),
          onPrimary: Colors.white,
          onSurface: const Color(0xFF1A1F2C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF1F4F9),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 1,
          foregroundColor: Color(0xFF162235),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF162235),
          ),
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF162235),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF162235),
            side: const BorderSide(color: Color(0xFF162235)),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/main': (context) => const MobileLayout(),
        '/dashboard': (context) => const DashboardPage(),
        '/analyze': (context) => const DocumentAnalysisPage(),
        '/chat': (context) => const LegalChatPage(),
        '/letter': (context) => const GenerateLetterPage(),
        '/history': (context) => const HistoryPage(),
        '/profile': (context) => const ProfilePage(),
        '/rights': (context) => const KnowYourRightsPage(),
      },
    );
  }
}
