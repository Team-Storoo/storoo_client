import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/content.dart';
import '../../models/folder_item.dart';
import '../../services/db_service.dart';
import '../content_detail/content_detail_screen.dart';
import '../save/link/link_save_screen.dart';
import '../save/image/image_save_screen.dart';
import '../save/note/note_save_screen.dart';
import 'widgets/in_folder_tab_bar.dart';
import 'widgets/in_folder_search_bar.dart';
import 'widgets/in_folder_sort_header.dart';
import 'widgets/in_folder_link_list.dart';
import 'widgets/in_folder_image_grid.dart';
import 'widgets/in_folder_memo_list.dart';

class InFolderScreen extends StatefulWidget {
  final FolderItem folder;
  final int initialTab;
  final String initialQuery;
  final VoidCallback? onContentSaved;

  const InFolderScreen({
    super.key,
    required this.folder,
    this.initialTab = 0,
    this.initialQuery = '',
    this.onContentSaved,
  });

  @override
  State<InFolderScreen> createState() => _InFolderScreenState();
}

class _InFolderScreenState extends State<InFolderScreen> {
  late int _selectedTab;
  InFolderSort _sort = InFolderSort.relevant;
  late final TextEditingController _searchCtrl;
  late String _searchQuery;

  List<Content> _links = [];
  List<Content> _images = [];
  List<Content> _memos = [];

  bool _isEditMode = false;
  final Set<int> _selectedIds = {};
  Offset _moreMenuPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _searchQuery = widget.initialQuery;
    _searchCtrl = TextEditingController(text: widget.initialQuery);
    _loadContents();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadContents() async {
    final links = await DBService.getContentsByFolder(widget.folder.id, 'link');
    final images = await DBService.getContentsByFolder(
      widget.folder.id,
      'image',
    );
    final memos = await DBService.getContentsByFolder(widget.folder.id, 'memo');
    if (mounted) {
      setState(() {
        _links = links;
        _images = images;
        _memos = memos;
      });
    }
  }

  Future<void> _deleteContent(int contentId) async {
    await DBService.deleteContentAndSync(contentId, widget.folder.id);
    _loadContents();
  }

  // ── 편집 모드 ──────────────────────────────────────────────────────

  void _enterEditMode() {
    setState(() {
      _isEditMode = true;
      _selectedIds.clear();
      _searchCtrl.clear();
      _searchQuery = '';
    });
  }

