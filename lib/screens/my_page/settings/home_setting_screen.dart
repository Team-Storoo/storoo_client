import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/home_section.dart';
import '../../../services/home_settings_service.dart';
import './widgets/home_section_checkbox.dart';

/// 홈화면 표시 섹션 설정 화면
///
/// - 선택 가능: 최소 [HomeSettingsService.minSections]개 ~
///             최대 [HomeSettingsService.maxSections]개
/// - 최솟값 미만이면 저장 버튼 비활성화
/// - 최댓값 초과 시 미선택 항목 체크박스 비활성화
class HomeSettingScreen extends StatefulWidget {
  const HomeSettingScreen({super.key});

  @override
  State<HomeSettingScreen> createState() => _HomeSettingScreenState();
}

class _HomeSettingScreenState extends State<HomeSettingScreen> {
  /// 현재 선택된 섹션 집합
  Set<HomeSection> _selected = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final saved = await HomeSettingsService.load();
    if (mounted) {
      setState(() {
        _selected = saved.toSet();
        _isLoading = false;
      });
    }
  }

  void _toggle(HomeSection section, bool checked) {
    setState(() {
      if (checked) {
        _selected.add(section);
      } else {
        // 최솟값 이하로 내려가지 않도록 보호
        if (_selected.length > HomeSettingsService.minSections) {
          _selected.remove(section);
        }
      }
    });
  }

  bool get _canSave =>
      _selected.length >= HomeSettingsService.minSections &&
      _selected.length <= HomeSettingsService.maxSections;

  Future<void> _save() async {
    if (!_canSave) return;
    await HomeSettingsService.save(_selected.toList());
    if (mounted) Navigator.of(context).pop(true); // true = 변경됨
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text('홈화면 설정', style: AppTextStyles.headline2),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          behavior: HitTestBehavior.opaque,
          child: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.divider,
                  ),
                  // ── 안내 문구 ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Row(
                      children: [
                        Text(
                          '홈화면에 표시할 항목을 선택하세요',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                    child: Row(
                      children: [
                        Text(
                          '최소 ${HomeSettingsService.minSections}개 · '
                          '최대 ${HomeSettingsService.maxSections}개 선택',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        // 현재 선택 수 뱃지
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_selected.length} / ${HomeSettingsService.maxSections}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── 섹션 체크박스 목록 ────────────────────────────────
                  Expanded(
                    child: ListView.separated(
                      itemCount: HomeSection.values.length,
                      separatorBuilder:
                          (_, __) => const Divider(
                            height: 1,
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                            color: AppColors.divider,
                          ),
                      itemBuilder: (_, i) {
                        final section = HomeSection.values[i];
                        final isChecked = _selected.contains(section);
                        // 최대 개수 도달 시 미선택 항목 비활성화
                        final isDisabled =
                            _selected.length >= HomeSettingsService.maxSections;

                        return HomeSectionCheckbox(
                          section: section,
                          isChecked: isChecked,
                          isDisabled: isDisabled,
                          onChanged: (checked) => _toggle(section, checked),
                        );
                      },
                    ),
                  ),

                  // ── 저장 버튼 (하단 고정) ──────────────────────────────
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: GestureDetector(
                        onTap: _canSave ? _save : null,
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color:
                                _canSave
                                    ? AppColors.primary
                                    : AppColors.divider,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              '저장하기',
                              style: AppTextStyles.subtitle.copyWith(
                                color:
                                    _canSave
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
