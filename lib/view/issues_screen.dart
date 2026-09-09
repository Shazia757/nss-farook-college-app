import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nss_new/common_pages/navbar.dart';
import 'package:nss_new/controller/issues_controller.dart';
import 'package:nss_new/model/issues_model.dart';
import 'package:nss_new/view/home_screen.dart';
import 'package:nss_new/common_pages/custom_decorations.dart';

class IssuesScreen extends StatefulWidget {
  const IssuesScreen({super.key});

  @override
  State<IssuesScreen> createState() => _IssuesScreenState();
}

class _IssuesScreenState extends State<IssuesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final IssuesController c = Get.put(IssuesController());
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Combine open and closed issues for volunteer view
        final allIssues = [
          ...c.modifiedOpenedList.map((e) => {'issue': e, 'resolved': false}),
          ...c.modifiedClosedList.map((e) => {'issue': e, 'resolved': true}),
        ];

        // Filter reported issues based on search query
        final filteredIssues = allIssues.where((item) {
          final issue = item['issue'] as Issues;

          final titleMatch =
              issue.subject?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false;

          final descMatch =
              issue.description?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false;

          return titleMatch || descMatch;
        }).toList();

        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Navigation & Search Bar
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
                            },
                            decoration: InputDecoration(
                              hintText: 'Search issues...',
                              hintStyle: tt.bodyMedium?.copyWith(
                                color: cs.onSurface.withOpacity(0.5),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: cs.onSurface.withOpacity(0.6),
                                size: 20,
                              ),
                              suffixIcon: _searchQuery.isNotEmpty
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
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                            style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title and Subtitle Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support Center',
                        style: tt.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Report new issues or track the status of existing issues.',
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Report New Issue Form Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.onPrimary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outline.withOpacity(0.6)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report New Issue',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Issue Type',
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Issue Type Dropdown
                        DropdownButtonFormField<String>(
                          value: c.subjectController.text.isNotEmpty
                              ? c.subjectController.text
                              : 'Attendance discrepancy',
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: cs.surface,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: cs.outline.withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: cs.outline.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: cs.primary),
                            ),
                          ),
                          dropdownColor: cs.surface,
                          items:
                              [
                                    'Attendance discrepancy',
                                    'Event registration error',
                                    'App/Technical issue',
                                    'General query',
                                  ]
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type, style: tt.bodyMedium),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              c.subjectController.text = val;
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Description',
                          style: tt.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.primary,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Description text field
                        TextField(
                          controller: c.desController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: cs.surface,
                            hintText: 'Describe the issue...',
                            hintStyle: tt.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.4),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: cs.outline.withOpacity(0.5),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: cs.outline.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: cs.primary),
                            ),
                          ),
                          style: tt.bodyMedium,
                        ),
                        const SizedBox(height: 16),

                        // Send to (Secretary or Program Officer) choice chips
                        Row(
                          children: [
                            Text(
                              'Send to: ',
                              style: tt.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildSendToChip('Secretary', 'sec'),
                            const SizedBox(width: 8),
                            _buildSendToChip('Program Officer', 'po'),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: () {
                              if (c.subjectController.text.isEmpty) {
                                c.subjectController.text =
                                    'Attendance discrepancy';
                              }
                              if (c.onSubmitIssueValidation()) {
                                CustomWidgets().showConfirmationDialog(
                                  title: "Report Issue",
                                  message:
                                      "Are you sure you want to report the issue?",
                                  onConfirm: () => c.reportIssue(),
                                  data: Obx(
                                    () => (c.isReportLoading.value)
                                        ? CircularProgressIndicator()
                                        : Text(
                                            "Confirm",
                                            style: TextStyle(color: Colors.red),
                                          ),
                                  ),
                                );
                              }
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: cs.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: c.isReportLoading.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Submit Report',
                                    style: tt.labelLarge?.copyWith(
                                      color: cs.onSecondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // My Reported Issues Section Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'My Reported Issues',
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (filteredIssues.isEmpty)
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
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredIssues.length,
                    itemBuilder: (context, index) {
                      final item = filteredIssues[index];
                      final issue = item['issue'] as Issues;
                      final dateStr = issue.createdDate != null
                          ? DateFormat.yMMMd().format(issue.createdDate!)
                          : 'N/A';

                      return _buildReportedIssueCard(
                        context: context,
                        title: issue.subject ?? 'General query',
                        description: issue.description ?? '',
                        date: dateStr,
                        reportedTo: issue.to == 'sec'
                            ? 'Secretary'
                            : 'Program Officer',
                        isOpen: issue.isOpen ?? false,
                        cs: cs,
                        tt: tt,
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSendToChip(String roleLabel, String roleVal) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isSelected = c.submittedTo.value == roleVal;

    return ChoiceChip(
      showCheckmark: false,
      label: Text(roleLabel),
      selected: isSelected,
      labelStyle: tt.bodySmall?.copyWith(
        color: isSelected ? cs.onPrimary : cs.onSurface,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      selectedColor: cs.primary,
      backgroundColor: cs.outline.withOpacity(0.12),
      side: BorderSide(
        color: isSelected ? Colors.transparent : cs.outline,
        width: 1,
      ),
      onSelected: (selected) {
        if (selected) {
          c.submittedTo.value = roleVal;
        }
      },
    );
  }

  Widget _buildReportedIssueCard({
    required BuildContext context,
    required String title,
    required String description,
    required String date,
    required String reportedTo,
    required bool isOpen,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    final status = isOpen ? 'Open' : 'Closed';
    final statusColor = isOpen ? Colors.orange.shade700 : Colors.green.shade700;

    final statusBg = isOpen ? Colors.orange.shade50 : Colors.green.shade50;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.onPrimary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: tt.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Description (One Line)
          Text(
            description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 10),

          // Footer (Date, Recipient, View Details)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: cs.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: tt.bodySmall?.copyWith(
                        fontSize: 10,
                        color: cs.onSurface.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.person_outline,
                      size: 12,
                      color: cs.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'To: $reportedTo',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tt.bodySmall?.copyWith(
                          fontSize: 10,
                          color: cs.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        title,
                        style: tt.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Status: ',
                                style: tt.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: tt.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Reported on: $date', style: tt.bodySmall),
                          const SizedBox(height: 4),
                          Text('Sent to: $reportedTo', style: tt.bodySmall),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          Text(description, style: tt.bodyMedium),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  children: [
                    Text(
                      'View Details',
                      style: tt.labelSmall?.copyWith(
                        color: cs.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 14, color: cs.primary),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
