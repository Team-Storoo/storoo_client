import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 마이페이지 화면 (추후 구현 예정)
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: Text(
          '마이페이지',
          style: AppTextStyles.headline1.copyWith(color: Colors.white),
        ),
      ),
      body: Center(child: Text('마이페이지 (추후 구현)', style: AppTextStyles.body)),
    );
  }
}
