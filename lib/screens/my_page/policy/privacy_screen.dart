import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/policy_text_body.dart';

/// 개인정보 처리방침 화면
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  static const _content =
      '수집 항목\n이메일, 닉네임, 저장 콘텐츠\n\n'
      '수집 목적\n서비스 제공 및 개인화\n\n'
      '보유 기간\n회원 탈퇴 시 즉시 삭제\n\n'
      '제3자 제공\n원칙적으로 제3자에게 제공하지 않습니다.\n'
      '단, 법령에 의거하거나 수사기관의 요청이 있는 경우 예외로 합니다.\n\n'
      '안전 조치\n수집된 개인정보는 암호화하여 안전하게 보관합니다.\n\n'
      '(이하 생략 — 실제 방침으로 교체 예정)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('개인정보 처리방침', style: AppTextStyles.headline2),
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
