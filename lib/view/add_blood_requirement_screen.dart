import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/controller/blood_requirement_controller.dart';
import 'package:nss_new/model/blood_model.dart';

class AddBloodRequirementScreen extends StatefulWidget {
  final BloodDonationRequest? requirement;

  const AddBloodRequirementScreen({super.key, this.requirement});

  @override
  State<AddBloodRequirementScreen> createState() =>
      _AddBloodRequirementScreenState();
}

class _AddBloodRequirementScreenState extends State<AddBloodRequirementScreen> {
  final _formKey = GlobalKey<FormState>();
  final BloodRequirementController controller =
      Get.find<BloodRequirementController>();

  late TextEditingController _patientNameController;
  late TextEditingController _bloodGroupController;
  late TextEditingController _hospitalNameController;
  late TextEditingController _contactPersonController;
  late TextEditingController _contactNumberController;
  late TextEditingController _dateTimeController;
  late TextEditingController _unitsController;
  late TextEditingController _urgencyLevelController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final req = widget.requirement;
    _patientNameController = TextEditingController(text: req?.patientName ?? '');
    _bloodGroupController = TextEditingController(text: req?.bloodGroup ?? '');
    _hospitalNameController = TextEditingController(text: req?.hospital ?? '');
    _contactPersonController = TextEditingController(text: req?.contactPerson ?? '');
    _contactNumberController = TextEditingController(text: req?.contactNumber ?? '');
    _dateTimeController = TextEditingController(text: req?.neededBefore ?? '');
    _unitsController = TextEditingController(text: (req?.unitsRequired ?? 1).toString());
    _urgencyLevelController = TextEditingController(text: req?.urgency ?? 'normal');
    _descriptionController = TextEditingController(text: req?.notes ?? '');
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _bloodGroupController.dispose();
    _hospitalNameController.dispose();
    _contactPersonController.dispose();
    _contactNumberController.dispose();
    _dateTimeController.dispose();
    _unitsController.dispose();
    _urgencyLevelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return;

    if (!mounted) return;
    final formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    setState(() {
      _dateTimeController.text = formattedDate;
    });
  }

  void _saveRequirement() async {
    if (_formKey.currentState!.validate()) {
      final req = widget.requirement;
      final map = <String, dynamic>{
        'patient_name': _patientNameController.text.trim(),
        'blood_group': _bloodGroupController.text.trim().toUpperCase(),
        'hospital': _hospitalNameController.text.trim(),
        'contact_person': _contactPersonController.text.trim().isNotEmpty
            ? _contactPersonController.text.trim()
            : _patientNameController.text.trim(),
        'contact_number': _contactNumberController.text.trim(),
        'required_date': _dateTimeController.text.trim(),
        'units_required': int.tryParse(_unitsController.text) ?? 1,
        'urgency': _urgencyLevelController.text.trim().toLowerCase(),
        'notes': _descriptionController.text.trim(),
      };

      bool success = false;
      if (req == null) {
        success = await controller.addRequirement(map);
      } else {
        map['id'] = req.id;
        success = await controller.updateRequirement(map);
      }

      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEditMode = widget.requirement != null;

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
                              'Back to requirements list',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
                            isEditMode
                                ? 'Update emergency blood requisition'
                                : 'Create a new emergency blood requisition',
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isEditMode
                                ? 'Update the details of the active blood requirement'
                                : 'Fill the details below to raise a new emergency blood requirement',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),

                          CustomWidgets().buildLabel(context, "Patient Name"),
                          TextFormField(
                            controller: _patientNameController,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Enter patient's full name",
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? "Please enter patient name"
                                    : null,
                          ),

                          CustomWidgets().buildLabel(context, "Blood Group"),
                          TextFormField(
                            controller: _bloodGroupController,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "e.g., O+, A-, B+",
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? "Please enter blood group"
                                    : null,
                          ),

                          CustomWidgets().buildLabel(context, "Units Required"),
                          TextFormField(
                            controller: _unitsController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Number of units (e.g. 1, 2)",
                            ),
                          ),

                          CustomWidgets().buildLabel(context, "Hospital Name"),
                          TextFormField(
                            controller: _hospitalNameController,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Enter hospital name & location",
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? "Please enter hospital name"
                                    : null,
                          ),

                          CustomWidgets().buildLabel(context, "Contact Person"),
                          TextFormField(
                            controller: _contactPersonController,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Contact person name",
                            ),
                          ),

                          CustomWidgets().buildLabel(context, "Contact Number"),
                          TextFormField(
                            controller: _contactNumberController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Enter contact number",
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? "Please enter contact number"
                                    : null,
                          ),

                          CustomWidgets().buildLabel(
                            context,
                            "Required Date",
                          ),
                          TextFormField(
                            controller: _dateTimeController,
                            readOnly: true,
                            onTap: _selectDateTime,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Tap to select date",
                              suffixIcon: Icon(
                                Icons.calendar_today,
                                color: cs.primary,
                              ),
                            ),
                            validator: (val) =>
                                val == null || val.trim().isEmpty
                                    ? "Please select date"
                                    : null,
                          ),

                          CustomWidgets().buildLabel(context, "Urgency Level"),
                          DropdownButtonFormField<String>(
                            value: ['normal', 'urgent', 'critical'].contains(_urgencyLevelController.text.toLowerCase())
                                ? _urgencyLevelController.text.toLowerCase()
                                : 'normal',
                            decoration: CustomWidgets().buildInputDecoration(context, "Select urgency"),
                            items: const [
                              DropdownMenuItem(value: 'normal', child: Text('Normal')),
                              DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                              DropdownMenuItem(value: 'critical', child: Text('Critical')),
                            ],
                            onChanged: (val) {
                              if (val != null) _urgencyLevelController.text = val;
                            },
                          ),

                          CustomWidgets().buildLabel(context, "Notes / Description"),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Provide additional details",
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
                                  child: const Text('Cancel'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Obx(() => ElevatedButton(
                                  onPressed: controller.isLoading.value ? null : _saveRequirement,
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
                                  child: controller.isLoading.value
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                        )
                                      : Text(isEditMode ? 'Update Requirement' : 'Save Requirement'),
                                )),
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
