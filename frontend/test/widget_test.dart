import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_lawyer/main.dart';
import 'package:pocket_lawyer/pages/Dashboard.dart';
import 'package:pocket_lawyer/pages/DocumentAnalysis.dart';
import 'package:pocket_lawyer/pages/LegalChat.dart';
import 'package:pocket_lawyer/pages/KnowYourRights.dart';
import 'package:pocket_lawyer/pages/HistoryPage.dart';
import 'package:pocket_lawyer/pages/ProfilePage.dart';
import 'package:pocket_lawyer/pages/GenerateLetter.dart';
import 'package:pocket_lawyer/layout/MobileLayout.dart';

void main() {
  group('Pocket Lawyer App Widget Tests', () {
    testWidgets('Login page renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const PocketLawyerApp());

      expect(find.text('Pocket Lawyer'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Navigation to Sign Up page works',
        (WidgetTester tester) async {
      await tester.pumpWidget(const PocketLawyerApp());

      final createButton = find.text('Create Account');
      await tester.tap(createButton);
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.text('Full Name'), findsOneWidget);
    });

    testWidgets('MobileLayout bottom navigation works',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: MobileLayout()));
      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsOneWidget);

      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.byType(HistoryPage), findsOneWidget);

      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('Legal Chat page displays initial message',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LegalChatPage()));
      await tester.pumpAndSettle();

      expect(find.textContaining('Hello! I\'m your legal assistant'),
          findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Know Your Rights page shows all rights cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: KnowYourRightsPage()));
      await tester.pumpAndSettle();

      expect(find.text('FOR EDUCATIONAL PURPOSES ONLY'), findsOneWidget);
      expect(find.textContaining('Employment Rights'), findsOneWidget);
      expect(find.textContaining('Tenant Rights'), findsOneWidget);
      expect(find.textContaining('Consumer Rights'), findsOneWidget);
      expect(find.textContaining('Contract Basics'), findsOneWidget);
    });

    testWidgets('Document Analysis page has input and buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: DocumentAnalysisPage()));
      await tester.pumpAndSettle();

      expect(find.text('Document Analysis'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('Generate Letter page has input fields and buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GenerateLetterPage()));
      await tester.pumpAndSettle();

      expect(find.text('Generate Legal Letter'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('HistoryPage displays list and empty state',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryPage()));
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      // If there are no items yet, show empty state text
      expect(find.textContaining('No history available'), findsOneWidget);
    });
  });
}
