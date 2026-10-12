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

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final isManager = user?.isManager ?? false;

    // Tabs chính:
    // Tab 0: Chấm công (Duy Ngọc)
    // Tab 1: Quỹ phép & Đơn từ (Uyên)
    // Tab 2: Công việc phòng ban (P.Anh)
    // Tab 3: Phê duyệt (Duy Ngọc - Manager) hoặc Hồ sơ cá nhân
    final List<Widget> pages = [
      const AttendanceCheckInScreen(),
      const LeaveQuotaDashboardScreen(),
      const DepartmentTaskBoardScreen(),
      isManager ? const ManagerApprovalListScreen() : const ProfileScreen(),
    ];

    return Scaffold(
      drawer: _buildAppDrawer(context, auth),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.touch_app_outlined),
            activeIcon: Icon(Icons.touch_app),
            label: 'Chấm công',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'Đơn từ & Phép',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            activeIcon: Icon(Icons.task_alt),
            label: 'Công việc',
          ),
          BottomNavigationBarItem(
            icon: Icon(isManager
                ? Icons.admin_panel_settings_outlined
                : Icons.person_outline),
            activeIcon: Icon(isManager
                ? Icons.admin_panel_settings
                : Icons.person),
            label: isManager ? 'Duyệt đơn' : 'Cá nhân',
          ),
        ],
      ),
    );
  }

  Widget _buildAppDrawer(BuildContext context, AuthProvider auth) {
    final user = auth.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            accountName: Text(
              user?.fullName ?? 'Chưa đăng nhập',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundImage: user?.avatarUrl != null
                  ? NetworkImage(user!.avatarUrl)
                  : null,
              child: user?.avatarUrl == null ? const Icon(Icons.person) : null,
            ),
          ),

          // Role Switcher in Drawer
          ListTile(
            leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
            title: const Text('Chuyển đổi Role / Thành viên'),
            subtitle: Text('Hiện tại: ${user?.fullName} (${user?.role})'),
            trailing: PopupMenuButton<int>(
              icon: const Icon(Icons.arrow_drop_down),
              onSelected: (id) => auth.switchUser(id),
              itemBuilder: (ctx) => auth.availableUsers.map((u) {
                return PopupMenuItem<int>(
                  value: u.id,
                  child: Text('${u.fullName} (${u.role == "MANAGER" ? "Sếp" : "NV"})'),
                );
              }).toList(),
            ),
          ),

          const Divider(),

          // SECTION 1: DUY NGỌC (5 MÀN HÌNH)
          _buildDrawerHeaderSection('THÀNH VIÊN 1: DUY NGỌC (CHẤM CÔNG & DUYỆT)'),
          _buildDrawerItem(
            icon: Icons.fingerprint,
            title: '1. Check-in Chấm công GPS',
            onTap: () {
              Navigator.pop(context);
              setState(() => _currentIndex = 0);
            },
          ),
          _buildDrawerItem(
            icon: Icons.calendar_month,
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
            icon: Icons.approval,
            title: '3. Danh sách Đơn chờ duyệt & Batch',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManagerApprovalListScreen()),
              );
            },
          ),
          _buildDrawerItem(
            icon: Icons.pie_chart,
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
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: color ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color ?? AppColors.textPrimary,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
