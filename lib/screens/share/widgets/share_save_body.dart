import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/folder_item.dart';
import '../../../shared/widgets/required_label.dart';
import '../../save/widgets/folder_selector.dart';
import '../../save/widgets/memo_field.dart';
import '../../save/widgets/tag_input_row.dart';

/// Share 저장 시트 본문 레이아웃
class ShareSaveBody extends StatelessWidget {
  const ShareSaveBody({
    super.key,
    this.type = 'link',
    this.imageFilePaths = const [],
    required this.folders,
    required this.selectedFolder,
    required this.onSelectFolder,
    required this.onAddFolder,
    required this.titleController,
    required this.onTitleChanged,
    required this.memoController,
    required this.onMemoChanged,
    required this.tags,
    required this.onAddTag,
    required this.onRemoveTag,
    this.loadingFolders = false,
  });

  /// "link" | "note" | "image"
  final String type;
  final List<String> imageFilePaths;
  final List<FolderItem> folders;
  final FolderItem? selectedFolder;
  final ValueChanged<FolderItem> onSelectFolder;
  final VoidCallback onAddFolder;
  final TextEditingController titleController;
  final VoidCallback onTitleChanged;
  final TextEditingController memoController;
  final VoidCallback onMemoChanged;
  final List<String> tags;
  final VoidCallback onAddTag;
  final ValueChanged<int> onRemoveTag;
  final bool loadingFolders;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 이미지 미리보기 (이미지 타입) ──
          if (type == 'image' && imageFilePaths.isNotEmpty) ...[
            _ShareImagePreviewRow(paths: imageFilePaths),
            const SizedBox(height: 20),
          ],

          // ── 폴더 선택 ──
          if (loadingFolders)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else
            FolderSelector(
              folders: folders,
              selectedFolder: selectedFolder,
              onSelect: onSelectFolder,
              onAddFolder: onAddFolder,
              labelText: '어떤 폴더에 저장할까요?',
            ),
          const SizedBox(height: 20),

          // ── 제목 (필수) ──
          const RequiredLabel('제목'),
          const SizedBox(height: 8),
          _ShareTitleField(
            controller: titleController,
            onChanged: onTitleChanged,
          ),
          const SizedBox(height: 20),

          // ── 메모 (노트 타입 제외) ──
          if (type != 'note') ...[
            MemoField(controller: memoController, onChanged: onMemoChanged),
            const SizedBox(height: 20),
          ],

          // ── 태그 ──
          TagInputRow(tags: tags, onAdd: onAddTag, onRemove: onRemoveTag),
        ],
      ),
    );
  }
}

/// 이미지 가로 스크롤 미리보기 (최대 5장)
class _ShareImagePreviewRow extends StatelessWidget {
  const _ShareImagePreviewRow({required this.paths});

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    // 1장이면 전체 너비로 표시
    if (paths.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(paths.first),
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
        ),
      );
    }

    // 2장 이상이면 가로 스크롤
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(paths[i]),
                width: 140,
                height: 160,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(width: 140),
              ),
            ),
            // 장 수 뱃지 (마지막 썸네일 우상단)
            if (i == 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${paths.length}장',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder({double? width}) {
    return Container(
      width: width ?? double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 40,
        color: Color(0xFFBDBDBD),
      ),
    );
  }
}

class _ShareTitleField extends StatelessWidget {
  const _ShareTitleField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: '제목을 입력해주세요.',
        hintStyle: AppTextStyles.caption,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }
}
