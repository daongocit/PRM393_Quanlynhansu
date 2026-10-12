import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../providers/attendance_provider.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final attProv = Provider.of<AttendanceProvider>(context);
    final history = attProv.history;

    // Tính toán số liệu thống kê
    final totalDays = history.length;
    final onTimeDays = history.where((a) => a.status == 'ON_TIME').length;
    final lateDays = history.where((a) => a.status == 'LATE').length;
    final totalHours = history.fold<double>(0.0, (sum, a) => sum + a.workHours);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Bảng Chấm Công Cá Nhân'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thống kê nhanh trong tháng
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Ngày đi làm',
                    value: '$totalDays ngày',
                    icon: Icons.calendar_today,
                    iconColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Đúng giờ',
                    value: '$onTimeDays ngày',
                    icon: Icons.check_circle_outline,
                    iconColor: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Đi trễ',
                    value: '$lateDays lần',
                    icon: Icons.timer_outlined,
                    iconColor: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Tổng số giờ làm',
                    value: '${totalHours.toStringAsFixed(1)}h',
                    icon: Icons.schedule,
                    iconColor: AppColors.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Lịch chấm công trực quan TableCalendar
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2026, 1, 1),
                  lastDay: DateTime.utc(2026, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Lịch sử quẹt thẻ chi tiết',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (history.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Chưa có dữ liệu chấm công.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  DateTime? dt;
                  try {
                    dt = DateTime.parse(item.date);
                  } catch (_) {}

                  final formattedDate = dt != null
                      ? DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(dt)
                      : item.date;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: item.status == 'LATE'
                                ? AppColors.errorBg
                                : AppColors.successBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.status == 'LATE'
                                ? Icons.timer_off_outlined
                                : Icons.access_time_filled,
                            color: item.status == 'LATE'
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vào: ${item.checkInTime ?? "--"}  |  Ra: ${item.checkOutTime ?? "--"} (${item.workHours}h)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              if (item.note != null && item.note!.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.note!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontStyle: FontStyle.italic,
                                    color: item.status == 'LATE'
                                        ? AppColors.error
                                        : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        StatusBadge(status: item.status),
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
