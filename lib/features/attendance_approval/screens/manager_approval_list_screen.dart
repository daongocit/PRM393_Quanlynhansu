import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/approval_provider.dart';
import 'manager_approval_detail_screen.dart';
import 'department_attendance_report_screen.dart';

class ManagerApprovalListScreen extends StatefulWidget {
  const ManagerApprovalListScreen({super.key});

  @override
  State<ManagerApprovalListScreen> createState() => _ManagerApprovalListScreenState();
}

class _ManagerApprovalListScreenState extends State<ManagerApprovalListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<ApprovalProvider>(context, listen: false).loadManagerRequests(
          auth.currentUser!.departmentId,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final approvalProv = Provider.of<ApprovalProvider>(context);
    final user = auth.currentUser;

    final pending = approvalProv.pendingRequests;
    final processed = approvalProv.processedRequests;
    final selectedCount = approvalProv.selectedIds.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppHeader(
              title: 'Phê Duyệt Đơn Từ',
              subtitle: 'Quản lý đơn xin nghỉ & giải trình của nhân sự phòng ban',
              actions: [
                IconButton(
                  tooltip: 'Báo cáo chấm công phòng ban',
                  icon: const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DepartmentAttendanceReportScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Chờ phê duyệt'),
                        const SizedBox(width: 8),
                        if (pending.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${pending.length}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Tab(text: 'Đã xử lý (${processed.length})'),
                ],
              ),
            ),

            // Batch Action Bar (ASOFT Standard Feature)
            if (pending.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.primary.withValues(alpha: 0.06),
                child: Row(
                  children: [
                    Text(
                      'Đã chọn: $selectedCount đơn',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        if (selectedCount == pending.length) {
                          approvalProv.clearSelection();
                        } else {
                          approvalProv.selectAllPending();
                        }
                      },
                      child: Text(
                        selectedCount == pending.length ? 'Bỏ chọn' : 'Chọn tất cả',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                      ),
                      onPressed: selectedCount == 0
                          ? null
                          : () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Xác nhận duyệt hàng loạt'),
                                  content: Text(
                                      'Bạn có chắc chắn muốn phê duyệt $selectedCount đơn cùng lúc?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text('Hủy'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Duyệt tất cả'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && user != null) {
                                final isDirector = user.position.toLowerCase().contains('giám đốc') ||
                                    user.email == 'tranhr@company.com' ||
                                    user.departmentId == 2;
                                await approvalProv.approveBatch(
                                  user.id,
                                  isDirector: isDirector,
                                  approverName: user.fullName,
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Đã xử lý phê duyệt $selectedCount đơn!'),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              }
                            },
                      child: const Text('Duyệt hàng loạt', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),

            // Tab View
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: PENDING
                  pending.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline,
                                  size: 48, color: AppColors.success),
                              SizedBox(height: 12),
                              Text('Không có đơn nào đang chờ duyệt!',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: pending.length,
                          itemBuilder: (context, index) {
                            final req = pending[index];
                            final isSelected =
                                req.id != null && approvalProv.selectedIds.contains(req.id!);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ManagerApprovalDetailScreen(request: req),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Checkbox for batch
                                      Checkbox(
                                        value: isSelected,
                                        activeColor: AppColors.primary,
                                        onChanged: (val) {
                                          if (req.id != null) {
                                            approvalProv.toggleSelection(req.id!);
                                          }
                                        },
                                      ),
                                      // User Avatar
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundImage: req.userAvatar != null
                                            ? NetworkImage(req.userAvatar!)
                                            : null,
                                        child: req.userAvatar == null
                                            ? const Icon(Icons.person)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      // Details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  req.userName ?? 'Nhân viên',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                                StatusBadge(status: req.status),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              req.typeDisplay,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: AppColors.primary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              'Thời gian: ${req.fromDate} → ${req.toDate} (${req.totalDays} ngày)',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Lý do: "${req.reason}"',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                  // Tab 2: PROCESSED (APPROVED / REJECTED)
                  processed.isEmpty
                      ? const Center(child: Text('Chưa có lịch sử duyệt đơn.'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: processed.length,
                          itemBuilder: (context, index) {
                            final req = processed[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ManagerApprovalDetailScreen(request: req),
                                    ),
                                  );
                                },
                                leading: CircleAvatar(
                                  backgroundImage: req.userAvatar != null
                                      ? NetworkImage(req.userAvatar!)
                                      : null,
                                  child: req.userAvatar == null
                                      ? const Icon(Icons.person)
                                      : null,
                                ),
                                title: Text(
                                  '${req.userName} - ${req.typeDisplay}',
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  '${req.fromDate} (${req.totalDays} ngày)\nPhản hồi: ${req.managerComment ?? "--"}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: StatusBadge(status: req.status),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
