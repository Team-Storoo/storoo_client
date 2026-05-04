import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/folder_item.dart';

/// 홈 화면 내 폴더 미리보기 목록 (세로 리스트)
class FolderListPreview extends StatelessWidget {
  const FolderListPreview({super.key, required this.folders});

  final List<FolderItem> folders;

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Text('아직 생성한 폴더가 없어요', style: AppTextStyles.caption),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: folders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final folder = folders[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(folder.name, style: AppTextStyles.subtitle),
                    const SizedBox(height: 4),
                    Text('저장된 항목 ${folder.itemCount}개', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        );
      },
    );
  }
}
