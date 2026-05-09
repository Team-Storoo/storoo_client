import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/content.dart';

class InFolderLinkList extends StatelessWidget {
  final List<Content> items;
  final Future<void> Function(int id) onDelete;
  final String folderName;
  final void Function(Content item)? onTap;
  final bool isEditMode;
  final Set<int> selectedIds;
  final void Function(int id)? onToggleSelect;

  const InFolderLinkList({
    super.key,
    required this.items,
    required this.onDelete,
    required this.folderName,
    this.onTap,
    this.isEditMode = false,
    this.selectedIds = const {},
    this.onToggleSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          '저장된 링크가 없습니다.',
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
          (_, i) => _LinkCard(
            item: items[i],
            folderName: folderName,
            onDelete: onDelete,
            onTap: onTap,
            isEditMode: isEditMode,
            isSelected: selectedIds.contains(items[i].id),
            onToggleSelect: onToggleSelect,
          ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final Content item;
  final String folderName;
  final Future<void> Function(int id) onDelete;
  final void Function(Content item)? onTap;
  final bool isEditMode;
  final bool isSelected;
  final void Function(int id)? onToggleSelect;

  const _LinkCard({
    required this.item,
    required this.folderName,
    required this.onDelete,
    this.onTap,
    this.isEditMode = false,
    this.isSelected = false,
    this.onToggleSelect,
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

  String _extractSource(String? url) {
    if (url == null || url.isEmpty) return '';
    try {
      final host = Uri.parse(url).host.toLowerCase();
      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        return 'Youtube';
      }
      if (host.contains('instagram.com')) { return 'Instagram'; }
      if (host.contains('twitter.com') || host.contains('x.com')) {
        return 'Twitter';
      }
      if (host.contains('naver.com')) return 'Naver';
      if (host.contains('google.com')) return 'Google';
      if (host.contains('tiktok.com')) return 'TikTok';
      final domain = host.startsWith('www.') ? host.substring(4) : host;
      final part = domain.split('.').first;
      if (part.isEmpty) return domain;
      return part[0].toUpperCase() + part.substring(1);
    } catch (_) {
      return '';
    }
  }

  Widget _buildThumbnail() {
    final imageUrl = item.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final image =
          imageUrl.startsWith('http')
              ? Image.network(
                imageUrl,
                width: 68,
                height: 68,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              )
              : Image.file(
                File(imageUrl),
                width: 68,
                height: 68,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(),
              );
      return ClipRRect(borderRadius: BorderRadius.circular(8), child: image);
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.link, color: AppColors.primary, size: 28),
    );
  }

  Widget _buildSelectCircle() {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? AppColors.primary : Colors.transparent,
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          width: 2,
        ),
      ),
      child: isSelected
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final source = _extractSource(item.url);
    final dateStr = _formatDate(item.createdAt);
    final dateSource = source.isNotEmpty ? '$dateStr | $source' : dateStr;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isEditMode
          ? () => onToggleSelect?.call(item.id)
          : () => onTap?.call(item),
      onLongPress: isEditMode ? null : () => _showDeleteMenu(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditMode) ...[
              _buildSelectCircle(),
              const SizedBox(width: 12),
            ],
            Expanded(
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
                  const SizedBox(height: 4),
                  Text(
                    dateSource,
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
                          item.tags
                              .take(5)
                              .map((tag) => _TagChip(tag: tag))
                              .toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            _buildThumbnail(),
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
