import 'package:flutter/material.dart';
import 'package:storoo/shared/app_shell.dart';

import '../../models/user_profile.dart';
import '../../services/db_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController birthYearController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  int step = 0;

  bool agreedAge14 = false;
  bool agreedService = false;
  bool agreedPrivacy = false;
  bool agreedMarketing = false;
  bool agreedAds = false;

  String? gender;

  bool get canGoNext {
    switch (step) {
      case 0:
        return agreedAge14 && agreedService && agreedPrivacy;
      case 1:
        return nicknameController.text.trim().isNotEmpty;
      case 2:
        return gender != null && birthYearController.text.trim().isNotEmpty;
      case 3:
        return emailController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> saveAndFinish() async {
    final profile =
        UserProfile()
          ..nickname = nicknameController.text.trim()
          ..gender = gender
          ..birthYear = int.tryParse(birthYearController.text.trim())
          ..email = emailController.text.trim()
          ..agreedAge14 = agreedAge14
          ..agreedService = agreedService
          ..agreedPrivacy = agreedPrivacy
          ..agreedMarketing = agreedMarketing
          ..agreedAds = agreedAds
          ..onboardingCompleted = true
          ..createdAt = DateTime.now()
          ..updatedAt = DateTime.now();

    await DBService.saveUserProfile(profile);

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AppShell()));
  }

  void nextStep() {
    if (!canGoNext) return;

    if (step < 3) {
      setState(() {
        step++;
      });
    } else {
      saveAndFinish();
    }
  }

  void prevStep() {
    if (step == 0) return;
    setState(() {
      step--;
    });
  }

  @override
  void dispose() {
    nicknameController.dispose();
    birthYearController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title =
        [
          '이용약관에 동의해 주세요.',
          'Storoo에서 사용할\n닉네임을 설정해주세요.',
          '안녕하세요!\n성별과 나이를 입력해주세요.',
          '이메일 주소를 입력해주세요.',
        ][step];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storoo'),
        leading:
            step == 0
                ? null
                : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: prevStep,
                ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(child: _buildStepBody()),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: canGoNext ? nextStep : null,
                  child: Text(step == 3 ? '완료' : '다음'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepBody() {
    switch (step) {
      case 0:
        return Column(
          children: [
            CheckboxListTile(
              value: agreedAge14,
              onChanged: (v) => setState(() => agreedAge14 = v ?? false),
              title: const Text('[필수] 만 14세 이상입니다.'),
            ),
            CheckboxListTile(
              value: agreedService,
              onChanged: (v) => setState(() => agreedService = v ?? false),
              title: const Text('[필수] 서비스 이용약관 동의'),
            ),
            CheckboxListTile(
              value: agreedPrivacy,
              onChanged: (v) => setState(() => agreedPrivacy = v ?? false),
              title: const Text('[필수] 개인정보 수집 및 이용 동의'),
            ),
            CheckboxListTile(
              value: agreedMarketing,
              onChanged: (v) => setState(() => agreedMarketing = v ?? false),
              title: const Text('[선택] 마케팅 활용 동의'),
            ),
            CheckboxListTile(
              value: agreedAds,
              onChanged: (v) => setState(() => agreedAds = v ?? false),
              title: const Text('[선택] 광고성 정보 수신 동의'),
            ),
          ],
        );

      case 1:
        return TextField(
          controller: nicknameController,
          decoration: const InputDecoration(
            labelText: '닉네임',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        );

      case 2:
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => gender = 'male'),
                    child: Text(
                      '남성',
                      style: TextStyle(
                        color: gender == 'male' ? Colors.deepPurple : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => gender = 'female'),
                    child: Text(
                      '여성',
                      style: TextStyle(
                        color: gender == 'female' ? Colors.deepPurple : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: birthYearController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '출생년도',
                hintText: '예: 1999',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
        );

      case 3:
        return TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: '이메일',
            hintText: 'example@gmail.com',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => setState(() {}),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
