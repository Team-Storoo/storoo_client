import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/content.dart';

class InFolderMemoList extends StatelessWidget {
  final List<Content> items;
  final Future<void> Function(int id) onDelete;
  final String folderName;
  final void Function(Content item)? onTap;

  const InFolderMemoList({
    super.key,
    required this.items,
    required this.onDelete,
    required this.folderName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          '저장된 메모가 없습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      itemCount: items.length,
      separatorBuilder:
          (_, __) =>
              const Divider(height: 1, thickness: 1, color: AppColors.divider),
      itemBuilder:
          (_, i) => _MemoCard(
            item: items[i],
            folderName: folderName,
            onDelete: onDelete,
            onTap: onTap,
          ),
    );
  }
}

class _MemoCard extends StatelessWidget {
  final Content item;
  final String folderName;
  final Future<void> Function(int id) onDelete;
  final void Function(Content item)? onTap;

  const _MemoCard({
    required this.item,
    required this.folderName,
    required this.onDelete,
    this.onTap,
  });

  void _showDeleteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                  ),
                  title: const Text(
                    '삭제',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      color: AppColors.error,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onDelete(item.id);
                  },
                ),
              ],
            ),
          ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(item),
      onLongPress: () => _showDeleteMenu(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (item.content != null && item.content!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                item.content!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              _formatDate(item.createdAt),
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '폴더 > $folderName',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            if (item.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children:
                    item.tags.take(5).map((tag) => _TagChip(tag: tag)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
