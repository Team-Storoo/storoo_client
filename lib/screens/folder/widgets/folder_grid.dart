import 'package:flutter/material.dart';
import '/models/folder_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import './folder_card.dart';

class FolderGrid extends StatelessWidget {
  const FolderGrid({
    super.key,
    required this.folders,
    required this.onAddTap,
    required this.onFolderTap,
    this.onDeleteTap,
    this.isReorderable = false,
    this.onReorder,
  });

  final List<FolderItem> folders;
  final VoidCallback onAddTap;
  final ValueChanged<FolderItem> onFolderTap;
  final ValueChanged<FolderItem>? onDeleteTap;
  final bool isReorderable;
  final void Function(int oldIndex, int newIndex)? onReorder;

  @override
  Widget build(BuildContext context) {
    if (folders.isEmpty) {
      return _EmptyState(onAddTap: onAddTap);
    }
    if (isReorderable) {
      return _ReorderableGrid(
        folders: folders,
        onAddTap: onAddTap,
        onFolderTap: onFolderTap,
        onDeleteTap: onDeleteTap,
        onReorder: onReorder!,
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: folders.length + 1,
      itemBuilder: (_, i) {
        if (i < folders.length) {
          final folder = folders[i];
          return FolderCard(
            folder: folder,
            onTap: () => onFolderTap(folder),
            onDeleteTap: onDeleteTap,
          );
        }
        return _AddCard(onTap: onAddTap);
      },
    );
  }
}

// ── 드래그 재정렬 그리드 ──────────────────────────────────────────────

class _ReorderableGrid extends StatefulWidget {
  const _ReorderableGrid({
    required this.folders,
    required this.onAddTap,
    required this.onFolderTap,
    required this.onReorder,
    this.onDeleteTap,
  });

  final List<FolderItem> folders;
  final VoidCallback onAddTap;
  final ValueChanged<FolderItem> onFolderTap;
  final ValueChanged<FolderItem>? onDeleteTap;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  State<_ReorderableGrid> createState() => _ReorderableGridState();
}

class _ReorderableGridState extends State<_ReorderableGrid> {
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 12) / 2;
    final cardHeight = cardWidth / 1.4;

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemCount: widget.folders.length + 1,
      itemBuilder: (context, i) {
        if (i == widget.folders.length) {
          return _AddCard(onTap: widget.onAddTap);
        }

        final folder = widget.folders[i];

        return DragTarget<int>(
          onWillAccept: (fromIndex) => fromIndex != null && fromIndex != i,
          onAccept: (fromIndex) {
            widget.onReorder(fromIndex, i);
            setState(() => _draggingIndex = null);
          },
          builder: (context, candidateData, _) {
            final isHovered = candidateData.isNotEmpty;

            return LongPressDraggable<int>(
              data: i,
              delay: const Duration(milliseconds: 300),
              onDragStarted: () => setState(() => _draggingIndex = i),
              onDraggableCanceled: (_, __) => setState(() => _draggingIndex = null),
              onDragEnd: (_) => setState(() => _draggingIndex = null),
              feedback: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: Opacity(
                    opacity: 0.9,
                    child: Transform.scale(
                      scale: 1.05,
                      child: FolderCard(folder: folder, onTap: () {}),
                    ),
                  ),
                ),
              ),
              childWhenDragging: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: isHovered
                      ? Border.all(color: AppColors.primary, width: 2)
                      : Border.all(color: Colors.transparent),
                ),
                child: FolderCard(
                  folder: folder,
                  onTap: _draggingIndex == null ? () => widget.onFolderTap(folder) : () {},
                  onDeleteTap: widget.onDeleteTap,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ── 공통 위젯 ─────────────────────────────────────────────────────────

class _AddCard extends StatelessWidget {
  const _AddCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.create_new_folder, color: AppColors.primary, size: 32),
              const SizedBox(height: 8),
              Text(
                '폴더 추가하기',
                style: AppTextStyles.body.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                  const Icon(Icons.add_circle, color: AppColors.primary, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '폴더 추가하기',
                    style: AppTextStyles.body.copyWith(color: AppColors.primary),
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
