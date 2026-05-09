import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/content.dart';
import '../../../models/folder_item.dart';
import '../../../services/db_service.dart';
import '../../../services/og_meta_service.dart';
import '../../folder/widgets/create_folder_dialog.dart';
import '../../../shared/widgets/confirm_discard_dialog.dart';
import '../widgets/folder_selector.dart';
import '../widgets/memo_field.dart';
import '../widgets/tag_input_row.dart';
import '../widgets/save_button.dart';
import '../../../shared/widgets/required_label.dart';

/// 링크 저장 / 수정 화면
/// 필수: 링크 URL, 제목, 저장 폴더
/// 선택: 메모(최대 200자), 태그
class SaveLinkScreen extends StatefulWidget {
  final VoidCallback? onSaved;
  final Content? initialContent;
  final FolderItem? initialFolder;

  const SaveLinkScreen({
    super.key,
    this.onSaved,
    this.initialContent,
    this.initialFolder,
  });

  @override
  State<SaveLinkScreen> createState() => _SaveLinkScreenState();
}

class _SaveLinkScreenState extends State<SaveLinkScreen> {
  final _linkCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();

  List<FolderItem> _folders = [];
  FolderItem? _selectedFolder;
  final List<String> _tags = [];
  bool _loadingFolders = true;
  bool _saving = false;

  /// 저장 버튼 누르기 전까지 DB에 저장하지 않는 임시 폴더 목록
  /// 뒤로가기 취소 시 자동으로 폐기됩니다.
  final List<FolderItem> _pendingFolders = [];

  static const int _maxFolders = 5;

  bool get _isEditing => widget.initialContent != null;

  /// 변경사항 여부 — 뒤로가기 확인 팝업 표시 조건
  bool get _hasChanges {
    if (_pendingFolders.isNotEmpty) return true;
    if (!_isEditing) {
      return _linkCtrl.text.isNotEmpty ||
          _titleCtrl.text.isNotEmpty ||
          _memoCtrl.text.isNotEmpty ||
          _tags.isNotEmpty;
    }
    final c = widget.initialContent!;
    return _linkCtrl.text.trim() != (c.url?.trim() ?? '') ||
        _titleCtrl.text.trim() != c.title.trim() ||
        _memoCtrl.text.trim() != (c.content?.trim() ?? '') ||
        _tags.length != c.tags.length ||
        _selectedFolder?.id != widget.initialFolder?.id;
  }

  bool get _canSave =>
      _linkCtrl.text.trim().isNotEmpty &&
      _titleCtrl.text.trim().isNotEmpty &&
      _selectedFolder != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final c = widget.initialContent!;
      _linkCtrl.text = c.url ?? '';
      _titleCtrl.text = c.title;
      _memoCtrl.text = c.content ?? '';
      _tags.addAll(c.tags);
    }
    _loadFolders();
    _linkCtrl.addListener(() => setState(() {}));
    _titleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _linkCtrl.dispose();
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
    // 실제 DB 저장은 _save() 호출 시 수행됩니다.
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

    if (_isEditing) {
      final c = widget.initialContent!;
      final oldFolderId = c.folderId;
      c.title = _titleCtrl.text.trim();
      c.url = _linkCtrl.text.trim();
      c.content = memo.isEmpty ? null : memo;
      c.tags = List.from(_tags);
      c.folderId = _selectedFolder!.id;
      if (oldFolderId != null && oldFolderId != c.folderId) {
        await DBService.moveContentToFolder(c, oldFolderId);
      } else {
        await DBService.updateContent(c);
      }
    } else {
      final url = _linkCtrl.text.trim();
      // OG 메타 자동 수집 (실패해도 저장 진행)
      final meta = await OgMetaService.fetch(url);
      final content =
          Content()
            ..type = 'link'
            ..folderId = _selectedFolder!.id
            ..title = _titleCtrl.text.trim()
            ..url = url
            ..description = meta.title
            ..imageUrl = meta.imageUrl
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
                      // ── 링크 ──
                      const RequiredLabel('링크'),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _linkCtrl,
                        hint: '링크를 넣어주세요.',
                        onChanged: () => setState(() {}),
                        keyboardType: TextInputType.url,
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

/// 공통 단일 라인 입력 필드
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      keyboardType: keyboardType,
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
