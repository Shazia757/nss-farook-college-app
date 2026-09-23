import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/api.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/view/authentication/login_screen.dart';
import 'package:nss_new/view/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    try {
      final res = await Api().checkVersion();
      if (res != null &&
          res.status == false &&
          (res.message?.contains('updation required') == true ||
              res.message?.contains('Unsupported') == true)) {
        Get.offAll(() => const AppUpdateScreen(status: false));
        return;
      }
    } catch (_) {
      // If version check fails due to offline/timeout, proceed gracefully
    }

    if (LocalStorage.isLoggedIn) {
      Get.offAll(() => const HomeScreen());
    } else {
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 75,
                      child: Image.asset("assets/logos/logo.png", height: 150),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "NSS Farook College",
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),

            CustomWidgets().footer(),
          ],
        ),
      ),
    );
  }
}

class AppUpdateScreen extends StatelessWidget {
  const AppUpdateScreen({super.key, required this.status});
  final bool status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: SizedBox(),
        actions: [
          TextButton(
            onPressed: () {
              ((LocalStorage().readUser().admissionNo == null) ||
                      (LocalStorage().readUser().admissionNo == ''))
                  ? Get.offAll(() => LoginScreen())
                  : Get.offAll(() => HomeScreen());
            },
            child: (status)
                ? const Text(
                    "Skip",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  )
                : SizedBox(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration or Icon
              Icon(Icons.system_update, size: 100, color: Colors.blueAccent),
              const SizedBox(height: 30),

              // Title
              (status)
                  ? const Text(
                      "Update Available",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : const Text(
                      "Update Required",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
              const SizedBox(height: 16),

              // Subtitle / description
              const Text(
                "A new version of the app is available. Update now to enjoy the latest features and improvements.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Handle update logic
                  },
                  child: const Text(
                    "Update Now",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip Button
            ],
          ),
        ),
      ),
    );
  }
}
