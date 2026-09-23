import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/controller/account_controller.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({
    super.key,
    required this.userId,
    required this.isChangepassword,
  });
  final String userId;
  final bool isChangepassword;

  @override
  Widget build(BuildContext context) {
    final AccountController c = Get.isRegistered<AccountController>()
        ? Get.find<AccountController>()
        : Get.put(AccountController());
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.primary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "${isChangepassword ? "Change" : "Reset"} Password",
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cs.onPrimary,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: cs.outline.withOpacity(0.4),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading Text
                    Text(
                      isChangepassword ? "Change Password" : "Reset Password",
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isChangepassword
                          ? "Enter your old password and choose a secure new password."
                          : "Choose a new secure password for volunteer $userId.",
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Target User ID (if reset)
                    if (!isChangepassword) ...[
                      CustomWidgets().buildLabel(context, "Admission Number"),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: cs.outline.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          userId,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ],

                    // Old Password Field (if change mode)
                    if (isChangepassword) ...[
                      CustomWidgets().buildLabel(context, "Old Password"),
                      Obx(
                        () => TextFormField(
                          controller: c.oldpasswordController,
                          obscureText: c.isOldPassObscure.value,
                          style: TextStyle(color: cs.onSurface),
                          decoration: CustomWidgets().buildInputDecoration(
                            context,
                            "Enter old password",
                            suffixIcon: IconButton(
                              onPressed: () => c.isOldPassObscure.value
                                  ? c.showOldPassword()
                                  : c.hideOldPassword(),
                              icon: Icon(
                                c.isOldPassObscure.value
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: cs.onSurface.withOpacity(0.6),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],

                    // New Password Field
                    CustomWidgets().buildLabel(context, "New Password"),
                    Obx(
                      () => TextFormField(
                        controller: c.newPassController,
                        obscureText: c.isNewPassObscure.value,
                        style: TextStyle(color: cs.onSurface),
                        decoration: CustomWidgets().buildInputDecoration(
                          context,
                          "Enter new password",
                          suffixIcon: IconButton(
                            onPressed: () => c.isNewPassObscure.value
                                ? c.showNewPassword()
                                : c.hideNewPassword(),
                            icon: Icon(
                              c.isNewPassObscure.value
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: cs.onSurface.withOpacity(0.6),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Confirm Password Field
                    CustomWidgets().buildLabel(context, "Confirm New Password"),
                    Obx(
                      () => TextFormField(
                        controller: c.confirmPassController,
                        obscureText: c.isConfirmPassObscure.value,
                        style: TextStyle(color: cs.onSurface),
                        decoration: CustomWidgets().buildInputDecoration(
                          context,
                          "Confirm new password",
                          suffixIcon: IconButton(
                            onPressed: () => c.isConfirmPassObscure.value
                                ? c.showConfirmPassword()
                                : c.hideConfirmPassword(),
                            icon: Icon(
                              c.isConfirmPassObscure.value
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              color: cs.onSurface.withOpacity(0.6),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Save Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Obx(
                        () => FilledButton.icon(
                          onPressed: () {
                            if (isChangepassword) {
                              if (c.onChangePassValidation()) {
                                CustomWidgets().showConfirmationDialog(
                                  title: "Change Password",
                                  message:
                                      "Are you sure you want to change your password?",
                                  onConfirm: () => c.changePassword(userId),
                                  data: Obx(
                                    () => (c.isChangePassLoading.value)
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.red,
                                            ),
                                          )
                                        : const Text(
                                            'Confirm',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  ),
                                );
                              }
                            } else {
                              if (c.onResetPassValidation()) {
                                CustomWidgets().showConfirmationDialog(
                                  title: "Reset Password",
                                  message:
                                      "Are you sure you want to reset the password?",
                                  onConfirm: () {
                                    c.resetPassword(userId);
                                    Get.back();
                                  },
                                  data: Obx(
                                    () => (c.isChangePassLoading.value)
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.red,
                                            ),
                                          )
                                        : const Text(
                                            'Confirm',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  ),
                                );
                              }
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: c.isLoading.value
                              ? const SizedBox()
                              : const Icon(Icons.lock_rounded),
                          label: c.isLoading.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isChangepassword
                                      ? "CHANGE PASSWORD"
                                      : "RESET PASSWORD",
                                  style: tt.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
