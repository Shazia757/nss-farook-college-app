import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/controller/blood_requirement_controller.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/blood_model.dart';
import 'package:nss_new/view/add_blood_requirement_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BloodRequirementDetailsSheet extends StatefulWidget {
  final BloodDonationRequest request;
  final VoidCallback? onDelete;

  const BloodRequirementDetailsSheet({
    super.key,
    required this.request,
    this.onDelete,
  });

  static void show(
    BuildContext context,
    BloodDonationRequest req, {
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          BloodRequirementDetailsSheet(request: req, onDelete: onDelete),
    );
  }

  static Future<void> makeCall(
    BuildContext context,
    String? phoneNumber,
  ) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      CustomWidgets.showSnackBar(
        'Unavailable',
        'No contact number provided for this requirement.',
        backgroundColor: Colors.orange.shade800,
      );
      return;
    }

    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.length < 5) {
      CustomWidgets.showSnackBar(
        'Invalid Number',
        'The provided phone number is invalid ($phoneNumber).',
        backgroundColor: Colors.orange.shade800,
      );
      return;
    }

    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri, mode: LaunchMode.externalApplication);
      } else {
        CustomWidgets.showSnackBar(
          'Dialer Unavailable',
          'Could not launch dialer. Please verify that this device has a phone call app installed.',
          backgroundColor: Colors.red.shade800,
        );
      }
    } catch (e) {
      CustomWidgets.showSnackBar(
        'Error',
        'Failed to initiate call: $e',
        backgroundColor: Colors.red.shade800,
      );
    }
  }

  @override
  State<BloodRequirementDetailsSheet> createState() =>
      _BloodRequirementDetailsSheetState();
}

