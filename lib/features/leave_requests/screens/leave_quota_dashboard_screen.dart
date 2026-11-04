import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_app_header.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/leave_request_provider.dart';
import 'create_leave_request_screen.dart';
import 'my_leave_requests_screen.dart';
import 'leave_request_detail_screen.dart';
import 'shift_schedule_screen.dart';

class LeaveQuotaDashboardScreen extends StatefulWidget {
  const LeaveQuotaDashboardScreen({super.key});

  @override
  State<LeaveQuotaDashboardScreen> createState() =>
      _LeaveQuotaDashboardScreenState();
}

class _LeaveQuotaDashboardScreenState extends State<LeaveQuotaDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser != null) {
        Provider.of<LeaveRequestProvider>(context, listen: false)
            .loadUserData(auth.currentUser!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final leaveProv = Provider.of<LeaveRequestProvider>(context);
    final balance = leaveProv.balance;

    final tenureMonths = balance?.tenureMonths ?? 3;
    final accruedDays = balance?.accruedDays ?? 3.0;
    final usedDays = balance?.usedDays ?? 2.0;
    final remainingDays = balance?.remainingDays ?? 1.0;
    final pendingDays = balance?.pendingDays ?? 0.0;
    final seniorityBonusDays = balance?.seniorityBonusDays ?? 0;

    final double quotaPercent = accruedDays > 0
        ? ((remainingDays / accruedDays) * 100).clamp(0.0, 100.0)
        : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppHeader(
              title: 'Quản Lý Quỹ Phép & Đơn Từ',
              subtitle: 'Theo dõi hạn mức phép năm theo thâm niên & nộp đơn trực tuyến',
              actions: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: IconButton(
                    tooltip: 'Xem danh sách toàn bộ đơn cá nhân',
                    icon: const Icon(Icons.list_alt_rounded, color: AppColors.primary, size: 20),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyLeaveRequestsScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // THẺ QUỸ PHÉP THÔNG MINH (BUSINESS RULE CHÍNH TỪ ĐỀ BÀI)
                    Container(
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
                      child: Stack(
                        children: [
                          // Ambient decorative glowing circles
                          Positioned(
                            right: -30,
                            top: -30,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primaryLight.withValues(alpha: 0.12),
                              ),
                            ),
                          ),
                          Positioned(
                            left: -20,
                            bottom: -20,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header: Title & Tenure pill
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(Icons.workspace_premium_rounded,
                                            color: Color(0xFFFBBF24), size: 22),
                                        SizedBox(width: 8),
                                        Text(
                                          'QUỸ PHÉP THEO THÂM NIÊN',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: seniorityBonusDays > 0
                                            ? const Color(0xFFF59E0B).withValues(alpha: 0.22)
                                            : Colors.white.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: seniorityBonusDays > 0
                                              ? const Color(0xFFFBBF24).withValues(alpha: 0.8)
                                              : Colors.white.withValues(alpha: 0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            seniorityBonusDays > 0
                                                ? Icons.military_tech_rounded
                                                : Icons.timer_outlined,
                                            color: seniorityBonusDays > 0
                                                ? const Color(0xFFFBBF24)
                                                : Colors.white70,
                                            size: 13,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            seniorityBonusDays > 0
                                                ? '$tenureMonths tháng (+$seniorityBonusDays phép)'
                                                : '$tenureMonths tháng làm việc',
                                            style: TextStyle(
                                              color: seniorityBonusDays > 0
                                                  ? const Color(0xFFFDE68A)
                                                  : Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 22),

                                // Main remaining counter & circular ring
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Số ngày phép khả dụng còn lại',
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.75),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: [
                                            Text(
                                              remainingDays.toStringAsFixed(
                                                  remainingDays.truncateToDouble() == remainingDays ? 0 : 1),
                                              style: const TextStyle(
                                                color: Color(0xFF34D399), // Emerald Glow
                                                fontSize: 48,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -1.5,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              'ngày',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.7),
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Circular Percentage Indicator
                                    Container(
                                      width: 72,
                                      height: 72,
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withValues(alpha: 0.05),
                                        border: Border.all(
                                          color: const Color(0xFF34D399).withValues(alpha: 0.4),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          CircularProgressIndicator(
                                            value: (quotaPercent / 100.0).clamp(0.0, 1.0),
                                            strokeWidth: 5,
                                            backgroundColor: Colors.white12,
                                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                '${quotaPercent.toInt()}%',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                'còn lại',
                                                style: TextStyle(
                                                  color: Colors.white.withValues(alpha: 0.6),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 9,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Translucent glass metrics grid
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildGlassMetricCard(
                                        label: 'Hạn mức',
                                        value: '${accruedDays.toStringAsFixed(0)} ngày',
                                        icon: Icons.pie_chart_outline_rounded,
                                        valueColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildGlassMetricCard(
                                        label: 'Đã nghỉ',
                                        value: '${usedDays.toStringAsFixed(0)} ngày',
                                        icon: Icons.check_circle_outline_rounded,
                                        valueColor: const Color(0xFFF87171),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildGlassMetricCard(
                                        label: 'Chờ duyệt',
                                        value: '${pendingDays.toStringAsFixed(0)} ngày',
                                        icon: Icons.hourglass_top_rounded,
                                        valueColor: const Color(0xFFFBBF24),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // THẺ GIẢI THÍCH CHÍNH SÁCH THÂM NIÊN LÂU NĂM (>= 2 NĂM)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: seniorityBonusDays > 0
                              ? const Color(0xFFF59E0B).withValues(alpha: 0.35)
                              : AppColors.cardBorder,
                          width: 1,
                        ),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (seniorityBonusDays > 0
                                      ? AppColors.warning
                                      : AppColors.primary)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              seniorityBonusDays > 0
                                  ? Icons.military_tech_rounded
                                  : Icons.verified_user_outlined,
                              color: seniorityBonusDays > 0
                                  ? AppColors.warning
                                  : AppColors.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      seniorityBonusDays > 0
                                          ? 'Đãi ngộ Thâm niên Lâu năm'
                                          : 'Quy tắc Tích lũy Phép năm',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (seniorityBonusDays > 0) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppColors.warningBg,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppColors.warningBorder),
                                        ),
                                        child: const Text(
                                          '+ THƯỞNG',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  seniorityBonusDays > 0
                                      ? 'Bạn đã cống hiến $tenureMonths tháng (${tenureMonths ~/ 12} năm). Theo chính sách công ty, nhân sự làm từ 2 năm trở lên được thưởng thêm +$seniorityBonusDays ngày phép thâm niên (Tổng hạn mức: $accruedDays ngày/năm, cao hơn nhân sự mới).'
                                      : (tenureMonths < 12
                                          ? 'Nhân viên mới dưới 1 năm tích lũy 1 ngày phép/tháng ($tenureMonths tháng = $accruedDays ngày). Khi làm việc đủ 2 năm trở lên, bạn sẽ được tự động cộng thêm ngày phép thâm niên.'
                                          : 'Nhân viên 1 năm hưởng 12 ngày phép cơ sở. Khi đạt mốc 2 năm thâm niên trở lên sẽ được cộng thêm ngày phép thưởng thâm niên.'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Quick Actions
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: AppColors.primaryGlow,
                            ),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                              label: const Text(
                                'Lập đơn xin nghỉ mới',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreateLeaveRequestScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
                              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            icon: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 18),
                            label: const Text(
                              'Lịch ca',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ShiftScheduleScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Recent Requests Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Đơn từ gửi gần đây',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryLight,
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MyLeaveRequestsScreen(),
                              ),
                            );
                          },
                          icon: const Text(
                            'Xem tất cả',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          label: const Icon(Icons.arrow_forward_rounded, size: 16),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (leaveProv.userRequests.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.inbox_rounded, size: 40, color: AppColors.textMuted),
                            SizedBox(height: 10),
                            Text(
                              'Bạn chưa gửi đơn từ nào trong tháng.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: leaveProv.userRequests.take(3).length,
                        itemBuilder: (context, index) {
                          final req = leaveProv.userRequests[index];
                          final isApproved = req.status == 'APPROVED';
                          final isPending = req.status == 'PENDING';
                          final accentColor = isApproved
                              ? AppColors.success
                              : (isPending ? AppColors.warning : AppColors.error);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.cardBorder),
                              boxShadow: AppColors.softShadow,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LeaveRequestDetailScreen(request: req),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Row(
                                    children: [
                                      // Status accent line / icon container
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: accentColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(
                                            color: accentColor.withValues(alpha: 0.25),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.description_outlined,
                                          color: accentColor,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              req.typeDisplay,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_today_rounded,
                                                    size: 11, color: AppColors.textMuted),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${req.fromDate} → ${req.toDate}',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.textSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.surfaceSubtle,
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: Text(
                                                    '${req.totalDays} ngày',
                                                    style: const TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      StatusBadge(status: req.status),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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

  Widget _buildGlassMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
