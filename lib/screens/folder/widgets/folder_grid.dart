import 'package:flutter/material.dart';
import '/models/folder_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import './folder_card.dart';

/// 폴더 그리드 (일반 / 드래그 재정렬 / 리스트)
class FolderGrid extends StatelessWidget {
  const FolderGrid({
    super.key,
    required this.folders,
    required this.onAddTap,
    required this.onFolderTap,
    this.onDeleteTap,
    this.onRenameTap,
    this.isReorderable = false,
    this.isListView = false,
    this.onReorder,
  });

  final List<FolderItem> folders;
  final VoidCallback onAddTap;
  final ValueChanged<FolderItem> onFolderTap;
  final ValueChanged<FolderItem>? onDeleteTap;
  final ValueChanged<FolderItem>? onRenameTap;
  final bool isReorderable;
  final bool isListView;
  final void Function(int oldIndex, int newIndex)? onReorder;

  // ── 화면 빌드 ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // 폴더 없음 → 빈 상태
    if (folders.isEmpty) {
      return _EmptyState(onAddTap: onAddTap);
    }
    // 리스트 뷰 모드
    if (isListView) {
      return _FolderListView(
        folders: folders,
        onAddTap: onAddTap,
        onFolderTap: onFolderTap,
        onDeleteTap: onDeleteTap,
        onRenameTap: onRenameTap,
      );
    }
    // 사용자 지정순 → 드래그 재정렬 그리드
    if (isReorderable) {
      return _ReorderableGrid(
        folders: folders,
        onAddTap: onAddTap,
        onFolderTap: onFolderTap,
        onDeleteTap: onDeleteTap,
        onRenameTap: onRenameTap,
        onReorder: onReorder!,
      );
    }
    // 일반 그리드
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
            onRenameTap: onRenameTap,
          );
        }
        // 마지막 셀 → 폴더 추가 카드
        return _AddCard(onTap: onAddTap);
      },
    );
  }
}

// ── 리스트 뷰 ────────────────────────────────────────────────────────

class _FolderListView extends StatelessWidget {
  const _FolderListView({
    required this.folders,
    required this.onAddTap,
    required this.onFolderTap,
    this.onDeleteTap,
    this.onRenameTap,
  });

  final List<FolderItem> folders;
  final VoidCallback onAddTap;
  final ValueChanged<FolderItem> onFolderTap;
  final ValueChanged<FolderItem>? onDeleteTap;
  final ValueChanged<FolderItem>? onRenameTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: folders.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        if (i < folders.length) {
          final folder = folders[i];
          return _FolderListRow(
            folder: folder,
            onTap: () => onFolderTap(folder),
            onDeleteTap: onDeleteTap,
            onRenameTap: onRenameTap,
          );
        }
        return _AddListRow(onTap: onAddTap);
      },
    );
  }
}

class _FolderListRow extends StatefulWidget {
  const _FolderListRow({
    required this.folder,
    required this.onTap,
    this.onDeleteTap,
    this.onRenameTap,
  });

  final FolderItem folder;
  final VoidCallback onTap;
  final ValueChanged<FolderItem>? onDeleteTap;
  final ValueChanged<FolderItem>? onRenameTap;

  @override
  State<_FolderListRow> createState() => _FolderListRowState();
}

class _FolderListRowState extends State<_FolderListRow> {
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
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.folder.name, style: AppTextStyles.subtitle),
                  const SizedBox(height: 4),
                  Text(
                    '저장된 항목 ${widget.folder.itemCount}개',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTapDown: (d) => _tapPosition = d.globalPosition,
              onTap: _showMenu,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddListRow extends StatelessWidget {
  const _AddListRow({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.create_new_folder,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '폴더 추가하기',
              style: AppTextStyles.body.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
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
    this.onRenameTap,
  });

  final List<FolderItem> folders;
  final VoidCallback onAddTap;
  final ValueChanged<FolderItem> onFolderTap;
  final ValueChanged<FolderItem>? onDeleteTap;
  final ValueChanged<FolderItem>? onRenameTap;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  State<_ReorderableGrid> createState() => _ReorderableGridState();
}

class _ReorderableGridState extends State<_ReorderableGrid> {
  // 현재 드래그 중인 카드 인덱스
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
        // 마지막 셀 → 폴더 추가 카드
        if (i == widget.folders.length) {
          return _AddCard(onTap: widget.onAddTap);
        }

        final folder = widget.folders[i];

        // 드롭 영역
        return DragTarget<int>(
          onWillAccept: (fromIndex) => fromIndex != null && fromIndex != i,
          onAccept: (fromIndex) {
            widget.onReorder(fromIndex, i);
            setState(() => _draggingIndex = null);
          },
          builder: (context, candidateData, _) {
            final isHovered = candidateData.isNotEmpty;

            // 드래그 소스
            return LongPressDraggable<int>(
              data: i,
              delay: const Duration(milliseconds: 300),
              onDragStarted: () => setState(() => _draggingIndex = i),
              onDraggableCanceled:
                  (_, __) => setState(() => _draggingIndex = null),
              onDragEnd: (_) => setState(() => _draggingIndex = null),
              // 드래그 중 떠다니는 카드
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
              // 원래 자리 빈 슬롯
              childWhenDragging: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
              ),
              // 일반 상태 / 호버 강조
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border:
                      isHovered
                          ? Border.all(color: AppColors.primary, width: 2)
                          : Border.all(color: Colors.transparent),
                ),
                child: FolderCard(
                  folder: folder,
                  onTap:
                      _draggingIndex == null
                          ? () => widget.onFolderTap(folder)
                          : () {},
                  onDeleteTap: widget.onDeleteTap,
                  onRenameTap: widget.onRenameTap,
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

/// 폴더 추가 카드
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
              const Icon(
                Icons.create_new_folder,
                color: AppColors.primary,
                size: 32,
              ),
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

/// 폴더가 없을 때 빈 상태 안내
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
