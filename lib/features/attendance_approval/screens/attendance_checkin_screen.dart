import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../../leave_requests/screens/create_leave_request_screen.dart';
import 'attendance_history_screen.dart';

class AttendanceCheckInScreen extends StatefulWidget {
  const AttendanceCheckInScreen({super.key});

  @override
  State<AttendanceCheckInScreen> createState() => _AttendanceCheckInScreenState();
}

class _AttendanceCheckInScreenState extends State<AttendanceCheckInScreen> {
  late Timer _timer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<AttendanceProvider>(context, listen: false).loadUserAttendance(
          auth.currentUser!.id,
          auth.currentUser!.departmentId,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;
    final attProv = Provider.of<AttendanceProvider>(context);
    final todayAtt = attProv.todayAttendance;

    final isCheckedIn = todayAtt?.checkInTime != null;
    final isCheckedOut = todayAtt?.checkOutTime != null;

    final timeString = DateFormat('HH:mm:ss').format(_currentTime);
    final dateString = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(_currentTime);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppHeader(
              title: 'Chấm Công & Điểm Danh',
              subtitle: 'Ca CA01: 08:00 - 17:00 (Hành chính)',
              actions: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: IconButton(
                    tooltip: 'Xem lịch sử chấm công',
                    icon: const Icon(Icons.history_rounded, color: AppColors.primary, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AttendanceHistoryScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Cảnh báo Business Rule nếu đi trễ
                    if (todayAtt?.status == 'LATE') ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.errorBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded,
                                color: AppColors.error, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Cảnh báo: Đi trễ sau 08:15',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Hệ thống ghi nhận bạn vào sau 08:15. Vui lòng nộp đơn giải trình để không bị trừ công.',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      minimumSize: Size.zero,
                                    ),
                                    icon: const Icon(Icons.edit_document, size: 14),
                                    label: const Text('Lập đơn giải trình ngay',
                                        style: TextStyle(fontSize: 12)),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CreateLeaveRequestScreen(
                                            initialType: 'LATE_EXPLANATION',
                                            initialDate: _currentTime,
                                            initialReason:
                                                'Giải trình đi trễ ngày ${DateFormat('dd/MM/yyyy').format(_currentTime)}: ',
                                          ),
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
                      const SizedBox(height: 20),
                    ],

                    // Digital Clock Card
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 22),
                      decoration: BoxDecoration(
                        gradient: AppColors.darkHeroGradient,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.35),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: AppColors.primaryLight.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dateString.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            timeString,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  color: Color(0xFF34D399), size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Văn phòng Tầng 8, Tòa nhà FPT, Cầu Giấy',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Check-in / Check-out Button
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          if (user == null) return;
                          if (!isCheckedIn) {
                            await attProv.checkIn(user.id, 'CA01');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Điểm danh Check-in thành công!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } else if (!isCheckedOut) {
                            await attProv.checkOut();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Điểm danh Check-out thành công!'),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Hôm nay bạn đã hoàn thành ca làm việc!'),
                              ),
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: isCheckedOut
                                ? const LinearGradient(
                                    colors: [Colors.grey, Colors.blueGrey])
                                : (!isCheckedIn
                                    ? const LinearGradient(colors: [
                                        Color(0xFF0D9488),
                                        Color(0xFF14B8A6)
                                      ])
                                    : const LinearGradient(colors: [
                                        Color(0xFF1E3A8A),
                                        Color(0xFF3B82F6)
                                      ])),
                            boxShadow: [
                              BoxShadow(
                                color: (isCheckedOut
                                        ? Colors.grey
                                        : (!isCheckedIn
                                            ? AppColors.secondary
                                            : AppColors.primary))
                                    .withValues(alpha: 0.35),
                                blurRadius: 24,
                                spreadRadius: 4,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isCheckedOut
                                    ? Icons.done_all
                                    : (!isCheckedIn
                                        ? Icons.touch_app
                                        : Icons.exit_to_app),
                                color: Colors.white,
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isCheckedOut
                                    ? 'ĐÃ HOÀN THÀNH'
                                    : (!isCheckedIn ? 'CHECK IN' : 'CHECK OUT'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                isCheckedOut
                                    ? 'Ca CA01'
                                    : (!isCheckedIn ? 'Vào ca' : 'Kết thúc ca'),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Attendance Status Detail Cards
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.login,
                                        size: 16, color: AppColors.secondary),
                                    SizedBox(width: 6),
                                    Text(
                                      'Giờ vào ca',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  todayAtt?.checkInTime ?? '--:--',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                if (todayAtt != null)
                                  StatusBadge(status: todayAtt.status)
                                else
                                  const Text('Chưa quẹt thẻ',
                                      style: TextStyle(
                                          fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.logout,
                                        size: 16, color: AppColors.primaryLight),
                                    SizedBox(width: 6),
                                    Text(
                                      'Giờ ra ca',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  todayAtt?.checkOutTime ?? '--:--',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tổng: ${todayAtt?.workHours ?? 0.0} giờ',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
