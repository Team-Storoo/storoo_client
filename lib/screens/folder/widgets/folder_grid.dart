import 'package:flutter/material.dart';
import '/models/folder_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import './folder_card.dart';

/// 폴더 2열 그리드 — 빈 상태일 때 안내 화면 표시
class FolderGrid extends StatelessWidget {
  const FolderGrid({
    super.key,
    required this.folders,
    required this.onAddTap,
    required this.onFolderTap,
    this.onDeleteTap, // ✅ 삭제 콜백 추가
  });

  final List<FolderItem> folders;
  final VoidCallback onAddTap;
  final ValueChanged<FolderItem> onFolderTap;
  final ValueChanged<FolderItem>? onDeleteTap; // ✅ 폴더 삭제 콜백

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return _EmptyState(onAddTap: onAddTap);
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: folders.length + 1, // 폴더 개수 + '추가하기' 카드 1개
      itemBuilder: (_, i) {
        if (i < folders.length) {
          // 👉 기존 폴더 카드
          final folder = folders[i];
          return FolderCard(
            folder: folder,
            onTap: () => onFolderTap(folder),
            onDeleteTap: onDeleteTap, // ✅ 삭제 콜백 전달
          );
        } else {
          // 마지막에 '폴더 추가하기' 카드
          return GestureDetector(
            onTap: onAddTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.create_new_folder,
                        color: AppColors.primary, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      '폴더 추가하기',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

// ======================================================================
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddTap});

  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '아직 생성된 폴더가 없어요',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onAddTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_circle,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '폴더 추가하기',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
