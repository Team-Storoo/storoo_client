import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../models/content.dart';
import '../../models/folder_item.dart';
import '../../services/db_service.dart';

class ContentDetailScreen extends StatefulWidget {
  final Content item;
  final String folderName;

  const ContentDetailScreen({
    super.key,
    required this.item,
    required this.folderName,
  });

  @override
  State<ContentDetailScreen> createState() => _ContentDetailScreenState();
}

class _ContentDetailScreenState extends State<ContentDetailScreen> {
  late Content _item;
  late String _folderName;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _folderName = widget.folderName;
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _copyUrl(url);
      }
    } catch (_) {
      _copyUrl(url);
    }
  }

  void _copyUrl(String url) {
    Clipboard.setData(ClipboardData(text: url));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('링크를 열 수 없어 클립보드에 복사했어요.')),
      );
    }
  }

  // ── 제목 편집 ──────────────────────────────────────────────
  Future<void> _editTitle() async {
    final ctrl = TextEditingController(text: _item.title);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _EditDialog(
        title: '제목 수정',
        controller: ctrl,
        maxLines: 1,
      ),
    );
    if (result == null) return;
    _item.title = result.trim().isEmpty ? _item.title : result.trim();
    await DBService.updateContent(_item);
    setState(() => _changed = true);
  }

  // ── 메모 편집 ──────────────────────────────────────────────
  Future<void> _editMemo() async {
    final ctrl = TextEditingController(text: _item.content ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _EditDialog(
        title: '메모 수정',
        controller: ctrl,
        maxLines: 6,
      ),
    );
    if (result == null) return;
    _item.content = result.trim().isEmpty ? null : result.trim();
    await DBService.updateContent(_item);
    setState(() => _changed = true);
  }

  // ── 태그 편집 ──────────────────────────────────────────────
  Future<void> _editTags() async {
    final tags = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TagEditSheet(initialTags: List<String>.from(_item.tags)),
    );
    if (tags == null) return;
    _item.tags = tags;
    await DBService.updateContent(_item);
    setState(() => _changed = true);
  }

  // ── 저장 폴더 편집 ────────────────────────────────────────
  Future<void> _editFolder() async {
    final folders = await DBService.getFolders();
    if (!mounted) return;
    final result = await showModalBottomSheet<FolderItem>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FolderSelectSheet(
        folders: folders,
        currentFolderId: _item.folderId,
      ),
    );
    if (result == null || result.id == _item.folderId) return;
    final oldFolderId = _item.folderId!;
    _item.folderId = result.id;
    await DBService.moveContentToFolder(_item, oldFolderId);
    setState(() {
      _folderName = result.name;
      _changed = true;
    });
  }

  // ── 썸네일 위젯 ───────────────────────────────────────────
  Widget _buildThumbnail({double size = 80}) {
    final imageUrl = _item.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      final img = imageUrl.startsWith('http')
          ? Image.network(imageUrl, width: size, height: size, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _thumbPlaceholder(size))
          : Image.file(File(imageUrl), width: size, height: size, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _thumbPlaceholder(size));
      return ClipRRect(borderRadius: BorderRadius.circular(10), child: img);
    }
    return _thumbPlaceholder(size);
  }

  Widget _thumbPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.link, color: AppColors.primary, size: 32),
    );
  }

  // ── 링크 미리보기 카드 ─────────────────────────────────────
  Widget _buildLinkPreviewCard() {
    final url = _item.url ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(size: 80),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_item.description != null && _item.description!.isNotEmpty)
                  Text(
                    _item.description!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  )
                else
                  Text(
                    url,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: url.isNotEmpty ? () => _launchUrl(url) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '바로 이동 >',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 이미지 미리보기 ─────────────────────────────────────────
  Widget _buildImagePreview() {
    final imageUrl = _item.imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14)),
      child: imageUrl.startsWith('http')
          ? Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover)
          : Image.file(File(imageUrl), width: double.infinity, fit: BoxFit.cover),
    );
  }

  // ── 섹션 헤더 ──────────────────────────────────────────────
  Widget _sectionHeader(String label, VoidCallback onEdit) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onEdit,
          behavior: HitTestBehavior.opaque,
          child: const Text(
            '수정',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
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
            automaticallyImplyLeading: false,
            leading: GestureDetector(
              onTap: () => Navigator.of(context).pop(_changed),
              behavior: HitTestBehavior.opaque,
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 링크: 미리보기 카드
                if (_item.type == 'link') _buildLinkPreviewCard(),

                // 이미지: 풀 이미지
                if (_item.type == 'image') _buildImagePreview(),

                // ── 제목 ──────────────────────────────────
                _sectionHeader('제목', _editTitle),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _item.title,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── 메모 (링크의 경우 content 필드) ───────
                _sectionHeader('메모', _editMemo),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (_item.content?.isNotEmpty == true)
                        ? _item.content!
                        : '메모가 없습니다.',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      color: (_item.content?.isNotEmpty == true)
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── 태그 ──────────────────────────────────
                _sectionHeader('태그', _editTags),
                const SizedBox(height: 12),
                _item.tags.isEmpty
                    ? const Text(
                        '태그가 없습니다.',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _item.tags
                            .map((tag) => _TagChip(tag: tag))
                            .toList(),
                      ),

                const SizedBox(height: 24),

                // ── 저장 폴더 ──────────────────────────────
                _sectionHeader('저장 폴더', _editFolder),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.folder_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _folderName,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

// ── 태그 칩 ────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 13,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── 텍스트 편집 다이얼로그 ─────────────────────────────────────

class _EditDialog extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final int maxLines;

  const _EditDialog({
    required this.title,
    required this.controller,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: maxLines,
              autofocus: true,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F8F8),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    overlayColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(fontFamily: 'Pretendard', fontSize: 14),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(controller.text),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    overlayColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 태그 편집 바텀 시트 ─────────────────────────────────────────

class _TagEditSheet extends StatefulWidget {
  final List<String> initialTags;
  const _TagEditSheet({required this.initialTags});

  @override
  State<_TagEditSheet> createState() => _TagEditSheetState();
}

class _TagEditSheetState extends State<_TagEditSheet> {
  late List<String> _tags;
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _showInput = false;

  static const int _maxTags = 10;

  @override
  void initState() {
    super.initState();
    _tags = List<String>.from(widget.initialTags);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _ctrl.text.trim();
    if (tag.isEmpty) {
      setState(() => _showInput = false);
      return;
    }
    if (_tags.contains(tag)) {
      setState(() {
        _showInput = false;
        _ctrl.clear();
      });
      return;
    }
    if (_tags.length >= _maxTags) return;
    setState(() {
      _tags.add(tag);
      _ctrl.clear();
      _showInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottom + 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              '태그 수정',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ..._tags.map((tag) => _EditableTagChip(
                    tag: tag,
                    onRemove: () => setState(() => _tags.remove(tag)),
                  )),
              if (_showInput)
                SizedBox(
                  width: 130,
                  height: 36,
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _addTag(),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: '태그 입력',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                )
              else if (_tags.length < _maxTags)
                GestureDetector(
                  onTap: () {
                    setState(() => _showInput = true);
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _focus.requestFocus(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: AppColors.primary, size: 14),
                        SizedBox(width: 4),
                        Text(
                          '태그 추가',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_tags),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '저장',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableTagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;
  const _EditableTagChip({required this.tag, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 7, bottom: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$tag',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close, color: AppColors.primary, size: 14),
          ),
        ],
      ),
    );
  }
}

// ── 폴더 선택 바텀 시트 ────────────────────────────────────────

class _FolderSelectSheet extends StatefulWidget {
  final List<FolderItem> folders;
  final int? currentFolderId;

  const _FolderSelectSheet({
    required this.folders,
    required this.currentFolderId,
  });

  @override
  State<_FolderSelectSheet> createState() => _FolderSelectSheetState();
}

class _FolderSelectSheetState extends State<_FolderSelectSheet> {
  late int? _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentFolderId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              '저장 폴더 변경',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.4,
            ),
            itemCount: widget.folders.length,
            itemBuilder: (_, i) {
              final folder = widget.folders[i];
              final selected = _selectedId == folder.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedId = folder.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primaryLight
                        : const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppColors.primary : AppColors.divider,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        color: selected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          folder.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                final folder = widget.folders.firstWhere(
                  (f) => f.id == _selectedId,
                  orElse: () => widget.folders.first,
                );
                Navigator.of(context).pop(folder);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '확인',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
