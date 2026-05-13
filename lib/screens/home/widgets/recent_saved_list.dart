import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/content.dart';
import '../../../models/folder_item.dart';

class RecentSavedList extends StatelessWidget {
  final List<Content> items;
  final Map<int, FolderItem> folderMap;
  final void Function(Content content, FolderItem? folder)? onTap;

  const RecentSavedList({
    super.key,
    required this.items,
    this.folderMap = const {},
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: Text(
            '아직 저장된 항목이 없어요',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final item = items[i];
          final folder =
              item.folderId != null ? folderMap[item.folderId] : null;
          return _RecentItemCard(
            item: item,
            folder: folder,
            onTap: onTap != null ? () => onTap!(item, folder) : null,
          );
        },
      ),
    );
  }
}

// ── 카드 ──────────────────────────────────────────────────────────────

class _RecentItemCard extends StatelessWidget {
  final Content item;
  final FolderItem? folder;
  final VoidCallback? onTap;

  const _RecentItemCard({required this.item, this.folder, this.onTap});

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  String get _typeLabel => switch (item.type) {
    'image' => '이미지',
    'memo' => '노트',
    _ => '링크',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 160,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 55, child: _buildImage()),
              Expanded(
                flex: 45,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '폴더 > ${folder?.name ?? '-'} > $_typeLabel',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(item.createdAt),
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (item.type == 'image' && item.effectiveImageUrls.isNotEmpty) {
      return Image.file(
        File(item.effectiveImageUrls.first),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder:
            (_, __, ___) => _iconBox(
              Icons.broken_image_outlined,
              AppColors.divider,
              AppColors.textSecondary,
            ),
      );
    }
    if (item.type == 'link' &&
        item.imageUrl != null &&
        item.imageUrl!.isNotEmpty) {
      return Image.network(
        item.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder:
            (_, __, ___) => _iconBox(
              Icons.link_rounded,
              AppColors.primaryLight,
              AppColors.primary,
            ),
      );
    }
    return switch (item.type) {
      'link' => _iconBox(
        Icons.link_rounded,
        AppColors.primaryLight,
        AppColors.primary,
      ),
      'image' => _iconBox(
        Icons.image_outlined,
        const Color(0xFFE8F5E9),
        const Color(0xFF43A047),
      ),
      'memo' => _iconBox(
        Icons.edit_note_rounded,
        const Color(0xFFFFF3E0),
        const Color(0xFFFF8F00),
      ),
      _ => _iconBox(
        Icons.insert_drive_file_outlined,
        AppColors.primaryLight,
        AppColors.primary,
      ),
    };
  }

  Widget _iconBox(IconData icon, Color bg, Color iconColor) {
    return Container(
      width: double.infinity,
      color: bg,
      child: Icon(icon, color: iconColor, size: 36),
    );
  }
}
