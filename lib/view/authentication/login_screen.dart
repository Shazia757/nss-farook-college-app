import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/controller/account_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<AccountController>()
        ? Get.find<AccountController>()
        : Get.put(AccountController());

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.white),

          // Decorative background image
          Positioned.fill(
            child: Opacity(
              opacity: 1,
              child: Image.asset(
                "assets/images/login-bg.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    Image.asset("assets/logos/logo.png", height: 120),
                    const SizedBox(height: 20),

                    // Title and Motto
                    Text(
                      "NSS Farook College",
                      style: tt.headlineMedium?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '"Not Me, But You"',
                      style: tt.titleSmall?.copyWith(
                        color: cs.secondary,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Solid onPrimary Form Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cs.onPrimary, // Solid white card
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: cs.outline.withOpacity(0.4),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Admission Number Field
                          Text(
                            "Admission Number",
                            style: tt.labelLarge?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: c.userNameController,
                            style: TextStyle(color: cs.onSurface),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: cs.onSurface.withOpacity(0.6),
                                size: 20,
                              ),
                              hintText: "Enter admission number",
                              hintStyle: tt.bodyMedium!.copyWith(
                                color: cs.onSurface.withOpacity(0.2),
                              ),
                              filled: true,
                              fillColor: cs.outline.withOpacity(0.15),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: cs.outline.withOpacity(0.3),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                  color: cs.primary,
                                  width: 1.5,
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Password Field
                          Text(
                            "Password",
                            style: tt.labelLarge?.copyWith(
                              color: cs.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Obx(
                            () => TextField(
                              obscureText: c.isObscure.value,
                              controller: c.passwordController,
                              style: TextStyle(color: cs.onSurface),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: cs.onSurface.withOpacity(0.6),
                                  size: 20,
                                ),
                                suffix: GestureDetector(
                                  onTap: () => (c.isObscure.value)
                                      ? c.showPassword()
                                      : c.hidePassword(),
                                  child: Icon(
                                    c.isObscure.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey,
                                  ),
                                ),
                                hintText: "Enter password",
                                hintStyle: tt.bodyMedium!.copyWith(
                                  color: cs.onSurface.withOpacity(0.2),
                                ),
                                filled: true,
                                fillColor: cs.outline.withOpacity(0.15),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: cs.outline.withOpacity(0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: cs.primary,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Login Button
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.secondary.withOpacity(0.25),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Obx(
                              () => FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: cs.secondary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () {
                                  if (!c.isLoading.value) {
                                    c.login();
                                  }
                                },
                                icon: c.isLoading.value
                                    ? const SizedBox(width: 24, height: 24)
                                    : const Icon(Icons.login),
                                label: c.isLoading.value
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text("Logging in..."),
                                        ],
                                      )
                                    : Text(
                                        "LOGIN",
                                        style: tt.labelLarge?.copyWith(
                                          color: cs.onSecondary,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      "Version 1.0.0",
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
