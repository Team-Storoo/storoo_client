import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 저장/수정 화면에서 변경사항이 있을 때 뒤로가기 시 표시되는 취소 확인 팝업
///
/// 사용 예:
/// ```dart
/// final discard = await ConfirmDiscardDialog.show(context);
/// if (discard && mounted) Navigator.of(context).pop();
/// ```
///
/// - true 반환 : 사용자가 "나가기" 선택 → 변경사항 버리고 화면 종료
/// - false 반환: 사용자가 "계속 수정" 선택 → 그대로 화면 유지
class ConfirmDiscardDialog extends StatelessWidget {
  const ConfirmDiscardDialog({super.key});

  /// [context]로 다이얼로그를 표시하고 사용자 선택값을 반환합니다.
  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ConfirmDiscardDialog(),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 제목 ──────────────────────────────────────────────
            Text(
              '정말 취소하시겠습니까?',
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // ── 안내 문구 ──────────────────────────────────────────
            Text(
              '수정하신 내용은 저장되지 않습니다.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // ── 버튼 행 ────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // 계속 수정하기
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    overlayColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    '계속 수정',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // 나가기
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    overlayColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: Text(
                    '나가기',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
