import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/controller/program_controller.dart';
import 'package:nss_new/model/programs_model.dart';

class AddProgramScreen extends StatefulWidget {
  final Program? program;

  const AddProgramScreen({super.key, this.program});

  @override
  State<AddProgramScreen> createState() => _AddProgramScreenState();
}

class _AddProgramScreenState extends State<AddProgramScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AddProgramController c;

  @override
  void initState() {
    super.initState();
    c = Get.isRegistered<AddProgramController>()
        ? Get.find<AddProgramController>()
        : Get.put(AddProgramController());
    final p = widget.program;
    if (p != null) {
      c.setUpdateData(p);
    } else {
      c.clearTextFields();
    }
  }

  @override
  void dispose() {
    c.clearTextFields();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final dayStr = date.day.toString().padLeft(2, '0');
    return "$dayStr ${months[date.month - 1]} ${date.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initial = c.date ?? now;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        c.date = DateTime(picked.year, picked.month, picked.day, 12, 0, 0);
        c.dateController.text = DateFormat.yMMMd().format(picked);
      });
    }
  }

  void _saveProgram() {
    if (c.onSubmitProgramValidation()) {
      final isEditMode = widget.program != null;
      if (isEditMode) {
        CustomWidgets().showConfirmationDialog(
          title: "Update Program",
          message: "Are you sure you want to update the program details?",
          onConfirm: () => c.updateProgram(widget.program!.id!),
          data: Obx(
            () => c.isUpdateButtonLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : const Text("Confirm", style: TextStyle(color: Colors.red)),
          ),
        );
      } else {
        CustomWidgets().showConfirmationDialog(
          title: "Add Program",
          message: "Are you sure you want to add this program?",
          onConfirm: () => c.addProgram(),
          data: Obx(
            () => c.isUpdateButtonLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.red,
                    ),
                  )
                : const Text("Confirm", style: TextStyle(color: Colors.red)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEditMode = widget.program != null;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 18,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Back to programs list',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
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
                          Text(
                            isEditMode ? 'Edit Program' : 'Add Program',
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isEditMode
                                ? 'Update the program details'
                                : 'Add an upcoming event',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),
                          CustomWidgets().buildLabel(context, "Program Name"),
                          TextFormField(
                            controller: c.nameController,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "e.g., Annual Health Awareness Campaign",
                            ),
                          ),
                          CustomWidgets().buildLabel(
                            context,
                            "Program Description",
                          ),

                          TextFormField(
                            controller: c.descController,
                            style: TextStyle(color: cs.onSurface),
                            maxLines: 3,
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Describe the program...",
                            ),
                          ),
                          CustomWidgets().buildLabel(context, "Program Date"),
                          InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: cs.outline.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: cs.outline.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    c.date == null
                                        ? 'Select date'
                                        : _formatDate(c.date!),
                                    style: tt.bodyMedium?.copyWith(
                                      color: c.date == null
                                          ? cs.onSurface.withOpacity(0.4)
                                          : cs.onSurface,
                                    ),
                                  ),
                                  Icon(
                                    Icons.calendar_today,
                                    color: cs.primary,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          CustomWidgets().buildLabel(context, "Expected Hours"),
                          TextFormField(
                            controller: c.durationController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "e.g. 3",
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: cs.primary.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(12),
                              border: Border(
                                left: BorderSide(color: cs.primary, width: 4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: cs.primary,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Note',
                                      style: tt.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: cs.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Ensure all fields are accurate. These details will be visible to all volunteers and will be used for official NSS certification reports.',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurface.withOpacity(0.8),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back(),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: cs.outline),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: tt.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveProgram,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cs.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    isEditMode
                                        ? 'Save Changes'
                                        : 'Save Program',
                                    style: tt.labelLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
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
