import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/policy_text_body.dart';

/// 서비스 이용약관 화면
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _content =
      '제1조 (목적)\n'
      'Storoo 서비스 이용에 관한 조건 및 절차를 규정합니다.\n\n'
      '제2조 (이용약관의 효력)\n'
      '본 약관은 서비스 화면에 게시함으로써 효력이 발생합니다.\n\n'
      '제3조 (서비스 제공)\n'
      'Storoo는 콘텐츠 저장, 폴더 관리, 검색 기능을 제공합니다.\n\n'
      '제4조 (회원의 의무)\n'
      '회원은 타인의 정보를 도용하거나 부정한 방법으로 서비스를 이용해서는 안 됩니다.\n\n'
      '제5조 (서비스 이용 제한)\n'
      '회사는 약관 위반 시 서비스 이용을 제한할 수 있습니다.\n\n'
      '(이하 생략 — 실제 약관으로 교체 예정)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('서비스 이용약관', style: AppTextStyles.headline2),
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
