import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/controller/blood_requirement_controller.dart';
import 'package:nss_new/controller/volunteer_controller.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/model/volunteer_model.dart';
import 'package:nss_new/view/add_blood_requirement_screen.dart';
import 'package:nss_new/view/home_screen.dart';
import 'package:nss_new/view/blood_requirement_details_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ManageBloodRequirementScreen extends StatefulWidget {
  const ManageBloodRequirementScreen({super.key});

  @override
  State<ManageBloodRequirementScreen> createState() =>
      _ManageBloodRequirementScreenState();
}

class _ManageBloodRequirementScreenState
    extends State<ManageBloodRequirementScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late final BloodRequirementController controller;
  late final VolunteerListController volunteerListController;
  int _activeTab = 0; // 0 for Requirements, 1 for Volunteers

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BloodRequirementController>()
        ? Get.find<BloodRequirementController>()
        : Get.put(BloodRequirementController());
    volunteerListController = Get.isRegistered<VolunteerListController>()
        ? Get.find<VolunteerListController>()
        : Get.put(VolunteerListController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      controller.fetchBloodRequests();
    });
  }

  void _switchTab(int tabIndex) {
    setState(() {
      _activeTab = tabIndex;
      _searchController.clear();
      _searchQuery = '';
      volunteerListController.onSearchTextChanged('');
    });
  }

  Future<void> _makeCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      Get.snackbar(
        'Unavailable',
        'No contact number provided.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.length < 5) {
      Get.snackbar(
        'Invalid Number',
        'The provided contact number is invalid ($phoneNumber).',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade800,
        colorText: Colors.white,
      );
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Dialer Unavailable',
          'Could not launch dialer. Please check if your device has a phone call app installed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade800,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initiate call: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade800,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildVolunteerCard(
    BuildContext context,
    Volunteer vol,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final displayBlood = vol.bloodGroup?.isNotEmpty == true
        ? vol.bloodGroup!
        : 'N/A';
    final displayAddress = vol.address?.isNotEmpty == true
        ? vol.address!
        : 'Not specified';
    final displayPhone = vol.phoneNumber?.isNotEmpty == true
        ? vol.phoneNumber!
        : 'Not available';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.onPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: cs.primary.withOpacity(0.1),
                      child: Text(
                        displayBlood,
                        style: tt.titleMedium?.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vol.name ?? 'Unknown Volunteer',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          if (vol.department != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${vol.department?.category ?? ''} ${vol.department?.name ?? ''}'
                                  .trim(),
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: cs.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        displayAddress,
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: cs.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.phone, color: cs.primary),
              onPressed: () {
                _makeCall(displayPhone);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildRequirementCard(
    BuildContext context,
    BloodDonationRequest req,
    ColorScheme cs,
    TextTheme tt,
  ) {
    Color urgencyBg = Colors.grey.shade100;
    Color urgencyText = Colors.grey.shade800;
    final urgencyStr = (req.urgency ?? 'normal').toLowerCase();
    if (urgencyStr.contains('critical') || urgencyStr.contains('urgent')) {
      urgencyBg = Colors.red.shade50;
      urgencyText = Colors.red.shade700;
    } else if (urgencyStr.contains('high')) {
      urgencyBg = Colors.orange.shade50;
      urgencyText = Colors.orange.shade700;
    }

    final hasValidPhone =
        req.contactNumber != null &&
        req.contactNumber!.replaceAll(RegExp(r'[^0-9+]'), '').length >= 5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => BloodRequirementDetailsSheet.show(
          context,
          req,
          onDelete: () => _showDeleteConfirmation(context, req),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.onPrimary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outline.withOpacity(0.4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.red.shade50,
                          child: Text(
                            req.bloodGroup?.isNotEmpty == true
                                ? req.bloodGroup!
                                : '🩸',
                            style: tt.titleMedium?.copyWith(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                req.patientName?.isNotEmpty == true
                                    ? req.patientName!
                                    : 'Patient in need',
                                style: tt.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_hospital_outlined,
                                    size: 14,
                                    color: cs.onSurface.withOpacity(0.5),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      req.hospital?.isNotEmpty == true
                                          ? req.hospital!
                                          : 'Hospital not specified',
                                      style: tt.bodySmall?.copyWith(
                                        color: cs.onSurface.withOpacity(0.6),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: urgencyBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (req.urgency ?? 'normal').toUpperCase(),
                      style: tt.labelSmall?.copyWith(
                        color: urgencyText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              req.contactNumber?.isNotEmpty == true
                                  ? req.contactNumber!
                                  : 'Contact not provided',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                            if (hasValidPhone) ...[
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: () => _makeCall(req.contactNumber),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.phone,
                                    size: 12,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.water_drop_outlined,
                              size: 14,
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${req.unitsRequired ?? 1} Unit${(req.unitsRequired ?? 1) > 1 ? 's' : ''} needed',
                              style: tt.bodySmall?.copyWith(
                                color: cs.onSurface.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (req.neededBefore != null &&
                            req.neededBefore!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: cs.onSurface.withOpacity(0.5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Needed by: ${req.neededBefore!}',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.share_outlined,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        tooltip: 'Share Requirement',
                        onPressed: () {
                          final needed = req.neededBefore?.isNotEmpty == true
                              ? req.neededBefore!
                              : 'ASAP';
                          final shareMessage =
                              '''
🚨 *URGENT BLOOD REQUIREMENT* 🚨

🩸 *Blood Group Needed:* ${req.bloodGroup ?? 'Any'}
👤 *Patient Name:* ${req.patientName?.isNotEmpty == true ? req.patientName : 'Patient in need'}
🏥 *Hospital:* ${req.hospital?.isNotEmpty == true ? req.hospital : 'Hospital not specified'}
📞 *Contact Number:* ${req.contactNumber?.isNotEmpty == true ? req.contactNumber : 'N/A'}
⏰ *Needed By:* $needed
⚡ *Urgency Level:* ${req.urgency ?? 'Normal'}

${req.notes?.isNotEmpty == true ? '📝 *Details:* ${req.notes}\n' : ''}
Please share this message to help find a donor as soon as possible. Thank you!
'''
                                  .trim();
                          Share.share(shareMessage);
                        },
                      ),
                      if (LocalStorage().readUser().role != 'vol') ...[
                        IconButton(
                          icon: Icon(
                            Icons.edit_outlined,
                            color: cs.primary,
                            size: 20,
                          ),
                          onPressed: () {
                            Get.to(
                              () => AddBloodRequirementScreen(requirement: req),
                            );
                          },
                        ),
                        if (req.id != null)
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: cs.error,
                              size: 20,
                            ),
                            onPressed: () {
                              _showDeleteConfirmation(context, req);
                            },
                          ),
                      ],
                    ],
                  ),
                ],
              ),
              if (req.notes?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  req.notes!,
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap for complete details',
                    style: tt.bodySmall?.copyWith(
                      fontSize: 11,
                      color: cs.primary.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: cs.primary.withOpacity(0.8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, BloodDonationRequest req) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Requirement'),
        content: Text(
          'Are you sure you want to delete the blood requirement for ${req.patientName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (req.id != null) controller.deleteRequirement(req.id!);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: cs.surface,
      floatingActionButton: _activeTab == 0
          ? FloatingActionButton(
              onPressed: () {
                Get.to(() => const AddBloodRequirementScreen());
              },
              backgroundColor: cs.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 16.0,
                top: 12.0,
                bottom: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: cs.primary),
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: cs.outline.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                          if (_activeTab == 1) {
                            volunteerListController.onSearchTextChanged(val);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: _activeTab == 0
                              ? 'Search by patient name or hospital...'
                              : 'Search volunteers by name, blood, location...',
                          hintStyle: tt.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: cs.onSurface.withOpacity(0.6),
                            size: 20,
                          ),
                          suffixIcon:
                              (_activeTab == 0
                                  ? _searchQuery.isNotEmpty
                                  : _searchController.text.isNotEmpty)
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: cs.onSurface.withOpacity(0.6),
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                    if (_activeTab == 1) {
                                      volunteerListController
                                          .onSearchTextChanged('');
                                    }
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Blood Requirement',
                    style: tt.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _activeTab == 0
                        ? 'Oversee and coordinate critical blood supply logistics'
                        : 'Search and contact potential volunteer blood donors',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

            // Sliding tab selector
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cs.outline.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchTab(0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _activeTab == 0
                                ? cs.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Requirements',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _activeTab == 0
                                  ? Colors.white
                                  : cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _switchTab(1),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _activeTab == 1
                                ? cs.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Volunteers',
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _activeTab == 1
                                  ? Colors.white
                                  : cs.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _activeTab == 0
                    ? _buildRequirementsTab(context, cs, tt)
                    : _buildVolunteersTab(context, cs, tt),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementsTab(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Requirement Registry',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            Obx(() {
              final count = controller.activeFilterCount;
              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.filter_list_rounded, size: 20),
                  tooltip: 'Filter & Sort',
                  onPressed: () => _showRequirementsFilterBottomSheet(context),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final query = _searchQuery.toLowerCase().trim();
            final baseList = controller.filteredAndSortedRequirements;
            final filteredList = baseList.where((req) {
              if (query.isEmpty) return true;
              final pName = (req.patientName ?? '').toLowerCase();
              final hName = (req.hospital ?? '').toLowerCase();
              final bGroup = (req.bloodGroup ?? '').toLowerCase();
              return pName.contains(query) ||
                  hName.contains(query) ||
                  bGroup.contains(query);
            }).toList();

            if (filteredList.isEmpty) {
              final hasFilters = controller.activeFilterCount > 0;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 56,
                        color: cs.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        query.isNotEmpty
                            ? 'No blood requirements matching "$query"'
                            : hasFilters
                            ? 'No blood requirements match the active filters'
                            : 'No blood requirements registered',
                        textAlign: TextAlign.center,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (hasFilters) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            controller.resetFilters();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Reset Filters'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () => controller.fetchBloodRequests(),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final req = filteredList[index];
                  return _buildRequirementCard(context, req, cs, tt);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildVolunteersTab(
    BuildContext context,
    ColorScheme cs,
    TextTheme tt,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Available Volunteers',
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.primary,
              ),
            ),
            Obx(() {
              final count = volunteerListController.activeFilterCount;
              return Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: IconButton.filledTonal(
                  icon: const Icon(Icons.filter_list_rounded, size: 20),
                  tooltip: 'Filter & Sort Volunteers',
                  onPressed: () => _showVolunteerFilterBottomSheet(context),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            if (volunteerListController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = volunteerListController.usersList;

            if (list.isEmpty) {
              final hasFilters = volunteerListController.activeFilterCount > 0;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_off_outlined,
                        size: 56,
                        color: cs.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        hasFilters
                            ? 'No active volunteers match selected filters'
                            : 'No active volunteers found',
                        textAlign: TextAlign.center,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (hasFilters) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            volunteerListController.clearFilters();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Reset Filters'),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                volunteerListController.getData();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final vol = list[index];
                  return _buildVolunteerCard(context, vol, cs, tt);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showRequirementsFilterBottomSheet(BuildContext context) {
    String tempBloodGroup = controller.selectedBloodGroup.value;
    String tempStatus = controller.selectedStatus.value;
    String tempUrgency = controller.selectedUrgency.value;
    String tempSort = controller.sortBy.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter & Sort Requirements',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    Flexible(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Blood Group
                            const SizedBox(height: 8),
                            Text(
                              'Blood Group',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ChoiceChip(
                                  label: const Text('All'),
                                  selected: tempBloodGroup.isEmpty,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempBloodGroup = '';
                                    });
                                  },
                                ),
                                ...controller.bloodGroups.map((bg) {
                                  return ChoiceChip(
                                    label: Text(bg),
                                    selected: tempBloodGroup == bg,
                                    onSelected: (selected) {
                                      setModalState(() {
                                        tempBloodGroup = selected ? bg : '';
                                      });
                                    },
                                  );
                                }),
                              ],
                            ),

                            // 2. Status
                            const SizedBox(height: 16),
                            Text(
                              'Request Status',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('All'),
                                  selected: tempStatus.isEmpty,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempStatus = '';
                                    });
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text('Pending / Open'),
                                  selected: tempStatus == 'pending',
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempStatus = selected ? 'pending' : '';
                                    });
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text('Fulfilled'),
                                  selected: tempStatus == 'fulfilled',
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempStatus = selected ? 'fulfilled' : '';
                                    });
                                  },
                                ),
                              ],
                            ),

                            // 3. Urgency
                            const SizedBox(height: 16),
                            Text(
                              'Urgency Level',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                ChoiceChip(
                                  label: const Text('All'),
                                  selected: tempUrgency.isEmpty,
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempUrgency = '';
                                    });
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text('Normal'),
                                  selected: tempUrgency == 'normal',
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempUrgency = selected ? 'normal' : '';
                                    });
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text('Urgent'),
                                  selected: tempUrgency == 'urgent',
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempUrgency = selected ? 'urgent' : '';
                                    });
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text('Critical'),
                                  selected: tempUrgency == 'critical',
                                  onSelected: (selected) {
                                    setModalState(() {
                                      tempUrgency = selected ? 'critical' : '';
                                    });
                                  },
                                ),
                              ],
                            ),

                            // 4. Sort Options
                            const SizedBox(height: 16),
                            Text(
                              'Sort By',
                              style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ChoiceChip(
                                  label: const Text('Newest First'),
                                  selected: tempSort == 'newest',
                                  onSelected: (selected) {
                                    setModalState(() => tempSort = 'newest');
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text('Oldest First'),
                                  selected: tempSort == 'oldest',
                                  onSelected: (selected) {
                                    setModalState(() => tempSort = 'oldest');
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text('Highest Urgency'),
                                  selected: tempSort == 'urgency',
                                  onSelected: (selected) {
                                    setModalState(() => tempSort = 'urgency');
                                  },
                                ),
                                ChoiceChip(
                                  label: const Text('Nearest Needed Date'),
                                  selected: tempSort == 'needed_date',
                                  onSelected: (selected) {
                                    setModalState(
                                      () => tempSort = 'needed_date',
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Actions Row
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempBloodGroup = '';
                                tempStatus = '';
                                tempUrgency = '';
                                tempSort = 'newest';
                              });
                              controller.resetFilters();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              controller.applyFilters(
                                bloodGroup: tempBloodGroup,
                                status: tempStatus,
                                urgency: tempUrgency,
                                sort: tempSort,
                              );
                              Navigator.of(context).pop();
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showVolunteerFilterBottomSheet(BuildContext context) {
    String tempBloodGroup = volunteerListController.selectedBloodGroup.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final tt = Theme.of(ctx).textTheme;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Filter Volunteers',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Blood Group',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        ChoiceChip(
                          label: const Text('All'),
                          selected: tempBloodGroup.isEmpty,
                          onSelected: (selected) {
                            setModalState(() {
                              tempBloodGroup = '';
                            });
                          },
                        ),
                        ...volunteerListController.bloodGroups.map((bg) {
                          return ChoiceChip(
                            label: Text(bg),
                            selected: tempBloodGroup == bg,
                            onSelected: (selected) {
                              setModalState(() {
                                tempBloodGroup = selected ? bg : '';
                              });
                            },
                          );
                        }),
                      ],
                    ),
                    const Spacer(),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setModalState(() {
                                tempBloodGroup = '';
                              });
                              volunteerListController.clearFilters();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              volunteerListController.filterByBloodGroup(
                                tempBloodGroup,
                              );
                              Navigator.of(context).pop();
                            },
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
