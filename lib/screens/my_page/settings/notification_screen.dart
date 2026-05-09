import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/notification_setting_list.dart';

/// 알림 설정 화면
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('알림 설정', style: AppTextStyles.headline2),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: const Column(
        children: [
          Divider(height: 1, thickness: 1, color: AppColors.divider),
          Expanded(child: NotificationSettingList()),
        ],
      ),
    );
  }
}
