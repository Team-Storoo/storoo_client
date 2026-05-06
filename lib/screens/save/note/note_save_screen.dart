import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/content.dart';
import '../../../models/folder_item.dart';
import '../../../services/db_service.dart';
import '../../folder/widgets/create_folder_dialog.dart';
import '../widgets/folder_selector.dart';
import '../widgets/memo_field.dart';
import '../widgets/tag_input_row.dart';
import '../widgets/save_button.dart';

/// 노트 저장 / 수정 화면
/// 필수: 노트 내용, 제목, 저장 폴더
/// 선택: 메모(최대 200자), 태그
class SaveNoteScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  final Content? initialContent;
  final FolderItem? initialFolder;

  const SaveNoteScreen({
    super.key,
    this.onSaved,
    this.initialContent,
    this.initialFolder,
  });

  @override
  State<SaveNoteScreen> createState() => _SaveNoteScreenState();
}

class _SaveNoteScreenState extends State<SaveNoteScreen> {
  final _noteCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();

  List<FolderItem> _folders = [];
  FolderItem? _selectedFolder;
  final List<String> _tags = [];
  bool _loadingFolders = true;
  bool _saving = false;

  static const int _maxFolders = 5;

  bool get _isEditing => widget.initialContent != null;

  bool get _canSave =>
      _noteCtrl.text.trim().isNotEmpty &&
      _titleCtrl.text.trim().isNotEmpty &&
      _selectedFolder != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.initialContent!;
      _noteCtrl.text = c.content ?? '';
      _titleCtrl.text = c.title;
      _tags.addAll(c.tags);
    }
    _loadFolders();
    _noteCtrl.addListener(() => setState(() {}));
    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
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

  Future<void> _showAddTagDialog() async {
    final tag = await TagAddDialog.show(context);
    if (tag == null || tag.isEmpty) return;
    setState(() => _tags.add(tag));
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    if (_isEditing) {
      final c = widget.initialContent!;
      final oldFolderId = c.folderId;
      c.title = _titleCtrl.text.trim();
      c.content = _noteCtrl.text.trim();
      c.tags = List.from(_tags);
      c.folderId = _selectedFolder!.id;
      if (oldFolderId != null && oldFolderId != c.folderId) {
        await DBService.moveContentToFolder(c, oldFolderId);
      } else {
        await DBService.updateContent(c);
      }
    } else {
      final content =
          Content()
            ..type = 'memo'
            ..folderId = _selectedFolder!.id
            ..title = _titleCtrl.text.trim()
            ..content = _noteCtrl.text.trim()
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
                    // ── 노트 ──
                    const Text(
                      '노트',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 6,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: '내용을 입력해주세요.',
                        hintStyle: AppTextStyles.caption,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
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
