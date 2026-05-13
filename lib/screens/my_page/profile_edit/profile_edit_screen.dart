import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../services/db_service.dart';
import '../../../shared/widgets/confirm_discard_dialog.dart';
import './profile_edit_validator.dart';
import './widgets/profile_edit_body.dart';

/// 마이페이지 > 프로필 편집 화면
class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nicknameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  bool _isLoading = true;

  String _initialNickname = '';
  String _initialEmail = '';

  bool get _hasChanges =>
      _nicknameCtrl.text != _initialNickname ||
      _emailCtrl.text != _initialEmail;

  bool get _canSave =>
      ProfileEditValidator.isValidNickname(_nicknameCtrl.text.trim()) &&
      ProfileEditValidator.isEmailValidOrEmpty(_emailCtrl.text.trim());

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await DBService.getUserProfile();
    if (!mounted) return;

    final nickname = profile?.nickname ?? '';
    final email = profile?.email ?? '';

    setState(() {
      _nicknameCtrl.text = nickname;
      _emailCtrl.text = email;

      _initialNickname = nickname;
      _initialEmail = email;

      _isLoading = false;
    });
  }

  Future<void> _save() async {
    if (!_canSave) return;

    final profile = await DBService.getUserProfile();
    if (profile == null) return;

    profile
      ..nickname = _nicknameCtrl.text.trim()
      ..email = _emailCtrl.text.trim()
      ..updatedAt = DateTime.now();
    await DBService.saveUserProfile(profile);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _maybePop() async {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await ConfirmDiscardDialog.show(context);
    if (discard && mounted) Navigator.of(context).pop();
  }

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
          emailController: _emailCtrl,
          onChanged: () => setState(() {}),
        ),
      ),
    );
  }
}
