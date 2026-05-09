import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 폴더 옵션 바텀시트 (이름 변경 / 삭제)
///
/// SRP: 폴더 옵션 메뉴 UI만 담당
///
/// 반환값:
/// - 'rename' : 이름 변경 선택
/// - 'delete' : 삭제 선택
/// - null     : 닫기
class FolderOptionsSheet extends StatelessWidget {
  const FolderOptionsSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const FolderOptionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── 드래그 핸들 ───────────────────────────────────────────
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD0D0D0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          // ── 옵션 목록 ─────────────────────────────────────────────
          _OptionTile(
            icon: Icons.drive_file_rename_outline_rounded,
            label: '폴더 이름 변경',
            color: AppColors.textPrimary,
            onTap: () => Navigator.pop(context, 'rename'),
          ),
          _OptionTile(
            icon: Icons.delete_outline_rounded,
            label: '폴더 삭제',
            color: AppColors.error,
            onTap: () => Navigator.pop(context, 'delete'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 16),
            Text(label, style: AppTextStyles.subtitle.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
