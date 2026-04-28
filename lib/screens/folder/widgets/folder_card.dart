import 'package:flutter/material.dart';
import '/models/folder_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FolderCard extends StatelessWidget {
  final FolderItem folder;
  final VoidCallback onTap;
  final ValueChanged<FolderItem>? onDeleteTap; // ✅ 삭제 콜백 추가

  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // 폴더 이름과 내용
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    folder.name,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '저장된 항목 ${folder.itemCount}개',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // ✅ 세로 점 메뉴 버튼
            Positioned(
              right: 4,
              top: 4,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete' && onDeleteTap != null) {
                    onDeleteTap!(folder); // 삭제 실행
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('삭제'),
                  ),
                ],
                child: const Icon(Icons.more_vert,
                    color: AppColors.textSecondary, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
