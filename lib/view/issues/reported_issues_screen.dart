import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';
import 'package:nss_new/common_pages/navbar.dart';
import 'package:nss_new/controller/issues_controller.dart';
import 'package:nss_new/model/issues_model.dart';

class ReportedIssuesScreen extends StatefulWidget {
  const ReportedIssuesScreen({super.key});

  @override
  State<ReportedIssuesScreen> createState() => _ReportedIssuesScreenState();
}

class _ReportedIssuesScreenState extends State<ReportedIssuesScreen> {
  late final IssuesController c;

  @override
  void initState() {
    super.initState();
    c = Get.isRegistered<IssuesController>()
        ? Get.find<IssuesController>()
        : Get.put(IssuesController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      c.getAdminIssues();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: cs.surface,
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex:  3,
      ),
      body: SafeArea(
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final pendingIssues = c.modifiedOpenedList;
          final resolvedIssues = c.modifiedClosedList;

          final totalPending = c.openedList.length;
          final totalResolved = c.closedList.length;

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
                                  value: totalPending.toString(),
                                  icon: Icons.pending_actions_rounded,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomWidgets().buildSummaryCard(
                                  context,
                                  title: "Total Resolved",
                                  value: totalResolved.toString(),
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
                              value: totalPending.toString(),
                              icon: Icons.pending_actions_rounded,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 12),
                            CustomWidgets().buildSummaryCard(
                              context,
                              title: "Total Resolved",
                              value: totalResolved.toString(),
                              icon: Icons.task_alt_rounded,
                              color: Colors.green,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending Issues',
                              style: tt.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.primary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Filter by reported to :',
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ],
                    ),

                    // Filter by Reported-To Role: All / Secretary / Program Officer
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildRoleFilterChip(
                            context: context,
                            label: 'All',
                            value: 'all',
                            isSelected:
                                c.reportedTo.value == 'all' ||
                                c.reportedTo.value == 'both',
                            onSelected: () => c.filterByRole('all'),
                            icon: Icons.all_inclusive_rounded,
                            count: c.openedList.length,
                          ),
                          const SizedBox(width: 8),
                          _buildRoleFilterChip(
                            context: context,
                            label: 'Program Officer',
                            value: 'po',
                            isSelected: c.reportedTo.value == 'po',
                            onSelected: () => c.filterByRole('po'),
                            icon: Icons.school_outlined,
                            count: c.openedList
                                .where(
                                  (i) =>
                                      (i.to ?? '').toLowerCase() == 'po' ||
                                      (i.to ?? '').toLowerCase() ==
                                          'program officer' ||
                                      (i.to ?? '').toLowerCase() ==
                                          'program_officer',
                                )
                                .length,
                          ),

                          const SizedBox(width: 8),
                          _buildRoleFilterChip(
                            context: context,
                            label: 'Secretary',
                            value: 'sec',
                            isSelected: c.reportedTo.value == 'sec',
                            onSelected: () => c.filterByRole('sec'),
                            icon: Icons.badge_outlined,
                            count: c.openedList
                                .where(
                                  (i) =>
                                      (i.to ?? '').toLowerCase() == 'sec' ||
                                      (i.to ?? '').toLowerCase() == 'secretary',
                                )
                                .length,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (pendingIssues.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: cs.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                c.reportedTo.value == 'sec'
                                    ? 'No pending issues reported to Secretary'
                                    : c.reportedTo.value == 'po'
                                    ? 'No pending issues reported to Program Officer'
                                    : 'No pending issues reported',
                                style: tt.bodyMedium?.copyWith(
                                  color: cs.onSurface.withOpacity(0.5),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (c.reportedTo.value != 'all' &&
                                  c.reportedTo.value != 'both') ...[
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () => c.filterByRole('all'),
                                  child: const Text('Show All Issues'),
                                ),
                              ],
                            ],
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
                    _showIssueDetailsDialog(
                      context,
                      issue,
                      tt,
                      controller: controller,
                    );
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
      barrierDismissible: false,
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

  Widget _buildRoleFilterChip({
    required BuildContext context,
    required String label,
    required String value,
    required bool isSelected,
    required VoidCallback onSelected,
    required IconData icon,
    int? count,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? cs.onPrimary : cs.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: tt.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? cs.onPrimary : cs.onSurface,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cs.onPrimary.withOpacity(0.25)
                      : cs.outline.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$count',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                    color: isSelected
                        ? cs.onPrimary
                        : cs.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showIssueDetailsDialog(
    BuildContext context,
    Issues issue,
    TextTheme tt, {
    IssuesController? controller,
  }) {
    final cs = Theme.of(context).colorScheme;
    final dateStr = issue.createdDate != null
        ? DateFormat('d MMM yyyy, h:mm a').format(issue.createdDate!)
        : 'N/A';
    final resDateStr = issue.updatedDate != null
        ? DateFormat('d MMM yyyy, h:mm a').format(issue.updatedDate!)
        : null;

    final isPending = issue.isOpen ?? true;
    final reportedToName =
        (issue.to?.toLowerCase() == 'sec' ||
            issue.to?.toLowerCase() == 'secretary')
        ? 'Secretary'
        : 'Program Officer';

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: cs.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: cs.outline.withOpacity(0.15)),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPending
                            ? Colors.amber.shade50
                            : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isPending
                              ? Colors.amber.shade200
                              : Colors.green.shade200,
                        ),
                      ),
                      child: Icon(
                        isPending
                            ? Icons.hourglass_top_rounded
                            : Icons.task_alt_rounded,
                        size: 22,
                        color: isPending
                            ? Colors.amber.shade900
                            : Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            issue.subject?.isNotEmpty == true
                                ? issue.subject!
                                : 'General Query',
                            style: tt.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? Colors.amber.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isPending ? 'PENDING' : 'RESOLVED',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: isPending
                                    ? Colors.amber.shade900
                                    : Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
              ),

              // Content Body
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Metadata Info Box
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.onPrimary,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.18),
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildInfoTile(
                              context,
                              icon:
                                  (issue.to?.toLowerCase() == 'sec' ||
                                      issue.to?.toLowerCase() == 'secretary')
                                  ? Icons.badge_outlined
                                  : Icons.school_outlined,
                              label: 'Reported To',
                              value: reportedToName,
                            ),
                            const Divider(height: 16),
                            _buildInfoTile(
                              context,
                              icon: Icons.person_outline_rounded,
                              label: 'Reported By',
                              value:
                                  issue.createdBy?.name ??
                                  issue.createdByName ??
                                  'Volunteer',
                              subtitle: issue.createdBy?.admissionNo != null
                                  ? 'Admission No: ${issue.createdBy!.admissionNo}'
                                  : null,
                            ),
                            const Divider(height: 16),
                            _buildInfoTile(
                              context,
                              icon: Icons.calendar_today_outlined,
                              label: 'Reported Date',
                              value: dateStr,
                            ),
                            if (!isPending) ...[
                              const Divider(height: 16),
                              _buildInfoTile(
                                context,
                                icon: Icons.verified_user_outlined,
                                label: 'Resolved By',
                                value: issue.updatedBy ?? 'Admin',
                                subtitle: resDateStr != null
                                    ? 'On: $resDateStr'
                                    : null,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Description Section
                      Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 16,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Description',
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: cs.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 80),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: cs.outline.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outline.withOpacity(0.15),
                          ),
                        ),
                        child: Text(
                          issue.description?.isNotEmpty == true
                              ? issue.description!
                              : 'No description provided.',
                          style: tt.bodyMedium?.copyWith(
                            height: 1.5,
                            color: cs.onSurface.withOpacity(0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: cs.outline.withOpacity(0.15)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          side: BorderSide(color: cs.outline.withOpacity(0.4)),
                        ),
                        child: Text(
                          'Close',
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                    if (isPending &&
                        controller != null &&
                        issue.id != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.pop(dialogCtx);
                            _showResolveConfirmationDialog(
                              context,
                              issue,
                              controller,
                            );
                          },
                          icon: const Icon(
                            Icons.check_circle_outline,
                            size: 18,
                          ),
                          label: const Text('Resolve Issue'),
                          style: FilledButton.styleFrom(
                            backgroundColor: cs.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: cs.primary.withOpacity(0.8)),
        const SizedBox(width: 10),
        SizedBox(
          width: 95,
          child: Text(
            label,
            style: tt.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: tt.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurface.withOpacity(0.55),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
