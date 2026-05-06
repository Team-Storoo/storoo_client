import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/content.dart';
import '../../../models/folder_item.dart';
import '../../../services/db_service.dart';
import '../../folder/widgets/create_folder_dialog.dart';
import '../widgets/dashed_border.dart';
import '../widgets/folder_selector.dart';
import '../widgets/memo_field.dart';
import '../widgets/tag_input_row.dart';
import '../widgets/save_button.dart';

/// 이미지 저장 / 수정 화면
/// 필수: 이미지 1장 이상(최대 5장), 제목, 저장 폴더
/// 선택: 메모(최대 200자), 태그
class SaveImageScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  final Content? initialContent;
  final FolderItem? initialFolder;

  const SaveImageScreen({
    super.key,
    this.onSaved,
    this.initialContent,
    this.initialFolder,
  });

  @override
  State<SaveImageScreen> createState() => _SaveImageScreenState();
}

class _SaveImageScreenState extends State<SaveImageScreen> {
  final _titleCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();

  List<FolderItem> _folders = [];
  FolderItem? _selectedFolder;
  final List<String> _tags = [];

  final List<XFile> _images = [];
  static const int _maxImages = 5;

  bool _loadingFolders = true;
  bool _saving = false;

  static const int _maxFolders = 5;

  bool get _isEditing => widget.initialContent != null;

  bool get _canSave =>
      _images.isNotEmpty &&
      _titleCtrl.text.trim().isNotEmpty &&
      _selectedFolder != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.initialContent!;
      _titleCtrl.text = c.title;
      _memoCtrl.text = c.content ?? '';
      _tags.addAll(c.tags);
      if (c.imageUrl?.isNotEmpty == true) {
        _images.add(XFile(c.imageUrl!));
      }
    }
    _loadFolders();
    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadFolders() async {
    final folders = await DBService.getFolders();
    if (mounted) {
      setState(() {
        _folders = folders;
        if (_isEditing && widget.initialFolder != null) {
          _selectedFolder = _folders.firstWhere(
            (f) => f.id == widget.initialFolder!.id,
            orElse: () => folders.isNotEmpty ? folders.first : _folders.first,
          );
        } else {
          _selectedFolder ??= folders.isNotEmpty ? folders.first : null;
        }
        _loadingFolders = false;
      });
    }
  }

  Future<void> _createFolder() async {
    if (_folders.length >= _maxFolders) {
      _showSnack('폴더는 최대 $_maxFolders개까지 만들 수 있어요.');
      return;
    }
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreateFolderDialog(),
    );
    if (name == null || name.isEmpty || !mounted) return;
    final folder =
        FolderItem()
          ..name = name
          ..createdAt = DateTime.now()
          ..itemCount = 0;
    await DBService.saveFolder(folder);
    final newId = folder.id;
    final updated = await DBService.getFolders();
    if (mounted) {
      setState(() {
        _folders = updated;
        _selectedFolder = _folders.firstWhere(
          (f) => f.id == newId,
          orElse: () => _folders.last,
        );
      });
    }
  }

  void _addImage() async {
    if (_images.length >= _maxImages) return;
    try {
      final XFile? file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (file == null || !mounted) return;
      setState(() => _images.add(file));
    } catch (_) {}
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _showAddTagDialog() async {
    final tag = await TagAddDialog.show(context);
    if (tag == null || tag.isEmpty) return;
    setState(() => _tags.add(tag));
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final memo = _memoCtrl.text.trim();
    final title = _titleCtrl.text.trim();

    if (_isEditing) {
      final c = widget.initialContent!;
      final oldFolderId = c.folderId;
      c.title = title;
      c.content = memo.isEmpty ? null : memo;
      c.tags = List.from(_tags);
      c.folderId = _selectedFolder!.id;
      if (oldFolderId != null && oldFolderId != c.folderId) {
        await DBService.moveContentToFolder(c, oldFolderId);
      } else {
        await DBService.updateContent(c);
      }
    } else {
      for (final image in _images) {
        final content =
            Content()
              ..type = 'image'
              ..folderId = _selectedFolder!.id
              ..title = title
              ..imageUrl = image.path
              ..content = memo.isEmpty ? null : memo
              ..tags = List.from(_tags)
              ..createdAt = DateTime.now();
        await DBService.saveContentToFolder(content);
      }
    }

    if (mounted) {
      setState(() => _saving = false);
      widget.onSaved?.call();
      Navigator.of(context).pop();
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Pretendard')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: Text(_isEditing ? '수정' : '저장', style: AppTextStyles.headline2),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 이미지 ──
                    const Text(
                      '이미지',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ImagePickerRow(
                      images: _images,
                      maxImages: _maxImages,
                      onAdd: _addImage,
                      onRemove: _removeImage,
                    ),
                    const SizedBox(height: 20),

                    // ── 제목 ──
                    const Text(
                      '제목',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _titleCtrl,
                      hint: '제목을 입력해주세요.',
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // ── 저장 폴더 ──
                    if (_loadingFolders)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else
                      FolderSelector(
                        folders: _folders,
                        selectedFolder: _selectedFolder,
                        onSelect: (f) => setState(() => _selectedFolder = f),
                        onAddFolder: _createFolder,
                      ),
                    const SizedBox(height: 20),

                    // ── 메모 ──
                    MemoField(
                      controller: _memoCtrl,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // ── 태그 ──
                    TagInputRow(
                      tags: _tags,
                      onAdd: _showAddTagDialog,
                      onRemove: (i) => setState(() => _tags.removeAt(i)),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── 저장 버튼 ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: SaveButton(enabled: _canSave && !_saving, onTap: _save),
            ),
          ],
        ),
      ),
    );
  }
}

/// 이미지 추가 영역 — 추가 버튼 + 첨부된 이미지 썸네일 가로 스크롤
class _ImagePickerRow extends StatelessWidget {
  const _ImagePickerRow({
    required this.images,
    required this.maxImages,
    required this.onAdd,
    required this.onRemove,
  });

  final List<XFile> images;
  final int maxImages;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  static const double _itemSize = 88.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemSize,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 추가 버튼 (이미지가 최대 개수 미만일 때만 표시)
          if (images.length < maxImages)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: _itemSize,
                height: _itemSize,
                margin: const EdgeInsets.only(right: 10),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: const Color(0xFFCCCCCC),
                    radius: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 28,
                        color: Color(0xFFAAAAAA),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '사진 첨부',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                      Text(
                        '${images.length}/$maxImages',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 10,
                          color: Color(0xFFAAAAAA),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 첨부된 이미지 썸네일
          ...images.asMap().entries.map(
            (e) => _ImageThumbnail(
              image: e.value,
              index: e.key,
              onRemove: () => onRemove(e.key),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({
    required this.image,
    required this.index,
    required this.onRemove,
  });

  final XFile image;
  final int index;
  final VoidCallback onRemove;

  static const double _size = 88.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRemoveDialog(context),
      child: Container(
        width: _size,
        height: _size,
        margin: const EdgeInsets.only(right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(image.path), fit: BoxFit.cover),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '이미지 삭제',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              '첨부된 이미지를 삭제하시겠습니까?',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  overlayColor: Colors.transparent,
                ),
                child: const Text(
                  '취소',
                  style: TextStyle(fontFamily: 'Pretendard'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onRemove();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  overlayColor: Colors.transparent,
                ),
                child: const Text(
                  '삭제',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}

/// 공통 단일 라인 입력 필드
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
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
