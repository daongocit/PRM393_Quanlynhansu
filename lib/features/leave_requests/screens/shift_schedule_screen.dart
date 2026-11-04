import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/leave_request_provider.dart';
import 'create_leave_request_screen.dart';

class ShiftScheduleScreen extends StatelessWidget {
  const ShiftScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaveProv = Provider.of<LeaveRequestProvider>(context);
    final shifts = leaveProv.userShifts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lịch Phân Ca Làm Việc'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.swap_horiz, color: Colors.white),
        label: const Text('Xin đổi ca', style: TextStyle(color: Colors.white)),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const CreateLeaveRequestScreen(initialType: 'SHIFT_SWAP'),
            ),
          );
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thông tin ca chuẩn
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quy định ca làm việc tại công ty:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.wb_sunny_outlined, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('CA01: 08:00 - 17:00 (Ca hành chính chuẩn)',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.nightlight_outlined, size: 16, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text('CA02: 14:00 - 22:00 (Ca chiều / trực hệ thống)',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Lịch làm việc tuần này của bạn',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (shifts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Chưa có lịch phân ca tuần này.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: shifts.length,
                itemBuilder: (context, index) {
                  final s = shifts[index];
                  DateTime? dt;
                  try {
                    dt = DateTime.parse(s.date);
                  } catch (_) {}

                  final dateStr = dt != null
                      ? DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(dt)
                      : s.date;

                  final isNight = s.shiftCode == 'CA02';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        DateTime? dt;
                        try {
                          dt = DateTime.parse(s.date);
                        } catch (_) {}
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateLeaveRequestScreen(
                              initialType: 'SHIFT_SWAP',
                              initialDate: dt,
                              initialReason:
                                  'Xin đổi ca ${s.shiftCode} (${s.shiftName ?? "Ca làm việc"}) ngày ${s.date}',
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isNight
                                    ? AppColors.accent.withValues(alpha: 0.12)
                                    : AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isNight ? Icons.nightlight_round : Icons.wb_sunny,
                                color: isNight ? AppColors.accent : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dateStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${s.shiftName ?? s.shiftCode} (${s.startTime ?? "--"} - ${s.endTime ?? "--"})',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isNight
                                          ? AppColors.accent
                                          : AppColors.primary,
                                    ),
                                  ),
                                  if (s.note != null && s.note!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      s.note!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isNight
                                        ? AppColors.accent.withValues(alpha: 0.1)
                                        : AppColors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    s.shiftCode,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isNight
                                          ? AppColors.accent
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Đổi ca →',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
