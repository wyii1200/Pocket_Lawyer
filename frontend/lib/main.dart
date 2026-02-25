import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'pages/Login.dart';
import 'pages/SignUp.dart';
import 'pages/ForgotPassword.dart';
import 'pages/Onboarding.dart';
import 'pages/Dashboard.dart';
import 'pages/DocumentAnalysis.dart';
import 'pages/LegalChat.dart';
import 'pages/GenerateLetter.dart';
import 'pages/HistoryPage.dart';
import 'pages/ProfilePage.dart';
import 'pages/KnowYourRights.dart';
import 'layout/MobileLayout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (kDebugMode) {
    String host = kIsWeb ? 'localhost' : '10.0.2.2';
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseStorage.instance.useStorageEmulator(host, 9199);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
    debugPrint("Running in Debug Mode: Connected to Firebase Emulators");
  }

  runApp(const PocketLawyerApp());
}

class PocketLawyerApp extends StatelessWidget {
  const PocketLawyerApp({super.key});

  Future<Widget> _getLandingPage() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const LoginPage();

    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('app_language')) {
      await prefs.setString('app_language', 'en');
    }

    final bool seenOnboarding = prefs.getBool('seenOnboarding') ?? false;

    if (seenOnboarding) {
      return const MobileLayout();
    } else {
      return const OnboardingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Lawyer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF162235),
          primary: const Color(0xFF162235),
          surface: Colors.white,
        ),
        textTheme:
            GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: const Color(0xFF1A1F2C),
          displayColor: const Color(0xFF162235),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Color(0xFF162235)),
          titleTextStyle: TextStyle(
            color: Color(0xFF162235),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: 'Poppins',
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingSplashScreen();
          }

          if (snapshot.hasData) {
            return FutureBuilder<Widget>(
              future: _getLandingPage(),
              builder: (context, innerSnapshot) {
                if (innerSnapshot.hasData) {
                  return innerSnapshot.data!;
                }
                return const LoadingSplashScreen();
              },
            );
          }

          return const LoginPage();
        },
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/onboarding': (context) => const OnboardingPage(),
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

class LoadingSplashScreen extends StatelessWidget {
  const LoadingSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF162235),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: Colors.white.withOpacity(0.03),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Icon(Icons.scale, color: Colors.white, size: 72),
                ),
                const SizedBox(height: 32),
                const Text(
                  "POCKET LAWYER",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Serif',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),
                const SizedBox(
                  width: 40,
                  child: LinearProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.white12,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
