import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customLabel;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    Color border;
    String label = customLabel ?? status;

    switch (status) {
      case 'APPROVED':
      case 'ON_TIME':
      case 'DONE':
        bg = AppColors.successBg;
        text = AppColors.success;
        border = AppColors.successBorder;
        if (customLabel == null) {
          if (status == 'APPROVED') label = 'Đã duyệt';
          if (status == 'ON_TIME') label = 'Đúng giờ';
          if (status == 'DONE') label = 'Hoàn thành';
        }
        break;

      case 'PENDING':
      case 'IN_PROGRESS':
        bg = AppColors.warningBg;
        text = AppColors.warning;
        border = AppColors.warningBorder;
        if (customLabel == null) {
          if (status == 'PENDING') label = 'Chờ duyệt';
          if (status == 'IN_PROGRESS') label = 'Đang làm';
        }
        break;

      case 'REJECTED':
      case 'LATE':
      case 'ABSENT':
        bg = AppColors.errorBg;
        text = AppColors.error;
        border = AppColors.errorBorder;
        if (customLabel == null) {
          if (status == 'REJECTED') label = 'Từ chối';
          if (status == 'LATE') label = 'Đi trễ';
          if (status == 'ABSENT') label = 'Vắng mặt';
        }
        break;

      case 'TODO':
      case 'EARLY_LEAVE':
      default:
        bg = AppColors.infoBg;
        text = AppColors.info;
        border = AppColors.infoBorder;
        if (customLabel == null) {
          if (status == 'TODO') label = 'Chưa làm';
          if (status == 'EARLY_LEAVE') label = 'Về sớm';
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: text,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
