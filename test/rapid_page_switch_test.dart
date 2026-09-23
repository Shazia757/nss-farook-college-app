import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nss_new/config/color_scheme.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/user_model.dart';
import 'package:nss_new/view/home_screen.dart';
import 'package:nss_new/view/program/programs_screen.dart';
import 'package:nss_new/view/attendance/view_attendance_screen.dart';
import 'package:nss_new/view/issues/issues_screen.dart';
import 'package:nss_new/view/issues/reported_issues_screen.dart';
import 'package:nss_new/view/profile_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (MethodCall methodCall) async => '.',
        );
    Get.testMode = true;
    await GetStorage.init();
    LocalStorage().clearAll();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets(
    'Rapid page switching test - Volunteer role without setState/build exceptions',
    (WidgetTester tester) async {
      // Set up volunteer user session
      final volUser = Users(
        admissionNo: '2781',
        name: 'Volunteer 2781',
        role: 'vol',
        email: 'vol2781@example.com',
      );
      LocalStorage().writeSession(
        user: volUser,
        token: 'test-token',
        role: 'vol',
      );

      // Build MaterialApp
      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: const HomeScreen(),
        ),
      );

      // Initial frame
      await tester.pump();

      // Rapidly switch between Volunteer pages
      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: const ProgramsScreen(),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: const AttendanceScreen(),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: const IssuesScreen(),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: ProfileScreen(),
        ),
      );
      await tester.pump();

      // Rapid reverse switching
      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: const HomeScreen(),
        ),
      );
      await tester.pump();

      // Verify HomeScreen is rendered and no exceptions were thrown
      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Rapid page switching test - Program Officer role without exceptions',
    (WidgetTester tester) async {
      // Set up PO user session
      final poUser = Users(
        admissionNo: 'PO001',
        name: 'Program Officer',
        role: 'po',
        email: 'po@example.com',
      );
      LocalStorage().writeSession(
        user: poUser,
        token: 'test-token',
        role: 'po',
      );

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: const HomeScreen(),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: const ProgramsScreen(),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: const ReportedIssuesScreen(),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: ProfileScreen(),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        GetMaterialApp(
          theme: ThemeData(useMaterial3: true, colorScheme: lightColorScheme),
          home: const HomeScreen(),
        ),
      );
      await tester.pump();

      expect(find.byType(HomeScreen), findsOneWidget);
    },
  );
}
