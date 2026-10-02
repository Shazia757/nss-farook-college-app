import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/controller/account_controller.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    required this.userId,
    required this.isChangepassword,
    this.volunteerName,
  });

  final String userId;
  final bool isChangepassword;
  final String? volunteerName;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  late final AccountController c;

  @override
  void initState() {
    super.initState();
    c = Get.isRegistered<AccountController>()
        ? Get.find<AccountController>()
        : Get.put(AccountController());
    c.clearPasswordFields();
  }

  @override
  void dispose() {
    c.clearPasswordFields();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          "${widget.isChangepassword ? "Change" : "Reset"} Password",
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
                    color: cs.outline.withValues(alpha: 0.4),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
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
                      widget.isChangepassword
                          ? "Change Password"
                          : "Reset Password",
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.isChangepassword
                          ? "Enter your old password and choose a secure new password."
                          : "Set a new secure password for this volunteer.",
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Target Volunteer Details Card (if reset mode)
                    if (!widget.isChangepassword) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: cs.primary.withValues(
                                alpha: 0.15,
                              ),
                              child: Icon(
                                Icons.person,
                                color: cs.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.volunteerName != null &&
                                      widget.volunteerName!.isNotEmpty) ...[
                                    Text(
                                      widget.volunteerName!,
                                      style: tt.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    "Admission No: ${widget.userId}",
                                    style: tt.bodyMedium?.copyWith(
                                      color: cs.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Staff password reset action",
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.onSurface.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Old Password Field (ONLY in change mode)
                    if (widget.isChangepassword) ...[
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
                                color: cs.onSurface.withValues(alpha: 0.6),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
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
                              color: cs.onSurface.withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

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
                              color: cs.onSurface.withValues(alpha: 0.6),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Obx(() {
                        final isLoading = c.isChangePassLoading.value;
                        return FilledButton.icon(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (widget.isChangepassword) {
                                    if (c.onChangePassValidation()) {
                                      CustomWidgets().showConfirmationDialog(
                                        title: "Change Password",
                                        message:
                                            "Are you sure you want to change your password?",
                                        onConfirm: () {
                                          Get.back();
                                          c.changePassword();
                                        },
                                        data: const Text(
                                          'Confirm',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      );
                                    }
                                  } else {
                                    if (c.onResetPassValidation()) {
                                      final targetDesc =
                                          (widget.volunteerName != null &&
                                              widget.volunteerName!.isNotEmpty)
                                          ? "${widget.volunteerName} (${widget.userId})"
                                          : widget.userId;
                                      CustomWidgets().showConfirmationDialog(
                                        title: "Reset Password",
                                        message:
                                            "Are you sure you want to reset the password for $targetDesc?",
                                        onConfirm: () async {
                                          Get.back(); // close confirmation dialog
                                          await c.resetPassword(widget.userId);
                                        },
                                        data: const Text(
                                          'Confirm',
                                          style: TextStyle(color: Colors.red),
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
                          icon: isLoading
                              ? const SizedBox.shrink()
                              : const Icon(Icons.lock_reset_rounded),
                          label: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Submitting...",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                )
                              : Text(
                                  widget.isChangepassword
                                      ? "CHANGE PASSWORD"
                                      : "RESET PASSWORD",
                                  style: tt.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        );
                      }),
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
