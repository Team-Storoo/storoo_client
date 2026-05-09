import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 정책/약관 텍스트를 스크롤 가능하게 보여주는 공통 위젯
class PolicyTextBody extends StatelessWidget {
  const PolicyTextBody({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Text(content, style: AppTextStyles.body),
    );
  }
}
