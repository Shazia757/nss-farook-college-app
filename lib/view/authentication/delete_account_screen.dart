import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/controller/account_controller.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';

class DeleteAccountScreen extends StatelessWidget {
  DeleteAccountScreen({super.key});

  final AccountController c = Get.isRegistered<AccountController>()
      ? Get.find<AccountController>()
      : Get.put(AccountController());

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
          icon: Icon(Icons.arrow_back, color: cs.error),
          onPressed: () => Get.back(),
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
                    // Danger Zone Header
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: cs.error,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Delete Account Request",
                          style: tt.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Please note that this will send a formal deletion request to the Program Officer. Once approved, all account data, service hours, and certificates will be permanently removed.",
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Label
                    CustomWidgets().buildLabel(context, "Reason for Deletion"),
                    TextFormField(
                      controller: c.reasonController,
                      maxLines: 5,
                      style: TextStyle(color: cs.onSurface),
                      decoration: CustomWidgets().buildInputDecoration(
                        context,
                        "Specify your reason here (Min 20 characters)...",
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: Obx(
                        () => FilledButton.icon(
                          onPressed: () {
                            if (c.reasonController.text.trim().isNotEmpty) {
                              CustomWidgets().showConfirmationDialog(
                                title: "Confirm Account Deletion?",
                                content: Text(
                                  "This action is permanent. All your data and service logs will be permanently deleted and cannot be recovered.",
                                  style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurface.withOpacity(0.8),
                                  ),
                                ),
                                onConfirm: () => c.deleteAccount(),
                                data: Obx(
                                  () => c.isLoading.value
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
                            } else {
                              Get.snackbar(
                                "Error",
                                "Please specify the reason",
                              );
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: c.isLoading.value
                              ? const SizedBox()
                              : const Icon(Icons.delete_forever_rounded),
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
                                  "DELETE ACCOUNT",
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