  void _exitEditMode() {
    setState(() {
      _isEditMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _deleteSelected() async {
    final count = _selectedIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('항목 삭제'),
        content: Text('선택한 $count개의 항목을 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              '삭제',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    for (final id in List<int>.from(_selectedIds)) {
      await DBService.deleteContentAndSync(id, widget.folder.id);
    }
    _exitEditMode();
    _loadContents();
  }

  Future<void> _showMoreMenu() async {
    final size = MediaQuery.of(context).size;
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        _moreMenuPosition.dx,
        _moreMenuPosition.dy,
        size.width - _moreMenuPosition.dx,
        size.height - _moreMenuPosition.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      items: const [
        PopupMenuItem(
          value: 'edit',
          height: 44,
          child: Row(
            children: [
              Icon(Icons.checklist_outlined, size: 16, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                '편집',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
    if (result == 'edit') _enterEditMode();
  }

  // ── 필터 / 정렬 ────────────────────────────────────────────────────

  List<Content> _filtered(List<Content> items) {
    List<Content> result =
        _searchQuery.isEmpty
            ? List<Content>.from(items)
            : items.where((c) {
              final q = _searchQuery.toLowerCase();
              return c.title.toLowerCase().contains(q) ||
                  (c.url?.toLowerCase().contains(q) ?? false) ||
                  (c.content?.toLowerCase().contains(q) ?? false) ||
                  c.tags.any((t) => t.toLowerCase().contains(q));
            }).toList();

    switch (_sort) {
      case InFolderSort.newest:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case InFolderSort.oldest:
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case InFolderSort.relevant:
        break;
    }
    return result;
  }

  int get _currentCount {
    switch (_selectedTab) {
      case 0:
        return _filtered(_links).length;
      case 1:
        return _filtered(_images).length;
      case 2:
        return _filtered(_memos).length;
      default:
        return 0;
    }
  }

  Future<void> _openDetail(Content item) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder:
            (_) =>
                ContentDetailScreen(item: item, folderName: widget.folder.name),
      ),
    );
    if (changed == true) _loadContents();
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return InFolderLinkList(
          items: _filtered(_links),
          onDelete: _deleteContent,
          folderName: widget.folder.name,
          onTap: _openDetail,
          isEditMode: _isEditMode,
          selectedIds: _selectedIds,
          onToggleSelect: _toggleSelect,
        );
      case 1:
        return InFolderImageGrid(
          items: _filtered(_images),
          onDelete: _deleteContent,
          folderName: widget.folder.name,
          onTap: _openDetail,
          isEditMode: _isEditMode,
          selectedIds: _selectedIds,
          onToggleSelect: _toggleSelect,
        );
      case 2:
        return InFolderMemoList(
          items: _filtered(_memos),
          onDelete: _deleteContent,
          folderName: widget.folder.name,
          onTap: _openDetail,
          isEditMode: _isEditMode,
          selectedIds: _selectedIds,
          onToggleSelect: _toggleSelect,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _openSaveSheet() {
    void onSaved() {
      _loadContents();
      widget.onContentSaved?.call();
    }

    final Widget screen = switch (_selectedTab) {
      1 => SaveImageScreen(onSaved: onSaved, initialFolder: widget.folder),
      2 => SaveNoteScreen(onSaved: onSaved, initialFolder: widget.folder),
      _ => SaveLinkScreen(onSaved: onSaved, initialFolder: widget.folder),
    };

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  // ── 화면 빌드 ───────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isEditMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isEditMode) _exitEditMode();
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
        ),
        child: Scaffold(
          backgroundColor: AppColors.background,
          floatingActionButton: _isEditMode
              ? null
              : FloatingActionButton(
                  onPressed: _openSaveSheet,
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            leading: _isEditMode
                ? TextButton(
                    onPressed: _exitEditMode,
                    child: const Text(
                      '취소',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    behavior: HitTestBehavior.opaque,
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                      size: 24,
                    ),
                  ),
            title: Text(
              _isEditMode
                  ? (_selectedIds.isEmpty ? '항목 선택' : '${_selectedIds.length}개 선택됨')
                  : widget.folder.name,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            centerTitle: true,
            actions: _isEditMode
                ? [
                    TextButton(
                      onPressed: _selectedIds.isEmpty ? null : _deleteSelected,
                      child: Text(
                        '삭제',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          color: _selectedIds.isEmpty
                              ? AppColors.textSecondary
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ]
                : [
                    GestureDetector(
                      onTapDown: (d) => _moreMenuPosition = d.globalPosition,
                      onTap: _showMoreMenu,
                      behavior: HitTestBehavior.opaque,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(
                          Icons.more_vert,
                          color: AppColors.textPrimary,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
          ),
          body: Column(
            children: [
              InFolderTabBar(
                selectedIndex: _selectedTab,
                onTabChanged: (i) => setState(() {
                  _selectedTab = i;
                  _searchCtrl.clear();
                  _searchQuery = '';
                  if (_isEditMode) _selectedIds.clear();
                }),
              ),
              if (!_isEditMode) ...[
                InFolderSearchBar(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                InFolderSortHeader(
                  count: _currentCount,
                  sort: _sort,
                  onSortChanged: (s) => setState(() => _sort = s),
                  onFilterTap: () {},
                ),
              ],
              Expanded(child: _buildTabContent()),
            ],
          ),
        ),
      ),
    );
  }
}
