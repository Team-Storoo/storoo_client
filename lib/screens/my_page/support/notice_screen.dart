import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/notice_list.dart';

/// 공지사항 화면
/// TODO: DB 연동 후 실제 공지사항 데이터 연결
class NoticeScreen extends StatelessWidget {
  const NoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('공지사항', style: AppTextStyles.headline2),
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
          Expanded(child: NoticeList()),
        ],
      ),
    );
  }
}
