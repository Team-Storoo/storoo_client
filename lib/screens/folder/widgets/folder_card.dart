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
                _MoreButton(
                  folder: folder,
                  onDeleteTap: onDeleteTap,
                  onRenameTap: onRenameTap,
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

class _MoreButton extends StatefulWidget {
  const _MoreButton({
    required this.folder,
    this.onDeleteTap,
    this.onRenameTap,
  });

  final FolderItem folder;
  final ValueChanged<FolderItem>? onDeleteTap;
  final ValueChanged<FolderItem>? onRenameTap;

  @override
  State<_MoreButton> createState() => _MoreButtonState();
}

class _MoreButtonState extends State<_MoreButton> {
  Offset _tapPosition = Offset.zero;

  Future<void> _showMenu() async {
    final size = MediaQuery.of(context).size;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        _tapPosition.dx,
        _tapPosition.dy,
        size.width - _tapPosition.dx,
        size.height - _tapPosition.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: [
        PopupMenuItem(
          value: 'rename',
          height: 44,
          child: Row(
            children: [
              const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '이름 수정',
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          height: 44,
          child: Row(
            children: [
              const Icon(Icons.delete_outline, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              Text(
                '삭제',
                style: AppTextStyles.body.copyWith(color: AppColors.error),
              ),
            ],
          ),
        ),
      ],
    );
    if (result == 'rename') widget.onRenameTap?.call(widget.folder);
    if (result == 'delete') widget.onDeleteTap?.call(widget.folder);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (d) => _tapPosition = d.globalPosition,
      onTap: _showMenu,
      child: const Padding(
        padding: EdgeInsets.all(2),
        child: Icon(
          Icons.more_vert,
          size: 18,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
