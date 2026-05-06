import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../models/content.dart';
import '../../models/folder_item.dart';
import '../../services/db_service.dart';
import '../save/link/link_save_screen.dart';
import '../save/image/image_save_screen.dart';
import '../save/note/note_save_screen.dart';
import 'widgets/detail_section_label.dart';
import 'widgets/detail_read_field.dart';
import 'widgets/detail_tag_chips.dart';
import 'widgets/detail_link_preview_card.dart';
import 'widgets/detail_image_carousel.dart';

/// 콘텐츠 상세 화면
/// 읽기 전용 뷰 — 수정은 AppBar [수정] 버튼으로 해당 save 스크린 재활용
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

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _folderName = widget.folderName;
  }

  // ── 링크 열기 ────────────────────────────────────────────────
  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _copyToClipboard(url);
      }
    } catch (_) {
      _copyToClipboard(url);
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('링크를 열 수 없어 클립보드에 복사했어요.')));
    }
  }

  // ── 수정 버튼 → 해당 save 스크린으로 이동 ─────────────────────
  Future<void> _onEdit() async {
    FolderItem? folder;
    if (_item.folderId != null) {
      folder = await DBService.getFolderById(_item.folderId!);
    }
    if (!mounted) return;

    final Widget screen = switch (_item.type) {
      'link' => SaveLinkScreen(initialContent: _item, initialFolder: folder),
      'image' => SaveImageScreen(initialContent: _item, initialFolder: folder),
      _ => SaveNoteScreen(initialContent: _item, initialFolder: folder),
    };

    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

    if (mounted) await _reload();
  }

  Future<void> _reload() async {
    final updated = await DBService.isar.contents.get(_item.id);
    if (updated == null || !mounted) return;
    final folder =
        updated.folderId != null
            ? await DBService.getFolderById(updated.folderId!)
            : null;
    if (!mounted) return;
    setState(() {
      _item = updated;
      if (folder != null) _folderName = folder.name;
    });
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
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          title: const Text(
            '상세',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: _onEdit,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '수정',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 타입별 상단 콘텐츠 ─────────────────────────
              if (_item.type == 'link')
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: DetailLinkPreviewCard(
                    item: _item,
                    onTap: () => _launchUrl(_item.url ?? ''),
                  ),
                ),

              if (_item.type == 'image' && _item.imageUrl?.isNotEmpty == true)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: DetailImageCarousel(imagePaths: [_item.imageUrl!]),
                ),

              if (_item.type == 'memo')
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 120),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      _item.content?.isNotEmpty == true
                          ? _item.content!
                          : '내용이 없습니다.',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        color:
                            _item.content?.isNotEmpty == true
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),

              // ── 제목 ─────────────────────────────────────
              const DetailSectionLabel(label: '제목'),
              const SizedBox(height: 10),
              DetailReadField(text: _item.title),
              const SizedBox(height: 22),

              // ── 메모 (링크·이미지만) ──────────────────────
              if (_item.type != 'memo') ...[
                const DetailSectionLabel(label: '메모'),
                const SizedBox(height: 10),
                DetailReadField(
                  text: _item.content ?? '',
                  placeholder: '저장된 메모가 없습니다.',
                  maxLines: 5,
                ),
                const SizedBox(height: 22),
              ],

              // ── 태그 ─────────────────────────────────────
              const DetailSectionLabel(label: '태그'),
              const SizedBox(height: 10),
              DetailTagChips(tags: _item.tags),
              const SizedBox(height: 22),

              // ── 저장 폴더 ──────────────────────────────────
              const DetailSectionLabel(label: '저장 폴더'),
              const SizedBox(height: 10),
              DetailReadField(text: _folderName),
            ],
          ),
        ),
      ),
    );
  }
}
