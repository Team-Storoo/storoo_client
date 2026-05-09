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
/// SRP: 폼 UI 렌더링만 담당
class ShareSaveBody extends StatelessWidget {
  const ShareSaveBody({
    super.key,
    this.type = 'link',
    this.imageFilePath,
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
  final String? imageFilePath;
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

/// 공유된 이미지 미리보기 (이미지 타입 전용)
class _ShareImagePreview extends StatelessWidget {
  const _ShareImagePreview({this.filePath});

  final String? filePath;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child:
          filePath != null
              ? Image.file(
                File(filePath!),
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              )
              : Container(
                width: double.infinity,
                height: 180,
                color: const Color(0xFFF5F5F5),
                child: const Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: Color(0xFFBDBDBD),
                ),
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
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
