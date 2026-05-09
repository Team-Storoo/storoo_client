import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 작업 확인 다이얼로그 (삭제·경고 등 공통 UI)
///
/// SRP: 확인/취소 UI 렌더링만 담당
/// ISP: 필요한 props만 받아 다양한 상황에 재사용 가능
///
/// 사용 예:
/// ```dart
/// final confirmed = await ConfirmActionDialog.show(
///   context,
///   iconColor: AppColors.error,
///   title: '정말로 이 폴더를 삭제하시겠어요?',
///   message: '폴더를 삭제하면, 안에 담긴 콘텐츠도 함께 삭제되고 다시 복구할 수 없어요.',
///   confirmLabel: '삭제',
/// );
/// ```
/// - true : 사용자가 확인 선택
/// - false: 사용자가 취소 선택
class ConfirmActionDialog extends StatelessWidget {
  const ConfirmActionDialog({
    super.key,
    required this.iconColor,
    required this.title,
    required this.message,
    this.confirmLabel = '확인',
    this.confirmColor = AppColors.error,
    this.cancelLabel = '취소',
  });

  final Color iconColor;
  final String title;
  final String message;
  final String confirmLabel;
  final Color confirmColor;
  final String cancelLabel;

  static Future<bool> show(
    BuildContext context, {
    required Color iconColor,
    required String title,
    required String message,
    String confirmLabel = '확인',
    Color confirmColor = AppColors.error,
    String cancelLabel = '취소',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => ConfirmActionDialog(
            iconColor: iconColor,
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            confirmColor: confirmColor,
            cancelLabel: cancelLabel,
          ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 경고 아이콘 (좌측 정렬) ───────────────────────────────
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.priority_high_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),

            // ── 제목 (좌측 정렬) ──────────────────────────────────────
            Text(title, style: AppTextStyles.headline2),
            const SizedBox(height: 10),

            // ── 안내 문구 (좌측 정렬, 빨간색) ───────────────────────
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.error,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // ── 버튼 행 ────────────────────────────────────────────────
            Row(
              children: [
                // 취소
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.divider),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(cancelLabel, style: AppTextStyles.body),
                  ),
                ),
                const SizedBox(width: 12),
                // 확인
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      confirmLabel,
                      style: AppTextStyles.body.copyWith(color: Colors.white),
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