class _BloodRequirementDetailsSheetState
    extends State<BloodRequirementDetailsSheet> {
  late String _currentStatus;
  BloodDonationRequest get request => widget.request;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.request.status?.toLowerCase() ?? 'pending';
  }

  void _shareRequirement() {
    final needed =
        request.neededBefore != null && request.neededBefore!.isNotEmpty
        ? request.neededBefore!
        : 'Immediately / ASAP';
    final shareMessage =
        '''
🚨 *URGENT BLOOD REQUIREMENT* 🚨
NSS Farook College Emergency Blood Network

🩸 *Blood Group:* ${request.bloodGroup ?? 'Any'}
👤 *Patient Name:* ${request.patientName?.isNotEmpty == true ? request.patientName : 'Patient in need'}
💉 *Units Required:* ${request.unitsRequired ?? 1}
🏥 *Hospital:* ${request.hospital?.isNotEmpty == true ? request.hospital : 'Local Hospital'}
📞 *Contact Person:* ${request.contactPerson?.isNotEmpty == true ? request.contactPerson : 'NSS Coordinator'}
📱 *Contact Number:* ${request.contactNumber?.isNotEmpty == true ? request.contactNumber : 'N/A'}
⏰ *Needed By:* $needed
⚡ *Urgency Level:* ${(request.urgency ?? 'Normal').toUpperCase()}
${request.notes?.isNotEmpty == true ? '📝 *Notes:* ${request.notes}\n' : ''}
Please share this message with eligible donors. Every second counts!
'''
            .trim();

    Share.share(shareMessage);
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Not available';
    try {
      return DateFormat('d MMM yyyy, h:mm a').format(dt);
    } catch (_) {
      return dt.toString();
    }
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return 'Not specified / ASAP';
    try {
      final parsed = DateTime.tryParse(raw);
      if (parsed != null) {
        return DateFormat('d MMMM yyyy').format(parsed);
      }
    } catch (_) {}
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final role = LocalStorage().readUser().role;
    final isAuthorized = role == 'po' || role == 'sec';

    final urgencyStr = (request.urgency ?? 'normal').toLowerCase();
    Color urgencyBg = Colors.grey.shade100;
    Color urgencyColor = Colors.grey.shade800;
    if (urgencyStr.contains('critical')) {
      urgencyBg = Colors.red.shade100;
      urgencyColor = Colors.red.shade900;
    } else if (urgencyStr.contains('urgent')) {
      urgencyBg = Colors.orange.shade100;
      urgencyColor = Colors.orange.shade900;
    } else {
      urgencyBg = Colors.green.shade50;
      urgencyColor = Colors.green.shade800;
    }

    final statusStr = (request.status ?? 'open').toLowerCase();
    Color statusBg = Colors.blue.shade50;
    Color statusColor = Colors.blue.shade800;
    if (statusStr.contains('fulfill')) {
      statusBg = Colors.green.shade50;
      statusColor = Colors.green.shade800;
    } else if (statusStr.contains('cancel')) {
      statusBg = Colors.grey.shade200;
      statusColor = Colors.grey.shade700;
    }

    final hasValidPhone =
        request.contactNumber != null &&
        request.contactNumber!.replaceAll(RegExp(r'[^0-9+]'), '').length >= 5;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: cs.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Top Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.red.shade50,
                    child: Text(
                      request.bloodGroup?.isNotEmpty == true
                          ? request.bloodGroup!
                          : '🩸',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          request.patientName?.isNotEmpty == true
                              ? request.patientName!
                              : 'Patient Name Not Specified',
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: urgencyBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (request.urgency ?? 'Normal').toUpperCase(),
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: urgencyColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                (request.status ?? 'Pending').toUpperCase(),
                                style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Scrollable Details Body
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick stats row
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            context,
                            icon: Icons.bloodtype,
                            label: 'Group',
                            value: request.bloodGroup ?? 'N/A',
                            color: Colors.red.shade700,
                          ),
                          Container(
                            height: 32,
                            width: 1,
                            color: cs.outline.withOpacity(0.2),
                          ),
                          _buildStatItem(
                            context,
                            icon: Icons.water_drop_outlined,
                            label: 'Units Needed',
                            value:
                                '${request.unitsRequired ?? 1} Unit${(request.unitsRequired ?? 1) > 1 ? 's' : ''}',
                            color: cs.primary,
                          ),
                          Container(
                            height: 32,
                            width: 1,
                            color: cs.outline.withOpacity(0.2),
                          ),
                          _buildStatItem(
                            context,
                            icon: Icons.access_time_rounded,
                            label: 'Needed By',
                            value: request.neededBefore?.isNotEmpty == true
                                ? request.neededBefore!
                                : 'ASAP',
                            color: Colors.orange.shade800,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Requirement Status Section & Dropdown
                    _buildSectionHeader(
                      context,
                      title: 'Requirement Status',
                      icon: Icons.published_with_changes_rounded,
                    ),
                    const SizedBox(height: 8),
                    if (!isAuthorized) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: cs.onPrimary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _currentStatus == 'fulfilled'
                                    ? Colors.green
                                    : _currentStatus == 'cancelled'
                                        ? Colors.grey
                                        : Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _currentStatus == 'fulfilled'
                                    ? 'Fulfilled'
                                    : _currentStatus == 'cancelled'
                                        ? 'Cancelled'
                                        : 'Pending / Open',
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.onPrimary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.3),
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: ['pending', 'fulfilled', 'cancelled'].contains(_currentStatus)
                                ? _currentStatus
                                : 'pending',
                            isExpanded: true,
                            dropdownColor: cs.onPrimary,
                            borderRadius: BorderRadius.circular(12),
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: cs.primary,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'pending',
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.blue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Pending / Open',
                                      style: tt.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'fulfilled',
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Fulfilled',
                                      style: tt.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'cancelled',
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Cancelled',
                                      style: tt.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: cs.onSurface,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (newStatus) async {
                              if (newStatus == null || newStatus == _currentStatus) return;
                              setState(() {
                                _currentStatus = newStatus;
                                request.status = newStatus;
                              });
                              final controller = Get.isRegistered<BloodRequirementController>()
                                  ? Get.find<BloodRequirementController>()
                                  : Get.put(BloodRequirementController());
                              if (request.id != null) {
                                await controller.updateRequirement({
                                  'id': request.id,
                                  'status': newStatus,
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),

                    // Hospital & Location Section
                    _buildSectionHeader(
                      context,
                      title: 'Hospital & Location',
                      icon: Icons.local_hospital_outlined,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailCard(
                      context,
                      children: [
                        _buildDetailRow(
                          context,
                          label: 'Hospital Name',
                          value: request.hospital?.isNotEmpty == true
                              ? request.hospital!
                              : 'Not provided',
                        ),
                        _buildDetailRow(
                          context,
                          label: 'Hospital Address',
                          value: request.hospital?.isNotEmpty == true
                              ? request.hospital!
                              : 'Not provided',
                        ),
                        _buildDetailRow(
                          context,
                          label: 'Patient Address',
                          value: 'Not provided',
                        ),
                        _buildDetailRow(
                          context,
                          label: 'Needed Date',
                          value: _formatDate(request.neededBefore),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Contact Information Section
                    _buildSectionHeader(
                      context,
                      title: 'Contact Information',
                      icon: Icons.contact_phone_outlined,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailCard(
                      context,
                      children: [
                        _buildDetailRow(
                          context,
                          label: 'Contact Person',
                          value: request.contactPerson?.isNotEmpty == true
                              ? request.contactPerson!
                              : 'Not provided',
                        ),
                        _buildDetailRow(
                          context,
                          label: 'Phone Number',
                          value: request.contactNumber?.isNotEmpty == true
                              ? request.contactNumber!
                              : 'Not provided',
                          isActionable: hasValidPhone,
                          trailing: hasValidPhone
                              ? IconButton.filledTonal(
                                  icon: const Icon(Icons.phone, size: 18),
                                  onPressed: () =>
                                      BloodRequirementDetailsSheet.makeCall(
                                        context,
                                        request.contactNumber,
                                      ),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.green.shade100,
                                    foregroundColor: Colors.green.shade900,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Additional Notes
                    if (request.notes?.isNotEmpty == true) ...[
                      _buildSectionHeader(
                        context,
                        title: 'Notes & Instructions',
                        icon: Icons.notes_rounded,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.onPrimary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          request.notes!,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurface.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Timestamps & Audit Info
                    _buildSectionHeader(
                      context,
                      title: 'Audit Information',
                      icon: Icons.history_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailCard(
                      context,
                      children: [
                        _buildDetailRow(
                          context,
                          label: 'Created Date',
                          value: _formatDateTime(request.createdAt),
                        ),
                        if (request.updatedAt != null)
                          _buildDetailRow(
                            context,
                            label: 'Last Updated',
                            value: _formatDateTime(request.updatedAt),
                          ),
                        if (request.createdBy?.isNotEmpty == true)
                          _buildDetailRow(
                            context,
                            label: 'Posted By',
                            value: request.createdBy!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Action Buttons Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border(
                  top: BorderSide(color: cs.outline.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  // Call button
                  if (hasValidPhone)
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Call Contact'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () =>
                            BloodRequirementDetailsSheet.makeCall(
                              context,
                              request.contactNumber,
                            ),
                      ),
                    ),
                  if (hasValidPhone) const SizedBox(width: 10),

                  // Share button
                  Expanded(
                    flex: hasValidPhone ? 1 : 2,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _shareRequirement,
                    ),
                  ),

                  // Admin actions (Edit / Delete)
                  if (isAuthorized) ...[
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit Requirement',
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.to(
                          () => AddBloodRequirementScreen(requirement: request),
                        );
                      },
                    ),
                    if (widget.onDelete != null) ...[
                      const SizedBox(width: 4),
                      IconButton.filledTonal(
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: cs.error,
                        ),
                        tooltip: 'Delete Requirement',
                        style: IconButton.styleFrom(
                          backgroundColor: cs.errorContainer.withOpacity(0.5),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onDelete!();
                        },
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        Text(
          label,
          style: tt.bodySmall?.copyWith(
            color: cs.onSurface.withOpacity(0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required IconData icon,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cs.onPrimary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: cs.outline.withOpacity(0.15),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isActionable = false,
    Widget? trailing,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: tt.bodyMedium?.copyWith(
                fontWeight: isActionable ? FontWeight.bold : FontWeight.w500,
                color: isActionable ? cs.primary : cs.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 8), trailing],
        ],
      ),
    );
  }
}
