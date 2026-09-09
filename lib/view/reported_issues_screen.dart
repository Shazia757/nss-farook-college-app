import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/common_pages/navbar.dart';
import 'package:nss_new/controller/issues_controller.dart';
import 'package:nss_new/database/local_storage.dart';
import 'package:nss_new/model/issues_model.dart';

class ReportedIssuesScreen extends StatelessWidget {
  const ReportedIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final IssuesController c = Get.put(IssuesController());
    final role = LocalStorage().readUser().role;

    // Call getAdminIssues to load all tickets reported to PO/Secretary
    c.getAdminIssues();

    return Scaffold(
      backgroundColor: cs.surface,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: role == 'po' ? 2 : 3,
      ),
      body: SafeArea(
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingIssues = c.modifiedOpenedList;
          final resolvedIssues = c.modifiedClosedList;

          return RefreshIndicator(
            onRefresh: () async {
              await c.getAdminIssues();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resolve Issues',
                      style: tt.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track and resolve reported campus issues.',
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;

                        if (isWide) {
                          return Row(
                            children: [
                              Expanded(
                                child: CustomWidgets().buildSummaryCard(
                                  context,
                                  title: "Total Pending",
                                  value: pendingIssues.length.toString(),
                                  icon: Icons.pending_actions_rounded,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomWidgets().buildSummaryCard(
                                  context,
                                  title: "Total Resolved",
                                  value: resolvedIssues.length.toString(),
                                  icon: Icons.task_alt_rounded,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          );
                        }

                        return Column(
                          children: [
                            CustomWidgets().buildSummaryCard(
                              context,
                              title: "Total Pending",
                              value: pendingIssues.length.toString(),
                              icon: Icons.pending_actions_rounded,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 12),
                            CustomWidgets().buildSummaryCard(
                              context,
                              title: "Total Resolved",
                              value: resolvedIssues.length.toString(),
                              icon: Icons.task_alt_rounded,
                              color: Colors.green,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    Text(
                      'Pending Issues',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (pendingIssues.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No issues reported',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 900
                              ? 3
                              : constraints.maxWidth > 600
                              ? 2
                              : 1;
                          return MasonryGridView.count(
                            crossAxisCount: crossAxisCount,
                            shrinkWrap: true,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pendingIssues.length,
                            itemBuilder: (context, index) {
                              final issue = pendingIssues[index];
                              return _buildPendingIssueCard(
                                context,
                                issue,
                                c,
                                cs,
                                tt,
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 24),

                    Text(
                      'Resolved Issues',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (resolvedIssues.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            'No issues resolved',
                            style: tt.bodyMedium?.copyWith(
                              color: cs.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ),
                      )
                    else
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 900
                              ? 3
                              : constraints.maxWidth > 600
                              ? 2
                              : 1;
                          return MasonryGridView.count(
                            crossAxisCount: crossAxisCount,
                            shrinkWrap: true,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: resolvedIssues.length,
                            itemBuilder: (context, index) {
                              final issue = resolvedIssues[index];
                              return _buildResolvedIssueCard(
                                context,
                                issue,
                                cs,
                                tt,
                              );
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPendingIssueCard(
    BuildContext context,
    Issues issue,
    IssuesController controller,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final dateStr = issue.createdDate != null
        ? DateFormat.yMMMd().format(issue.createdDate!)
        : 'N/A';

    return Container(
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "PENDING",
                  style: tt.labelSmall?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: cs.onSurface.withOpacity(0.45),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            issue.subject ?? 'General Issue',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            issue.description ?? '',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.7),
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Divider(color: cs.outline.withOpacity(0.2), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: cs.primary.withOpacity(0.1),
                child: Text(
                  (issue.createdBy?.name ?? 'U').substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.createdBy?.name ?? '',
                      style: tt.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      'Admission No: ${issue.createdBy?.admissionNo ?? 'N/A'}',
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showIssueDetailsDialog(context, issue, tt);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: BorderSide(color: cs.outline.withOpacity(0.5)),
                  ),
                  child: Text(
                    "View Details",
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
                    _showResolveConfirmationDialog(context, issue, controller);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Resolve",
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
    );
  }

  void _showResolveConfirmationDialog(
    BuildContext context,
    Issues issue,
    IssuesController controller,
  ) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Confirm Resolved"),
        content: Text(
          "Are you sure you have resolved \"${issue.subject ?? 'this issue'}\"?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: cs.onSurface.withOpacity(0.6)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.resolveIssue(issue.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Obx(
              () => controller.isResolveLoading.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResolvedIssueCard(
    BuildContext context,
    Issues issue,
    ColorScheme cs,
    TextTheme tt,
  ) {
    final dateStr = issue.createdDate != null
        ? DateFormat.yMMMd().format(issue.createdDate!)
        : 'N/A';
    final resDateStr = issue.updatedDate != null
        ? DateFormat.yMMMd().format(issue.updatedDate!)
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.onSurface.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "RESOLVED",
                  style: tt.labelSmall?.copyWith(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 13,
                    color: cs.onSurface.withOpacity(0.45),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            issue.subject ?? 'General Issue',
            style: tt.titleMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            issue.description ?? '',
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurface.withOpacity(0.6),
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.green.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Resolved on $resDateStr',
                    style: tt.bodySmall?.copyWith(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: cs.outline.withOpacity(0.15), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: cs.onSurface.withOpacity(0.1),
                      child: Text(
                        (issue.createdBy?.name ?? 'U')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'By: ${issue.updatedBy ?? ''}',
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.6),
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _showIssueDetailsDialog(context, issue, tt);
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "View Details",
                  style: tt.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showIssueDetailsDialog(
    BuildContext context,
    Issues issue,
    TextTheme tt,
  ) {
    final dateStr = issue.createdDate != null
        ? DateFormat.yMMMd().format(issue.createdDate!)
        : 'N/A';
    final resDateStr = issue.updatedDate != null
        ? DateFormat.yMMMd().format(issue.updatedDate!)
        : 'N/A';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          issue.subject ?? 'Issue Details',
          style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogDetailRow(
                'Status',
                issue.isOpen ?? true ? 'Pending' : 'Resolved',
                isStatus: true,
              ),
              const SizedBox(height: 8),
              _buildDialogDetailRow(
                'Reported By',
                issue.createdBy?.name ?? 'N/A',
              ),
              const SizedBox(height: 4),
              _buildDialogDetailRow(
                'Admission No',
                issue.createdBy?.admissionNo ?? 'N/A',
              ),
              const SizedBox(height: 4),
              _buildDialogDetailRow('Reported On', dateStr),
              const SizedBox(height: 4),
              _buildDialogDetailRow(
                'Reported To',
                issue.to == 'sec' ? 'Secretary' : 'Program Officer',
              ),
              if (issue.updatedBy != null && issue.isOpen == false) ...[
                const SizedBox(height: 4),
                _buildDialogDetailRow('Resolved On', resDateStr),
              ],
              const Divider(height: 24),
              Text(
                'Description',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                issue.description ?? '',
                style: tt.bodyMedium?.copyWith(height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogDetailRow(
    String label,
    String value, {
    bool isStatus = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isStatus
                  ? (value == 'Resolved' ? Colors.green : Colors.orange)
                  : null,
              fontWeight: isStatus ? FontWeight.bold : null,
            ),
          ),
        ),
      ],
    );
  }
}
