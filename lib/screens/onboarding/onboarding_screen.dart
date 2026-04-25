import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/user_profile.dart';
import '../../services/db_service.dart';
import '../../shared/app_shell.dart';
import 'widgets/terms_step.dart';
import 'widgets/nickname_step.dart';
import 'widgets/personal_info_step.dart';
import 'widgets/email_step.dart';

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

  bool get allAgreed =>
      agreedAge14 &&
      agreedService &&
      agreedPrivacy &&
      agreedMarketing &&
      agreedAds;

  bool get canGoNext {
    switch (step) {
      case 0:
        return agreedAge14 && agreedService && agreedPrivacy;
      case 1:
        return _isValidNickname(nicknameController.text.trim());
      case 2:
        return gender != null &&
            _isValidBirthYear(birthYearController.text.trim());
      case 3:
        return _isValidEmail(emailController.text.trim());
      default:
        return false;
    }
  }

  /// 1900 ~ 현재 연도 사이의 4자리 숫자
  bool _isValidBirthYear(String value) {
    if (value.length != 4) return false;
    final year = int.tryParse(value);
    if (year == null) return false;
    final currentYear = DateTime.now().year;
    return year >= 1900 && year <= currentYear;
  }

  /// 한글, 영문 대소문자, 숫자, 밑줄(_), 마침표(.) 만 허용 / 2~15자
  bool _isValidNickname(String value) {
    if (value.length < 2) return false;
    final regex = RegExp(r'^[가-힣a-zA-Z0-9_.]+$');
    return regex.hasMatch(value);
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.(com|net|org|edu|gov|io|co|kr|me|app|dev|info|biz|[a-zA-Z]{2,})$',
    );
    return regex.hasMatch(email);
  }

  void toggleAll(bool value) {
    setState(() {
      agreedAge14 = value;
      agreedService = value;
      agreedPrivacy = value;
      agreedMarketing = value;
      agreedAds = value;
    });
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
      setState(() => step++);
    } else {
      saveAndFinish();
    }
  }

  void skipStep() {
    if (step < 3) {
      setState(() => step++);
    } else {
      saveAndFinish();
    }
  }

  void prevStep() {
    if (step == 0) return;
    setState(() => step--);
  }

  @override
  void dispose() {
    nicknameController.dispose();
    birthYearController.dispose();
    emailController.dispose();
    super.dispose();
  }

  String get _title {
    final nickname =
        nicknameController.text.trim().isEmpty
            ? 'OOO'
            : nicknameController.text.trim();
    return [
      '이용약관에 동의해 주세요.',
      'Storoo에서 사용할\n닉네임을 설정해주세요.',
      '안녕하세요, $nickname님!\n성별과 나이를 입력해주세요.',
      '$nickname님의\n이메일 주소를 입력해주세요.',
    ][step];
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Storoo',
            style: AppTextStyles.storooTitle.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          leading:
              step == 0
                  ? const SizedBox.shrink()
                  : GestureDetector(
                    onTap: prevStep,
                    behavior: HitTestBehavior.opaque,
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        _title,
                        style: AppTextStyles.headline1.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 28),
                      _buildStepBody(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _buildBottomArea(),
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
        return TermsStep(
          agreedAge14: agreedAge14,
          agreedService: agreedService,
          agreedPrivacy: agreedPrivacy,
          agreedMarketing: agreedMarketing,
          agreedAds: agreedAds,
          allAgreed: allAgreed,
          onAge14Changed: (v) => setState(() => agreedAge14 = v),
          onServiceChanged: (v) => setState(() => agreedService = v),
          onPrivacyChanged: (v) => setState(() => agreedPrivacy = v),
          onMarketingChanged: (v) => setState(() => agreedMarketing = v),
          onAdsChanged: (v) => setState(() => agreedAds = v),
          onToggleAll: toggleAll,
        );
      case 1:
        return NicknameStep(
          controller: nicknameController,
          onChanged: () => setState(() {}),
        );
      case 2:
        return PersonalInfoStep(
          gender: gender,
          onGenderChanged: (v) => setState(() => gender = v),
          birthYearController: birthYearController,
          onChanged: () => setState(() {}),
        );
      case 3:
        return EmailStep(
          controller: emailController,
          onChanged: () => setState(() {}),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomArea() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: canGoNext ? nextStep : null,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return const Color(0xFFC4A8FF);
                }
                return AppColors.primary;
              }),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              elevation: WidgetStateProperty.all(0),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            child: Text(
              '다음',
              style: AppTextStyles.button.copyWith(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        if (step == 2 || step == 3) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: skipStep,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '건너뛰기 >',
                style: AppTextStyles.caption.copyWith(fontSize: 13),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
