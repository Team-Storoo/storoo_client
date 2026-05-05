import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/policy_text_body.dart';

/// 데이터 제공 정책 화면
class DataPolicyScreen extends StatelessWidget {
  const DataPolicyScreen({super.key});

  static const _content =
      'Storoo는 사용자 데이터를 다음 목적으로만 활용합니다.\n\n'
      '활용 목적\n• 서비스 품질 개선\n• 개인화 추천\n• 오류 분석 및 안정성 향상\n\n'
      '데이터 보호\n'
      '데이터는 암호화되어 저장되며, 외부에 제공되지 않습니다.\n\n'
      '데이터 삭제\n'
      '회원 탈퇴 시 모든 데이터가 즉시 삭제됩니다.\n\n'
      '(이하 생략 — 실제 정책으로 교체 예정)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('데이터 제공 정책', style: AppTextStyles.headline2),
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
          Expanded(child: PolicyTextBody(content: _content)),
        ],
      ),
    );
  }
}
