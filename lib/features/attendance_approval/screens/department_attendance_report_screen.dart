import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';

class DepartmentAttendanceReportScreen extends StatefulWidget {
  const DepartmentAttendanceReportScreen({super.key});

  @override
  State<DepartmentAttendanceReportScreen> createState() =>
      _DepartmentAttendanceReportScreenState();
}

class _DepartmentAttendanceReportScreenState
    extends State<DepartmentAttendanceReportScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final deptId = auth.currentUser?.departmentId ?? 1;
      final attProv = Provider.of<AttendanceProvider>(context, listen: false);

      // Nếu ngày hiện tại chưa có ai điểm danh, tự động gợi ý ngày dữ liệu mẫu 12/10/2026
      if (attProv.deptTodayAttendance.isEmpty ||
          attProv.deptTodayAttendance.every((a) => a.checkInTime == null)) {
        setState(() => _selectedDate = DateTime(2026, 10, 12));
        attProv.loadDepartmentAttendanceForDate(deptId, '2026-10-12');
      }
    });
  }

  void _changeDate(DateTime newDate) {
    setState(() => _selectedDate = newDate);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final deptId = auth.currentUser?.departmentId ?? 1;
    final dateStr = DateFormat('yyyy-MM-dd').format(newDate);
    Provider.of<AttendanceProvider>(context, listen: false)
        .loadDepartmentAttendanceForDate(deptId, dateStr);
  }

  @override
  Widget build(BuildContext context) {
    final attProv = Provider.of<AttendanceProvider>(context);
    final deptAttendance = attProv.deptTodayAttendance;

    final totalMembers = deptAttendance.length;
    final presentCount = deptAttendance.where((a) => a.checkInTime != null).length;
    final lateCount = deptAttendance.where((a) => a.status == 'LATE').length;
    final absentCount = totalMembers - presentCount;

    final attendanceRate = totalMembers > 0
        ? ((presentCount / totalMembers) * 100).toStringAsFixed(0)
        : '100';

    final selectedDateStr = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final isToday = DateFormat('yyyy-MM-dd').format(_selectedDate) ==
        DateFormat('yyyy-MM-dd').format(DateTime.now());
    final isSampleDate =
        DateFormat('yyyy-MM-dd').format(_selectedDate) == '2026-10-12';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Báo Cáo Chấm Công Phòng Ban'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thanh chuyển đổi ngày báo cáo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Hôm nay'),
                    selected: isToday,
                    onSelected: (val) {
                      if (val) _changeDate(DateTime.now());
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Mẫu (12/10)'),
                    selected: isSampleDate,
                    onSelected: (val) {
                      if (val) _changeDate(DateTime(2026, 10, 12));
                    },
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Chọn ngày báo cáo',
                    icon: const Icon(Icons.calendar_month, color: AppColors.primary),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2026, 1, 1),
                        lastDate: DateTime(2026, 12, 31),
                      );
                      if (picked != null) {
                        _changeDate(picked);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Header Card Thống kê phòng ban
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 10,
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
                      const Text(
                        'Phòng Kỹ thuật IT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          selectedDateStr,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tỷ lệ chuyên cần',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$attendanceRate%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Tổng nhân sự: $totalMembers',
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Đi làm: $presentCount | Vắng: $absentCount',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Stat Cards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Có mặt hôm nay',
                    value: '$presentCount người',
                    icon: Icons.person_pin_circle,
                    iconColor: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Đi trễ',
                    value: '$lateCount người',
                    icon: Icons.access_alarms,
                    iconColor: AppColors.error,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Danh sách điểm danh nhân viên hôm nay',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (deptAttendance.isEmpty)
              const Center(child: Text('Chưa có dữ liệu phòng ban.'))
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: deptAttendance.length,
                itemBuilder: (context, index) {
                  final att = deptAttendance[index];
                  final isPresent = att.checkInTime != null;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundImage: att.userAvatar != null
                              ? NetworkImage(att.userAvatar!)
                              : null,
                          child: att.userAvatar == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                att.userName ?? 'Nhân sự',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isPresent
                                    ? 'Vào: ${att.checkInTime} (${att.shiftCode})'
                                    : 'Chưa điểm danh vào ca',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isPresent
                                      ? AppColors.textSecondary
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          status: isPresent ? att.status : 'ABSENT',
                          customLabel: isPresent ? null : 'Chưa điểm danh',
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
