import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 저장 화면 — FAB에서 바텀시트로 열릴 예정
/// 현재는 비어 있는 플레이스홀더 화면
class SaveScreen extends StatelessWidget {
  const SaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: Text(
          '저장',
          style: AppTextStyles.headline1.copyWith(color: Colors.white),
        ),
      ),
      body: Center(child: Text('저장 화면 (추후 구현)', style: AppTextStyles.body)),
    );
  }
}
