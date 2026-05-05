import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/content.dart';
import '../../models/folder_item.dart';
import '../../services/db_service.dart';
import '../in_folder/in_folder_screen.dart';
import 'widgets/search_bar_field.dart';

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

    final matchedContents = contents
        .where((c) =>
            c.title.toLowerCase().contains(q) ||
            (c.url?.toLowerCase().contains(q) ?? false) ||
            (c.content?.toLowerCase().contains(q) ?? false) ||
            (c.description?.toLowerCase().contains(q) ?? false))
        .where((c) => c.folderId != null && folderMap.containsKey(c.folderId))
        .map((c) => (content: c, folder: folderMap[c.folderId]!))
        .toList();

    setState(() {
      _folderResults = matchedFolders;
      _contentResults = matchedContents;
    });
  }

  void _goToFolder(FolderItem folder) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => InFolderScreen(folder: folder)),
    );
  }

  void _goToContent(FolderItem folder, Content content) {
    final tab = switch (content.type) {
      'image' => 1,
      'memo' => 2,
      _ => 0,
    };
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InFolderScreen(
          folder: folder,
          initialTab: tab,
          initialQuery: _query,
        ),
      ),
    );
  }

  bool get _hasResults =>
      _folderResults.isNotEmpty || _contentResults.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          '검색',
          style: AppTextStyles.headline1.copyWith(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          SearchBarField(controller: _ctrl, onChanged: _onSearch),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 48, color: AppColors.navUnselected),
            SizedBox(height: 12),
            Text('폴더명이나 저장된 내용을 검색해보세요', style: AppTextStyles.caption),
          ],
        ),
      );
    }

    if (!_hasResults) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48, color: AppColors.navUnselected),
            const SizedBox(height: 12),
            Text('"$_query" 검색 결과가 없어요', style: AppTextStyles.caption),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        if (_folderResults.isNotEmpty) ...[
          _SectionLabel(label: '폴더', count: _folderResults.length),
          ..._folderResults.map((f) => _FolderResultTile(
                folder: f,
                onTap: () => _goToFolder(f),
              )),
        ],
        if (_contentResults.isNotEmpty) ...[
          _SectionLabel(label: '폴더 내 항목', count: _contentResults.length),
          ..._contentResults.map((r) => _ContentResultTile(
                content: r.content,
                folderName: r.folder.name,
                onTap: () => _goToContent(r.folder, r.content),
              )),
        ],
      ],
    );
  }
}

// ── 섹션 레이블 ──────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              )),
          const SizedBox(width: 6),
          Text('$count',
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              )),
        ],
      ),
    );
  }
}

// ── 폴더 결과 타일 ────────────────────────────────────────────

class _FolderResultTile extends StatelessWidget {
  const _FolderResultTile({required this.folder, required this.onTap});

  final FolderItem folder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.folder_outlined, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(folder.name,
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                  const SizedBox(height: 2),
                  Text('저장된 항목 ${folder.itemCount}개',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── 콘텐츠 결과 타일 ──────────────────────────────────────────

class _ContentResultTile extends StatelessWidget {
  const _ContentResultTile({
    required this.content,
    required this.folderName,
    required this.onTap,
  });

  final Content content;
  final String folderName;
  final VoidCallback onTap;

  IconData get _typeIcon {
    switch (content.type) {
      case 'image':
        return Icons.image_outlined;
      case 'memo':
        return Icons.notes_outlined;
      default:
        return Icons.link;
    }
  }

  String get _typeLabel {
    switch (content.type) {
      case 'image':
        return '이미지';
      case 'memo':
        return '메모';
      default:
        return '링크';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_typeIcon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.folder_outlined,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          folderName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _typeLabel,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
