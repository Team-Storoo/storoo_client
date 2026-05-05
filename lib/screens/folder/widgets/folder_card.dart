import 'package:flutter/material.dart';
import '/models/folder_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 폴더 목록의 개별 카드
class FolderCard extends StatelessWidget {
  final FolderItem folder;
  final VoidCallback onTap;
  final ValueChanged<FolderItem>? onDeleteTap;
  final ValueChanged<FolderItem>? onRenameTap;

  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    this.onDeleteTap,
    this.onRenameTap,
  });

  // ── 화면 빌드 ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    folder.name,
                    style: AppTextStyles.subtitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(
                    Icons.more_vert,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Text('저장된 항목 ${folder.itemCount}개', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
