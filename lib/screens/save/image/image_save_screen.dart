import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/content.dart';
import '../../../models/folder_item.dart';
import '../../../services/db_service.dart';
import '../../folder/widgets/create_folder_dialog.dart';
import '../../../shared/widgets/confirm_discard_dialog.dart';
import '../widgets/dashed_border.dart';
import '../widgets/folder_selector.dart';
import '../widgets/memo_field.dart';
import '../widgets/tag_input_row.dart';
import '../widgets/save_button.dart';
import '../../../shared/widgets/required_label.dart';

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

  /// 저장 버튼 누르기 전까지 DB에 저장하지 않는 임시 폴더 목록
  final List<FolderItem> _pendingFolders = [];

  static const int _maxFolders = 5;

  bool get _isEditing => widget.initialContent != null;

  /// 변경사항 여부 — 뒤로가기 확인 팝업 표시 조건
  bool get _hasChanges {
    if (_pendingFolders.isNotEmpty) return true;
    if (!_isEditing) {
      return _images.isNotEmpty ||
          _titleCtrl.text.isNotEmpty ||
          _memoCtrl.text.isNotEmpty ||
          _tags.isNotEmpty;
    }
    final c = widget.initialContent!;
    return _titleCtrl.text.trim() != c.title.trim() ||
        _memoCtrl.text.trim() != (c.content?.trim() ?? '') ||
        _tags.length != c.tags.length ||
        _selectedFolder?.id != widget.initialFolder?.id;
  }

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
      final urls = c.effectiveImageUrls;
      if (urls.isNotEmpty) {
        _images.addAll(urls.map(XFile.new));
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
        if (widget.initialFolder != null) {
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

    // 저장 버튼 누르기 전까지는 DB에 저장하지 않습니다.
    final tempFolder =
        FolderItem()
          ..name = name
          ..createdAt = DateTime.now()
          ..itemCount = 0;
    setState(() {
      _pendingFolders.add(tempFolder);
      _folders = [..._folders, tempFolder];
      _selectedFolder = tempFolder;
    });
  }

  void _addImage() async {
    if (_images.length >= _maxImages) return;
    try {
      final remaining = _maxImages - _images.length;
      final files = await ImagePicker().pickMultiImage(limit: remaining);
      if (files.isEmpty || !mounted) return;
      setState(() => _images.addAll(files.take(remaining)));
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

  /// 뒤로가기 시 변경사항 확인 후 팝업 표시
  Future<void> _maybePop() async {
    if (!_hasChanges) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await ConfirmDiscardDialog.show(context);
    if (discard && mounted) Navigator.of(context).pop();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    // 임시 폴더 전체 DB 저장 (여러 개 지원)
    if (_pendingFolders.isNotEmpty && mounted) {
      for (final folder in _pendingFolders) {
        await DBService.saveFolder(folder); // Isar가 id를 in-place 업데이트
      }
      final savedId = _selectedFolder?.id;
      final updated = await DBService.getFolders();
      if (!mounted) return;
      setState(() {
        _folders = updated;
        _selectedFolder = savedId != null
            ? updated.firstWhere((f) => f.id == savedId, orElse: () => updated.last)
            : updated.isNotEmpty ? updated.last : null;
        _pendingFolders.clear();
      });
    }

    final memo = _memoCtrl.text.trim();
    final title = _titleCtrl.text.trim();

    if (_isEditing) {
      final c = widget.initialContent!;
      final oldFolderId = c.folderId;
      c.title = title;
      c.content = memo.isEmpty ? null : memo;
      c.tags = List.from(_tags);
      c.folderId = _selectedFolder!.id;
      c.imageUrl = _images.map((e) => e.path).join('\n');
      if (oldFolderId != null && oldFolderId != c.folderId) {
        await DBService.moveContentToFolder(c, oldFolderId);
      } else {
        await DBService.updateContent(c);
      }
    } else {
      final content = Content()
        ..type = 'image'
        ..folderId = _selectedFolder!.id
        ..title = title
        ..imageUrl = _images.map((e) => e.path).join('\n')
        ..content = memo.isEmpty ? null : memo
        ..tags = List.from(_tags)
        ..createdAt = DateTime.now();
      await DBService.saveContentToFolder(content);
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
      child: PopScope(
        canPop: !_hasChanges,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          final discard = await ConfirmDiscardDialog.show(context);
          if (discard && context.mounted) Navigator.of(context).pop();
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: Text(
              _isEditing ? '수정' : '저장',
              style: AppTextStyles.headline2,
            ),
            leading: GestureDetector(
              onTap: _maybePop,
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
                      const RequiredLabel('이미지'),
                      const SizedBox(height: 12),
                      _ImagePickerRow(
                        images: _images,
                        maxImages: _maxImages,
                        onAdd: _addImage,
                        onRemove: _removeImage,
                      ),
                      const SizedBox(height: 20),

                      // ── 제목 ──
                      const RequiredLabel('제목'),
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
      ), // PopScope
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
