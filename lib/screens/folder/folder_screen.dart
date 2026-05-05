import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '/models/folder_item.dart';
import '../in_folder/in_folder_screen.dart';
import './widgets/folder_filter_row.dart';
import './widgets/folder_grid.dart';
import './widgets/create_folder_dialog.dart';
import '../../services/db_service.dart';

/// 폴더 화면
/// DB에 저장된 폴더 목록 관리
class FolderScreen extends StatefulWidget {
  final VoidCallback? onContentSaved;

  const FolderScreen({super.key, this.onContentSaved});

  @override
  State<FolderScreen> createState() => FolderScreenState();
}

class FolderScreenState extends State<FolderScreen> {
  // ── 상태 ────────────────────────────────────────────────────────────
  List<FolderItem> _folders = [];
  List<FolderItem> _customOrderedFolders = [];
  FolderSortFilter _filter = FolderSortFilter.total;

  // ── 초기화 ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  // ── 데이터 로드 ─────────────────────────────────────────────────────
  Future<void> refresh() => _loadFolders();

  Future<void> _loadFolders() async {
    final results = await Future.wait([
      DBService.getFolders(),
      DBService.getCustomFolderOrder(),
    ]);
    final folders = results[0] as List<FolderItem>;
    final orderedIds = results[1] as List<int>;
    if (!mounted) return;
    setState(() {
      _folders = folders;
      _customOrderedFolders = _buildCustomOrder(folders, orderedIds);
    });
  }

  // ── 사용자 지정 순서 ────────────────────────────────────────────────
  List<FolderItem> _buildCustomOrder(List<FolderItem> folders, List<int> orderedIds) {
    if (orderedIds.isEmpty) return List.from(folders);
    final map = {for (final f in folders) f.id: f};
    final ordered = orderedIds.where(map.containsKey).map((id) => map[id]!).toList();
    final remaining = folders.where((f) => !orderedIds.contains(f.id)).toList();
    return [...ordered, ...remaining];
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      final item = _customOrderedFolders.removeAt(oldIndex);
      _customOrderedFolders.insert(newIndex, item);
    });
    await DBService.saveCustomFolderOrder(
      _customOrderedFolders.map((f) => f.id).toList(),
    );
  }

  // ── 폴더 CRUD ───────────────────────────────────────────────────────
  Future<void> _showCreateDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreateFolderDialog(),
    );

    if (!mounted) return;
    if (name == null || name.isEmpty) return;

    if (_folders.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('폴더는 최대 5개까지만 만들 수 있어요')),
      );
      return;
    }

    final folder = FolderItem()
      ..name = name
      ..createdAt = DateTime.now();

    await DBService.saveFolder(folder);
    await _loadFolders();
  }

  Future<void> _renameFolder(FolderItem folder) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => CreateFolderDialog(initialName: folder.name, isRename: true),
    );
    if (!mounted) return;
    if (name == null || name.isEmpty || name == folder.name) return;
    folder.name = name;
    await DBService.saveFolder(folder);
    await _loadFolders();
  }

  Future<void> _deleteFolder(FolderItem folder) async {
    await DBService.deleteFolder(folder.id);
    await _loadFolders();
  }

  // ── 정렬 ────────────────────────────────────────────────────────────
  List<FolderItem> get _sorted {
    switch (_filter) {
      case FolderSortFilter.name:
        return List<FolderItem>.from(_folders)..sort((a, b) => a.name.compareTo(b.name));
      case FolderSortFilter.recent:
        return List<FolderItem>.from(_folders)..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case FolderSortFilter.custom:
        return _customOrderedFolders;
      case FolderSortFilter.total:
        return List<FolderItem>.from(_folders);
    }
  }

  // ── 화면 빌드 ───────────────────────────────────────────────────────
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
          centerTitle: false,
          title: Text(
            '내 폴더',
            style: AppTextStyles.headline1.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            // 폴더 추가 버튼
            GestureDetector(
              onTap: _showCreateDialog,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Icon(Icons.add, color: AppColors.textPrimary),
              ),
            ),
            // 더보기 버튼 (미구현)
            GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(left: 4, right: 16, top: 12, bottom: 12),
                child: Icon(Icons.more_vert, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // 정렬 필터 행
            FolderFilterRow(
              total: _folders.length,
              selectedFilter: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
            // 폴더 그리드
            Expanded(
              child: FolderGrid(
                folders: _sorted,
                onAddTap: _showCreateDialog,
                onRenameTap: _renameFolder,
                onFolderTap: (folder) async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InFolderScreen(
                        folder: folder,
                        onContentSaved: widget.onContentSaved,
                      ),
                    ),
                  );
                  _loadFolders();
                },
                onDeleteTap: _deleteFolder,
                isReorderable: _filter == FolderSortFilter.custom,
                onReorder: _onReorder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
