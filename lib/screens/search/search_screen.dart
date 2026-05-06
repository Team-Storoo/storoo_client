import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/content.dart';
import '../../models/folder_item.dart';
import '../../services/db_service.dart';
import '../content_detail/content_detail_screen.dart';
import '../in_folder/in_folder_screen.dart';
import 'widgets/search_bar_field.dart';
import 'widgets/search_content_tile.dart';
import 'widgets/search_empty_view.dart';
import 'widgets/search_folder_tile.dart';
import 'widgets/search_section_label.dart';

/// 검색 화면 — 쿼리 상태 관리 + 결과 라우팅만 담당 (SOLID: SRP)
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = '';

  List<FolderItem> _folderResults = [];
  List<({Content content, FolderItem folder})> _contentResults = [];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── 검색 로직 ────────────────────────────────────────────

  Future<void> _onSearch(String raw) async {
    final q = raw.trim().toLowerCase();
    setState(() => _query = q);

    if (q.isEmpty) {
      setState(() {
        _folderResults = [];
        _contentResults = [];
      });
      return;
    }

    final folders = await DBService.getFolders();
    final contents = await DBService.getAllActiveContents();
    if (!mounted) return;

    final folderMap = {for (final f in folders) f.id: f};

    final matchedFolders =
        folders.where((f) => f.name.toLowerCase().contains(q)).toList();

    final matchedContents =
        contents
            .where(
              (c) =>
                  c.title.toLowerCase().contains(q) ||
                  (c.url?.toLowerCase().contains(q) ?? false) ||
                  (c.content?.toLowerCase().contains(q) ?? false) ||
                  (c.description?.toLowerCase().contains(q) ?? false) ||
                  c.tags.any((t) => t.toLowerCase().contains(q)),
            )
            .where(
              (c) => c.folderId != null && folderMap.containsKey(c.folderId),
            )
            .map((c) => (content: c, folder: folderMap[c.folderId]!))
            .toList();

    setState(() {
      _folderResults = matchedFolders;
      _contentResults = matchedContents;
    });
  }

  // ── 네비게이션 ────────────────────────────────────────────

  void _goToFolder(FolderItem folder) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => InFolderScreen(folder: folder)));
  }

  /// 폴더 화면 + 상세 화면을 함께 push
  /// Back 스택: 검색 → 폴더 → 상세
  void _goToContent(FolderItem folder, Content content) {
    final tab = switch (content.type) {
      'image' => 1,
      'memo' => 2,
      _ => 0,
    };
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InFolderScreen(folder: folder, initialTab: tab),
      ),
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (_) => ContentDetailScreen(item: content, folderName: folder.name),
      ),
    );
  }

  // ── 빌드 ──────────────────────────────────────────────────

  bool get _hasResults =>
      _folderResults.isNotEmpty || _contentResults.isNotEmpty;

  int get _totalCount => _folderResults.length + _contentResults.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEEEEE),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Text('검색', style: AppTextStyles.headline1),
                ),
                SearchBarField(controller: _ctrl, onChanged: _onSearch),
                if (_query.isNotEmpty && _hasResults)
                  _SearchResultCount(count: _totalCount),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) return const SearchEmptyView.initial();
    if (!_hasResults) return SearchEmptyView.noResults(query: _query);

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (_folderResults.isNotEmpty) ...[
          SearchSectionLabel(label: '폴더', count: _folderResults.length),
          ..._folderResults.map(
            (f) => SearchFolderTile(folder: f, onTap: () => _goToFolder(f)),
          ),
        ],
        if (_contentResults.isNotEmpty) ...[
          SearchSectionLabel(label: '폴더 내 항목', count: _contentResults.length),
          ..._contentResults.map(
            (r) => SearchContentTile(
              content: r.content,
              folderName: r.folder.name,
              onTap: () => _goToContent(r.folder, r.content),
            ),
          ),
        ],
      ],
    );
  }
}

// ── 검색결과 총 개수 표시 ─────────────────────────────────────

class _SearchResultCount extends StatelessWidget {
  const _SearchResultCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          const Text(
            '검색결과 ',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
