import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nss_new/controller/blood_requirement_controller.dart';
import 'package:nss_new/controller/volunteer_controller.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/model/volunteer_model.dart';
import 'package:nss_new/view/add_blood_requirement_screen.dart';
import 'package:nss_new/view/home_screen.dart';
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
  final BloodRequirementController controller = Get.put(
    BloodRequirementController(),
  );
  final VolunteerListController volunteerListController = Get.put(
    VolunteerListController(),
  );
  int _activeTab = 0; // 0 for Requirements, 1 for Volunteers

  void _switchTab(int tabIndex) {
    setState(() {
      _activeTab = tabIndex;
      _searchController.clear();
      _searchQuery = '';
      volunteerListController.onSearchTextChanged('');
    });
  }

  Future<void> _makeCall(String? phoneNumber) async {
    final number = phoneNumber?.isNotEmpty == true ? phoneNumber! : '+919876543210';
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        Get.snackbar(
          'Error',
          'Could not launch dialer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to initiate call: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.9),
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
    final displayBlood = vol.bloodGroup?.isNotEmpty == true ? vol.bloodGroup! : 'O+';
    final displayAddress = vol.address?.isNotEmpty == true ? vol.address! : 'Farook College Campus, Calicut';
    final displayPhone = vol.phoneNumber?.isNotEmpty == true ? vol.phoneNumber! : '+919876543210';

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
                              '${vol.department?.category ?? ''} ${vol.department?.name ?? ''}'.trim(),
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
                      backgroundColor: cs.primary.withOpacity(0.1),
                      child: Text(
                        req.bloodGroup ?? 'O+',
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
                            req.patientName ?? 'Patient',
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
                                  req.hospital ?? '',
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
                          req.contactNumber ?? '',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                    if (req.neededBefore != null) ...[
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
                            req.neededBefore!,
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
                      final shareMessage = '''
🚨 *URGENT BLOOD REQUIREMENT* 🚨

🩸 *Blood Group Needed:* ${req.bloodGroup}
👤 *Patient Name:* ${req.patientName}
🏥 *Hospital:* ${req.hospital}
📞 *Contact Number:* ${req.contactNumber}
⏰ *Needed By:* ${req.neededBefore ?? 'ASAP'}
⚡ *Urgency Level:* ${req.urgency}

${req.notes?.isNotEmpty == true ? '📝 *Details:* ${req.notes}\n' : ''}
Please share this message to help find a donor as soon as possible. Thank you!
'''.trim();
                      Share.share(shareMessage);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.edit_outlined,
                      color: cs.primary,
                      size: 20,
                    ),
                    onPressed: () {
                      Get.to(() => AddBloodRequirementScreen(requirement: req));
                    },
                  ),
                  if (req.id != null)
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: cs.error, size: 20),
                      onPressed: () {
                        _showDeleteConfirmation(context, req);
                      },
                    ),
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
        ],
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
        Text(
          'Requirement Registry',
          style: tt.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final query = _searchQuery.toLowerCase().trim();
            final filteredList = controller.requirements.where((req) {
              final pName = (req.patientName ?? '').toLowerCase();
              final hName = (req.hospital ?? '').toLowerCase();
              return pName.contains(query) || hName.contains(query);
            }).toList();

            if (filteredList.isEmpty) {
              return Center(
                child: Text(
                  'No blood requirements found',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final req = filteredList[index];
                return _buildRequirementCard(context, req, cs, tt);
              },
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
            IconButton(
              icon: Icon(Icons.sort_rounded, color: cs.primary),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => const SortVolunteerBottomSheet(),
                );
              },
            ),
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
              return Center(
                child: Text(
                  'No volunteers found',
                  style: tt.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.5),
                  ),
                ),
              );
            }

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final vol = list[index];
                return _buildVolunteerCard(context, vol, cs, tt);
              },
            );
          }),
        ),
      ],
    );
  }
}

class SortVolunteerBottomSheet extends StatelessWidget {
  const SortVolunteerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<VolunteerListController>();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Filter & Sort Volunteers",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Blood Group",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Wrap(
              spacing: 8,
              children: controller.bloodGroups.map((group) {
                return ChoiceChip(
                  label: Text(group),
                  selected: controller.selectedBloodGroup.value == group,
                  onSelected: (_) {
                    controller.filterByBloodGroup(group);
                    Get.back();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  controller.clearFilters();
                  Get.back();
                },
                child: const Text("Clear Filters"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
