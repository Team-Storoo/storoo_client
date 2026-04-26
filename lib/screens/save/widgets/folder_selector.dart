import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../folder/folder_item.dart';

/// 저장 폴더 선택 위젯
/// - 2열 그리드로 폴더 목록 표시
/// - 선택 시 primary 색상 테두리
/// - 오른쪽 상단 '폴더 추가하기' 버튼
class FolderSelector extends StatelessWidget {
  const FolderSelector({
    super.key,
    required this.folders,
    required this.selectedFolderId,
    required this.onSelect,
    required this.onAddFolder,
  });

  final List<FolderItem> folders;
  final String? selectedFolderId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAddFolder;

  static const _labelStyle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Color(0xFF888888),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('저장 폴더', style: _labelStyle),
            GestureDetector(
              onTap: onAddFolder,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle,
                    size: 15,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '폴더 추가하기',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: folders.length,
          itemBuilder: (_, i) {
            final folder = folders[i];
            final isSelected = folder.id == selectedFolderId;
            return GestureDetector(
              onTap: () => onSelect(folder.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected
                            ? AppColors.primary
                            : const Color(0xFFE0E0E0),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Text(
                  folder.name,
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ).copyWith(color: AppColors.textPrimary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
