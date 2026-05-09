import 'package:flutter/material.dart';

import '../../../onboarding/widgets/email_step.dart';
import '../../../onboarding/widgets/nickname_step.dart';
import '../../../onboarding/widgets/personal_info_step.dart';

/// 프로필 편집 폼 바디
///
/// SRP: 입력 폼 레이아웃 렌더링만 담당
/// OCP: 온보딩 입력 위젯을 수정 없이 그대로 재사용
class ProfileEditBody extends StatelessWidget {
  const ProfileEditBody({
    super.key,
    required this.nicknameController,
    required this.birthYearController,
    required this.emailController,
    required this.gender,
    required this.onGenderChanged,
    required this.onChanged,
  });

  final TextEditingController nicknameController;
  final TextEditingController birthYearController;
  final TextEditingController emailController;
  final String? gender;
  final ValueChanged<String> onGenderChanged;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 닉네임 (필수) ─────────────────────────────────────────
          NicknameStep(
            controller: nicknameController,
            onChanged: onChanged,
          ),
          const SizedBox(height: 28),

          // ── 성별 + 출생년도 (선택) ────────────────────────────────
          PersonalInfoStep(
            gender: gender,
            onGenderChanged: onGenderChanged,
            birthYearController: birthYearController,
            onChanged: onChanged,
          ),
          const SizedBox(height: 28),

          // ── 이메일 (선택) ─────────────────────────────────────────
          EmailStep(
            controller: emailController,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
