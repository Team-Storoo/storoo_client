import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/db_service.dart';
import '../../../shared/widgets/confirm_discard_dialog.dart';
import './profile_edit_validator.dart';
import './widgets/profile_edit_body.dart';

/// 마이페이지 > 프로필 편집 화면
///
/// SRP: 화면 상태 관리·네비게이션·DB 연동만 담당
/// DIP: DBService 추상화에 의존
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  // ── 컨트롤러 ─────────────────────────────────────────────────────
  final TextEditingController _nicknameCtrl = TextEditingController();
  final TextEditingController _birthYearCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  // ── UI 상태 ────────────────────────────────────────────────────────
  String? _gender;
  bool _isLoading = true;

  // ── 초기값 (변경 감지 기준) ────────────────────────────────────────
  String _initialNickname = '';
  String? _initialGender;
  String _initialBirthYear = '';
  String _initialEmail = '';

  // ── 변경 감지 ─────────────────────────────────────────────────────
  bool get _hasChanges =>
      _nicknameCtrl.text != _initialNickname ||
      _gender != _initialGender ||
      _birthYearCtrl.text != _initialBirthYear ||
      _emailCtrl.text != _initialEmail;

  // ── 저장 버튼 활성화 조건 ─────────────────────────────────────────
  bool get _canSave =>
      ProfileEditValidator.isValidNickname(_nicknameCtrl.text.trim()) &&
      ProfileEditValidator.isBirthYearValidOrEmpty(
        _birthYearCtrl.text.trim(),
      ) &&
      ProfileEditValidator.isEmailValidOrEmpty(_emailCtrl.text.trim());

  // ── 라이프사이클 ──────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _birthYearCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  // ── 프로필 로드 ───────────────────────────────────────────────────

  /// TODO [DB] DBService.getUserProfile() 이 UserProfile 을 반환하면 됩니다.
  /// 현재 로그인된 사용자의 프로필을 반환하도록 구현해 주세요.
  Future<void> _loadProfile() async {
    final profile = await DBService.getUserProfile();
    if (!mounted) return;

    final nickname = profile?.nickname ?? '';
    final gender = profile?.gender;
    final birthYear = profile?.birthYear?.toString() ?? '';
    final email = profile?.email ?? '';

    setState(() {
      // 입력 필드 초기값 세팅
      _nicknameCtrl.text = nickname;
      _birthYearCtrl.text = birthYear;
      _emailCtrl.text = email;
      _gender = gender;

      // 변경 감지를 위한 초기값 저장
      _initialNickname = nickname;
      _initialGender = gender;
      _initialBirthYear = birthYear;
      _initialEmail = email;

      _isLoading = false;
    });
  }

  // ── 저장 ──────────────────────────────────────────────────────────

  /// TODO [DB] 변경된 프로필을 DB에 저장하는 로직을 구현해 주세요.
  ///
  /// 구현 예시:
  /// ```dart
  /// final profile = await DBService.getUserProfile() ?? UserProfile();
  /// profile
  ///   ..nickname  = _nicknameCtrl.text.trim()
  ///   ..gender    = _gender
  ///   ..birthYear = int.tryParse(_birthYearCtrl.text.trim())
  ///   ..email     = _emailCtrl.text.trim()
  ///   ..updatedAt = DateTime.now();
  /// await DBService.saveUserProfile(profile);
  /// ```
  Future<void> _save() async {
    if (!_canSave) return;

    // TODO [DB] 위 주석의 예시를 참고하여 여기에 저장 로직을 구현해 주세요.

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ── 뒤로가기 ─────────────────────────────────────────────────────

  Future<void> _maybePop() async {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await ConfirmDiscardDialog.show(context);
    if (discard && mounted) Navigator.of(context).pop();
  }

  // ── 빌드 ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final discard = await ConfirmDiscardDialog.show(context);
        if (discard && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text('프로필 편집', style: AppTextStyles.headline2),
          leading: GestureDetector(
            onTap: _maybePop,
            behavior: HitTestBehavior.opaque,
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: _canSave ? _save : null,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    '저장',
                    style: AppTextStyles.body.copyWith(
                      color:
                          _canSave
                              ? AppColors.primary
                              : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: ProfileEditBody(
          nicknameController: _nicknameCtrl,
          birthYearController: _birthYearCtrl,
          emailController: _emailCtrl,
          gender: _gender,
          onGenderChanged: (v) => setState(() => _gender = v),
          onChanged: () => setState(() {}),
        ),
      ),
    );
  }
}
