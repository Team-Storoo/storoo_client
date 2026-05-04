import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/content.dart';
import '../../models/folder_item.dart';
import '../../services/db_service.dart';
import '../save/save_content_sheet.dart';
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

  const InFolderScreen({
    super.key,
    required this.folder,
    this.initialTab = 0,
    this.initialQuery = '',
  });

  @override
  State<InFolderScreen> createState() => _InFolderScreenState();
}

class _InFolderScreenState extends State<InFolderScreen> {
  late int _selectedTab;
  InFolderSort _sort = InFolderSort.newest;
  late final TextEditingController _searchCtrl;
  late String _searchQuery;

  List<Content> _links = [];
  List<Content> _images = [];
  List<Content> _memos = [];

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
    final images = await DBService.getContentsByFolder(widget.folder.id, 'image');
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

  List<Content> _filtered(List<Content> items) {
    List<Content> result = _searchQuery.isEmpty
        ? List<Content>.from(items)
        : items.where((c) {
            final q = _searchQuery.toLowerCase();
            return c.title.toLowerCase().contains(q) ||
                (c.url?.toLowerCase().contains(q) ?? false) ||
                (c.content?.toLowerCase().contains(q) ?? false);
          }).toList();

    if (_sort == InFolderSort.oldest) {
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return result;
  }

  int get _currentCount {
    switch (_selectedTab) {
      case 0: return _filtered(_links).length;
      case 1: return _filtered(_images).length;
      case 2: return _filtered(_memos).length;
      default: return 0;
    }
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return InFolderLinkList(
          items: _filtered(_links),
          onDelete: _deleteContent,
        );
      case 1:
        return InFolderImageGrid(
          items: _filtered(_images),
          onDelete: _deleteContent,
        );
      case 2:
        return InFolderMemoList(
          items: _filtered(_memos),
          onDelete: _deleteContent,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _openSaveSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveContentSheet(
        folderId: widget.folder.id,
        folderName: widget.folder.name,
        onSaved: _loadContents,
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
        backgroundColor: AppColors.background,
        floatingActionButton: FloatingActionButton(
          onPressed: _openSaveSheet,
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          title: Text(
            widget.folder.name,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          centerTitle: true,
          actions: [
            GestureDetector(
              onTap: () {},
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
              }),
            ),
            InFolderSearchBar(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            InFolderSortHeader(
              count: _currentCount,
              sort: _sort,
              onSortChanged: (s) => setState(() => _sort = s),
            ),
            Expanded(child: _buildTabContent()),
          ],
        ),
      ),
    );
  }
}
