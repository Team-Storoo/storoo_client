import 'package:flutter/material.dart';
import '../../models/content.dart';
import '../../models/folder_item.dart';
import '../../services/db_service.dart';
import '../../services/og_meta_service.dart';
import '../folder/widgets/create_folder_dialog.dart';
import '../save/widgets/tag_input_row.dart';
import 'widgets/share_save_body.dart';
import 'widgets/share_save_header.dart';

/// 외부 앱에서 공유 시 표시되는 저장 시트
/// SRP: 상태 관리 및 DB 저장 로직만 담당
class ShareSaveScreen extends StatefulWidget {
  const ShareSaveScreen({
    super.key,
    this.type = 'link',
    this.initialUrl,
    this.initialNote,
    this.imageFilePaths = const [],
    this.onSaved,
  });

  /// 공유 타입: "link" | "note" | "image"
  final String type;
  final String? initialUrl;
  final String? initialNote;
  final List<String> imageFilePaths;
  final VoidCallback? onSaved;

  static Future<void> show(
    BuildContext context, {
    String type = 'link',
    String? initialUrl,
    String? initialNote,
    List<String> imageFilePaths = const [],
    VoidCallback? onSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.88,
        child: ShareSaveScreen(
          type: type,
          initialUrl: initialUrl,
          initialNote: initialNote,
          imageFilePaths: imageFilePaths,
          onSaved: onSaved,
        ),
      ),
    );
  }

  @override
  State<ShareSaveScreen> createState() => _ShareSaveScreenState();
}

class _ShareSaveScreenState extends State<ShareSaveScreen> {
  final _titleCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();

  List<FolderItem> _folders = [];
  FolderItem? _selectedFolder;
  final List<String> _tags = [];
  bool _loadingFolders = true;
  bool _saving = false;

  /// 저장 버튼 전까지 DB에 반영하지 않는 임시 폴더 목록
  final List<FolderItem> _pendingFolders = [];

  static const int _maxFolders = 5;

  bool get _canSave =>
      _titleCtrl.text.trim().isNotEmpty && _selectedFolder != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl.addListener(() => setState(() {}));
    _loadFolders();
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
        _selectedFolder = folders.isNotEmpty ? folders.first : null;
        _loadingFolders = false;
      });
    }
  }

  Future<void> _createFolder() async {
    if (_folders.length >= _maxFolders) return;
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreateFolderDialog(),
    );
    if (name == null || name.isEmpty || !mounted) return;
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

  Future<void> _save() async {
    if (_saving || !_canSave) return;
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

    final Content content;
    final memo = _memoCtrl.text.trim();

    if (widget.type == 'image') {
      // ── 이미지 저장: 다중 경로를 Content 1개에 저장 ──────────
      final paths = widget.imageFilePaths;
      content = Content()
        ..type = 'image'
        ..folderId = _selectedFolder!.id
        ..title = _titleCtrl.text.trim()
        ..imageUrl = paths.join('\n')
        ..content = memo.isEmpty ? null : memo
        ..tags = List.from(_tags)
        ..createdAt = DateTime.now();
    } else if (widget.type == 'note') {
      // ── 노트 저장 (메모 없음) ───────────────────────────────────
      content = Content()
        ..type = 'memo'
        ..folderId = _selectedFolder!.id
        ..title = _titleCtrl.text.trim()
        ..content = widget.initialNote?.trim()
        ..tags = List.from(_tags)
        ..createdAt = DateTime.now();
    } else {
      // ── 링크 저장 (기본) ────────────────────────────────────────
      final url = widget.initialUrl?.trim();
      OgMeta? meta;
      if (url != null && url.isNotEmpty) {
        meta = await OgMetaService.fetch(url);
      }
      content = Content()
        ..type = 'link'
        ..folderId = _selectedFolder!.id
        ..title = _titleCtrl.text.trim()
        ..url = url
        ..description = meta?.title
        ..imageUrl = meta?.imageUrl
        ..content = memo.isEmpty ? null : memo
        ..tags = List.from(_tags)
        ..createdAt = DateTime.now();
    }

    await DBService.saveContentToFolder(content);

    if (mounted) {
      setState(() => _saving = false);
      widget.onSaved?.call();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShareSaveHeader(
          canSave: _canSave && !_saving,
          isSaving: _saving,
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: _save,
        ),
        Expanded(
          child: ShareSaveBody(
            type: widget.type,
            imageFilePaths: widget.imageFilePaths,
            folders: _folders,
            selectedFolder: _selectedFolder,
            onSelectFolder: (f) => setState(() => _selectedFolder = f),
            onAddFolder: _createFolder,
            titleController: _titleCtrl,
            onTitleChanged: () => setState(() {}),
            memoController: _memoCtrl,
            onMemoChanged: () => setState(() {}),
            tags: _tags,
            onAddTag: _showAddTagDialog,
            onRemoveTag: (i) => setState(() => _tags.removeAt(i)),
            loadingFolders: _loadingFolders,
          ),
        ),
      ],
    );
  }
}
