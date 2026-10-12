import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customLabel;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label = customLabel ?? status;

    switch (status) {
      case 'APPROVED':
      case 'ON_TIME':
      case 'DONE':
        bg = AppColors.successBg;
        text = AppColors.success;
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
        if (customLabel == null) {
          if (status == 'TODO') label = 'Chưa làm';
          if (status == 'EARLY_LEAVE') label = 'Về sớm';
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
