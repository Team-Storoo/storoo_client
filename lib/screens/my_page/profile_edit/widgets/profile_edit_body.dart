import 'package:flutter/material.dart';

import '../../../onboarding/widgets/email_step.dart';
import '../../../onboarding/widgets/nickname_step.dart';

class ProfileEditBody extends StatelessWidget {
  const ProfileEditBody({
    super.key,
    required this.nicknameController,
    required this.emailController,
    required this.onChanged,
  });

  final TextEditingController nicknameController;
  final TextEditingController emailController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NicknameStep(
            controller: nicknameController,
            onChanged: onChanged,
          ),
          const SizedBox(height: 28),
          EmailStep(
            controller: emailController,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
