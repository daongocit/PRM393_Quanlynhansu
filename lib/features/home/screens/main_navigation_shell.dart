import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/profile_screen.dart';
import '../../auth/screens/login_screen.dart';

// Screens Member 1: Duy Ngọc
import '../../attendance_approval/screens/attendance_checkin_screen.dart';
import '../../attendance_approval/screens/attendance_history_screen.dart';
import '../../attendance_approval/screens/manager_approval_list_screen.dart';
import '../../attendance_approval/screens/department_attendance_report_screen.dart';

// Screens Member 2: Uyên
import '../../leave_requests/screens/leave_quota_dashboard_screen.dart';
import '../../leave_requests/screens/create_leave_request_screen.dart';
import '../../leave_requests/screens/my_leave_requests_screen.dart';
import '../../leave_requests/screens/shift_schedule_screen.dart';

// Screens Member 3: P.Anh
import '../../department_tasks/screens/department_task_board_screen.dart';
import '../../department_tasks/screens/create_or_edit_task_screen.dart';

import '../../../core/models/user_model.dart';
import '../../attendance_approval/providers/attendance_provider.dart';
import '../../attendance_approval/providers/approval_provider.dart';
import '../../leave_requests/providers/leave_request_provider.dart';
import '../../department_tasks/providers/task_provider.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  int? _lastLoadedUserId;

  void _syncUserDataForUser(User user) {
    _lastLoadedUserId = user.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Provider.of<AttendanceProvider>(context, listen: false)
          .loadUserAttendance(user.id, user.departmentId);
      Provider.of<LeaveRequestProvider>(context, listen: false)
          .loadUserData(user);
      Provider.of<TaskProvider>(context, listen: false)
          .loadDepartmentTasks(user.departmentId);
      if (user.isManager) {
        Provider.of<ApprovalProvider>(context, listen: false)
            .loadManagerRequests(user.departmentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isManager = user?.isManager ?? false;

    // Tự động đồng bộ lại toàn bộ 4 Provider khi chuyển đổi vai trò / thành viên
    if (user != null && user.id != _lastLoadedUserId) {
      _syncUserDataForUser(user);
    }

    // Tabs chính:
    // Tab 0: Chấm công (Duy Ngọc)
    // Tab 1: Quỹ phép & Đơn từ (Uyên)
    // Tab 2: Công việc phòng ban (P.Anh)
    // Tab 3: Phê duyệt (Duy Ngọc - Manager) hoặc Hồ sơ cá nhân
    final List<Widget> pages = [
      AttendanceCheckInScreen(key: ValueKey('att_${user?.id}')),
      LeaveQuotaDashboardScreen(key: ValueKey('leave_${user?.id}')),
      DepartmentTaskBoardScreen(key: ValueKey('task_${user?.departmentId}')),
      isManager
          ? ManagerApprovalListScreen(key: ValueKey('approval_${user?.id}'))
          : ProfileScreen(key: ValueKey('profile_${user?.id}')),
    ];

    return Scaffold(
      drawer: _buildAppDrawer(context, auth),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          border: const Border(top: BorderSide(color: AppColors.cardBorder, width: 1)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textMuted,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.fingerprint_rounded),
                activeIcon: Icon(Icons.fingerprint_rounded),
                label: 'Chấm công',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.date_range_outlined),
                activeIcon: Icon(Icons.date_range_rounded),
                label: 'Đơn từ & Phép',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.task_alt_outlined),
                activeIcon: Icon(Icons.task_alt_rounded),
                label: 'Công việc',
              ),
              BottomNavigationBarItem(
                icon: Icon(isManager
                    ? Icons.admin_panel_settings_outlined
                    : Icons.person_outline_rounded),
                activeIcon: Icon(isManager
                    ? Icons.admin_panel_settings_rounded
                    : Icons.person_rounded),
                label: isManager ? 'Duyệt đơn' : 'Cá nhân',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;
    final isManager = user?.isManager ?? false;

    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header with Premium Gradient
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: AppColors.darkHeroGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isManager ? const Color(0xFFFBBF24) : AppColors.primaryLight,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundImage: user?.avatarUrl != null && user!.avatarUrl.isNotEmpty
                            ? NetworkImage(user.avatarUrl)
                            : null,
                        backgroundColor: Colors.white24,
                        child: user?.avatarUrl == null ? const Icon(Icons.person, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.fullName ?? 'Chưa đăng nhập',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.5,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.position ?? 'Nhân sự',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isManager ? Icons.shield_rounded : Icons.badge_rounded,
                        color: isManager ? const Color(0xFFFBBF24) : Colors.white,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isManager ? 'VAI TRÒ: QUẢN LÝ (MANAGER)' : 'VAI TRÒ: NHÂN VIÊN (EMPLOYEE)',
                        style: TextStyle(
                          color: isManager ? const Color(0xFFFDE68A) : Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Role Switcher in Drawer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 18),
                ),
                title: const Text(
                  'Chuyển đổi Role / Demo',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Đang chọn: ${user?.fullName}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                trailing: PopupMenuButton<int>(
                  icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppColors.primary, size: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  onSelected: (id) => auth.switchUser(id),
                  itemBuilder: (ctx) => auth.availableUsers.map((u) {
                    final isCur = u.id == user?.id;
                    return PopupMenuItem<int>(
                      value: u.id,
                      child: Text(
                        u.fullName.contains('Hoàng Nam')
                            ? '${u.fullName} (NV - 2 năm thâm niên)'
                            : (u.fullName == 'Uyên'
                                ? '${u.fullName} (NV - 3 tháng)'
                                : '${u.fullName} (${u.role == "MANAGER" ? "Quản lý" : "NV"})'),
                        style: TextStyle(
                          fontWeight: isCur ? FontWeight.w800 : FontWeight.w500,
                          color: isCur ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 20),
          ),

          // SECTION 1: DUY NGỌC (5 MÀN HÌNH)
          _buildDrawerHeaderSection('THÀNH VIÊN 1: DUY NGỌC (CHẤM CÔNG & DUYỆT)'),
          _buildDrawerItem(
            icon: Icons.fingerprint_rounded,
            title: '1. Check-in Chấm công GPS',
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
          ),
          _buildDrawerItem(
            icon: Icons.calendar_month_rounded,
            title: '2. Bảng chấm công & Lịch sử tháng',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AttendanceHistoryScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.approval_rounded,
            title: '3. Danh sách Đơn chờ duyệt & Batch',
            subtitle: 'Bấm vào đơn để sang Màn 4: Thẩm định & Phê duyệt',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagerApprovalListScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.pie_chart_rounded,
            title: '5. Báo cáo chấm công phòng ban',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const DepartmentAttendanceReportScreen()),
              );
            },
          ),

          const Divider(),

          // SECTION 2: UYÊN (5 MÀN HÌNH)
          _buildDrawerHeaderSection('THÀNH VIÊN 2: UYÊN (ĐƠN TỪ & QUỸ PHÉP)'),
          _buildDrawerItem(
            icon: Icons.dashboard_outlined,
            title: '6. Dashboard Quỹ phép (Business Rule)',
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 1);
            },
          ),
          _buildDrawerItem(
            icon: Icons.post_add,
            title: '7. Lập đơn xin nghỉ & Validate Quota',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateLeaveRequestScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.list_alt,
            title: '8. Danh sách Đơn từ cá nhân',
            subtitle: 'Bấm vào đơn để sang Màn 9: Chi tiết & Timeline duyệt',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyLeaveRequestsScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.schedule_send,
            title: '10. Đăng ký Ca làm việc CA01/CA02',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ShiftScheduleScreen()),
              );
            },
          ),

          const Divider(),

          // SECTION 3: P.ANH (5 MÀN HÌNH)
          _buildDrawerHeaderSection('THÀNH VIÊN 3: P.ANH (CÔNG VIỆC & TASK)'),
          _buildDrawerItem(
            icon: Icons.view_kanban_outlined,
            title: '11. Bảng công việc phòng ban (Kanban)',
            subtitle: 'Bấm vào task để sang Màn 13: Tiến độ, Màn 14: Thảo luận, Màn 15: Nhắc nhở',
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 2);
            },
          ),
          _buildDrawerItem(
            icon: Icons.add_task,
            title: '12. Giao việc & Đặt Deadline',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateOrEditTaskScreen()),
              );
            },
          ),

          const Divider(),

          _buildDrawerItem(
            icon: Icons.account_circle_outlined,
            title: 'Hồ sơ cá nhân Profile',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Đăng xuất',
            color: AppColors.error,
            onTap: () {
              auth.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeaderSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1.5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color ?? AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textPrimary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              )
            : null,
        onTap: onTap,
        dense: true,
      ),
    );
  }
}
