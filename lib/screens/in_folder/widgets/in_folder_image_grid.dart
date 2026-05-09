import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/content.dart';

class InFolderImageGrid extends StatelessWidget {
  final List<Content> items;
  final Future<void> Function(int id) onDelete;
  final String folderName;
  final void Function(Content item)? onTap;
  final bool isEditMode;
  final Set<int> selectedIds;
  final void Function(int id)? onToggleSelect;

  const InFolderImageGrid({
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
          '저장된 이미지가 없습니다.',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _ImageCard(
        item: items[i],
        onDelete: onDelete,
        onTap: onTap,
        isEditMode: isEditMode,
        isSelected: selectedIds.contains(items[i].id),
        onToggleSelect: onToggleSelect,
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final Content item;
  final Future<void> Function(int id) onDelete;
  final void Function(Content item)? onTap;
  final bool isEditMode;
  final bool isSelected;
  final void Function(int id)? onToggleSelect;

  const _ImageCard({
    required this.item,
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditMode
          ? () => onToggleSelect?.call(item.id)
          : () => onTap?.call(item),
      onLongPress: isEditMode ? null : () => _showDeleteMenu(context),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? Image.file(
                      File(item.imageUrl!),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder:
                          (_, __, ___) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textSecondary,
                              size: 32,
                            ),
                          ),
                    )
                  : const Center(
                      child: Icon(
                        Icons.image_outlined,
                        color: AppColors.textSecondary,
                        size: 32,
                      ),
                    ),
            ),
          ),
          if (isEditMode)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.85),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ),
        ],
      ),
    );
  }
}
