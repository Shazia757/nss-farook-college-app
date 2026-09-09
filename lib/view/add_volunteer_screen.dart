import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/controller/volunteer_controller.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/user_model.dart';

class AddVolunteerScreen extends StatefulWidget {
  final Users? volunteer;
  const AddVolunteerScreen({super.key, this.volunteer});

  @override
  State<AddVolunteerScreen> createState() => _AddVolunteerScreenState();
}

class _AddVolunteerScreenState extends State<AddVolunteerScreen> {
  final _formKey = GlobalKey<FormState>();
  VolunteerController c = Get.put(VolunteerController());

  String? _selectedYear;
  DateTime? _selectedDOB;

  final List<String> _years = ['2023', '2024', '2025', '2026'];
  final List<String> _castes = [
    'General',
    'OBC',
    'Muslim',
    'SC',
    'ST',
    'Others',
  ];
  final List<String> _genders = ['M', 'F', 'O'];
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    final v = widget.volunteer;
    final isEditMode = widget.volunteer != null;
    if (isEditMode) {
      c.setUpdateData(v!);
      _selectedDOB = c.dob;
      _selectedYear = c.yearController.text;
    } else {
      c.clearTextFields();
      _selectedDOB = null;
      _selectedYear = null;
    }
  }

  @override
  void dispose() {
    c.clearTextFields();
    super.dispose();
  }

  String _formatDOB(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _selectDOB(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? DateTime(2005, 1, 1),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDOB) {
      setState(() {
        _selectedDOB = picked;
        c.dob = picked;
        c.dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems(
    List<String> baseList,
    String? currentValue,
  ) {
    final Set<String> itemsSet = Set.from(baseList);
    if (currentValue != null && currentValue.isNotEmpty) {
      itemsSet.add(currentValue);
    }
    return itemsSet
        .map((val) => DropdownMenuItem<String>(value: val, child: Text(val)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isEditMode = widget.volunteer != null;

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
                            Icon(Icons.arrow_back, size: 18, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Back to volunteer list',
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
                            isEditMode ? 'Edit Volunteer' : 'Add Volunteer',
                            style: tt.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isEditMode
                                ? 'Update the details of the volunteer.'
                                : 'Register a new NSS volunteer for the current academic session.',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 24),

                          CustomWidgets().buildLabel(context, "Full Name"),
                          TextFormField(
                            controller: c.nameController,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Enter full name",
                            ),
                          ),

                          CustomWidgets().buildLabel(
                            context,
                            "Admission Number",
                          ),
                          TextFormField(
                            controller: c.admissionNoController,
                            enabled: !isEditMode,
                            style: TextStyle(
                              color: isEditMode
                                  ? cs.onSurface.withOpacity(0.6)
                                  : cs.onSurface,
                            ),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Enter admission number",
                            ),
                          ),

                          CustomWidgets().buildLabel(context, "Email Address"),
                          TextFormField(
                            controller: c.emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Enter email address",
                            ),
                          ),

                          CustomWidgets().buildLabel(context, "Phone Number"),
                          TextFormField(
                            controller: c.phoneController,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: cs.onSurface),
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              "Enter phone number",
                            ),
                          ),

                          CustomWidgets().buildLabel(
                            context,
                            "Program of Study",
                          ),
                          CustomWidgets.searchableDropDown(
                            context: context,
                            controller: c.departmentController,
                            stringValueOf: (item) =>
                                "${item.category ?? ""} ${item.name ?? ''}",
                            onSelected: (p0) {
                              c.departmentController.text =
                                  "${p0.category ?? ""} ${p0.name ?? ''}";
                              c.departmentID = p0.id;
                            },
                            selectionList: c.departmentList,
                            label: "Department",
                          ),

                          CustomWidgets().buildLabel(context, "Batch Year"),
                          DropdownButtonFormField<String>(
                            value: _selectedYear,
                            decoration: CustomWidgets().buildInputDecoration(
                              context,
                              'Select Batch Year',
                            ),
                            items: _buildDropdownItems(_years, _selectedYear),
                            style: TextStyle(color: cs.onSurface, fontSize: 15),
                            dropdownColor: cs.onPrimary,
                            borderRadius: BorderRadius.circular(12),
                            onChanged: (val) {
                              setState(() {
                                _selectedYear = val;
                                c.yearController.text = val ?? '';
                              });
                            },
                          ),

                          CustomWidgets().buildLabel(context, "Blood Group"),
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value: c.selectedBloodGroup.value,
                              decoration: CustomWidgets().buildInputDecoration(
                                context,
                                'Select Blood Group',
                              ),
                              items: _buildDropdownItems(
                                _bloodGroups,
                                c.selectedBloodGroup.value,
                              ),
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 15,
                              ),
                              dropdownColor: cs.onPrimary,
                              borderRadius: BorderRadius.circular(12),
                              onChanged: (val) {
                                c.selectedBloodGroup.value = val;
                                c.bloodGroup.value = val ?? '';
                              },
                            ),
                          ),

                          CustomWidgets().buildLabel(context, "Date of Birth"),
                          InkWell(
                            onTap: () => _selectDOB(context),
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
                                    _selectedDOB == null
                                        ? 'Select Date of Birth'
                                        : _formatDOB(_selectedDOB!),
                                    style: tt.bodyMedium?.copyWith(
                                      color: _selectedDOB == null
                                          ? cs.onSurface.withOpacity(0.3)
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

                          CustomWidgets().buildLabel(context, "Gender"),
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value: c.selectedGender.value,
                              decoration: CustomWidgets().buildInputDecoration(
                                context,
                                'Select Gender',
                              ),
                              items: _buildDropdownItems(
                                _genders,
                                c.selectedGender.value,
                              ),
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 15,
                              ),
                              dropdownColor: cs.onPrimary,
                              borderRadius: BorderRadius.circular(12),
                              onChanged: (val) {
                                setState(() {
                                  c.selectedGender.value = val;
                                  c.genderController.text = val ?? '';
                                });
                              },
                            ),
                          ),
                          CustomWidgets().buildLabel(context, "Caste"),
                          Obx(
                            () => DropdownButtonFormField<String>(
                              value: c.selectedCaste.value,
                              decoration: CustomWidgets().buildInputDecoration(
                                context,
                                'Select Caste',
                              ),
                              items: _buildDropdownItems(
                                _castes,
                                c.selectedCaste.value,
                              ),
                              style: TextStyle(
                                color: cs.onSurface,
                                fontSize: 15,
                              ),
                              dropdownColor: cs.onPrimary,
                              borderRadius: BorderRadius.circular(12),
                              onChanged: (val) {
                                setState(() {
                                  c.selectedCaste.value = val;
                                  c.casteController.text = val ?? '';
                                });
                              },
                            ),
                          ),

                          if ((isEditMode) &&
                              (LocalStorage().readUser().role == 'po'))
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Promote As Secretary',
                                  style: tt.labelLarge?.copyWith(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Obx(
                                  () => Switch(
                                    value: c.role.value == 'sec',
                                    onChanged: (value) =>
                                        c.role.value = value ? 'sec' : 'vol',
                                  ),
                                ),
                              ],
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
                                  onPressed: () {
                                    if (c.onSubmitVolValidation()) {
                                      if (isEditMode) {
                                        CustomWidgets().showConfirmationDialog(
                                          title: "Update Volunteer",
                                          message:
                                              "Are you sure you want to update the volunteer details?",
                                          onConfirm: () => c.updateVolunteer(),
                                          data: Obx(
                                            () => c.isUpdateButtonLoading.value
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.red,
                                                        ),
                                                  )
                                                : const Text(
                                                    "Confirm",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                          ),
                                        );
                                      } else {
                                        CustomWidgets().showConfirmationDialog(
                                          title: "Add Volunteer",
                                          message:
                                              "Are you sure you want to add this volunteer?",
                                          onConfirm: () => c.addVolunteer(),
                                          data: Obx(
                                            () => c.isUpdateButtonLoading.value
                                                ? const SizedBox(
                                                    width: 18,
                                                    height: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: Colors.red,
                                                        ),
                                                  )
                                                : const Text(
                                                    "Confirm",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                          ),
                                        );
                                      }
                                    }
                                  },
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
                                        : 'Save Volunteer',
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
