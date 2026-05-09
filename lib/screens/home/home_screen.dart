import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/content.dart';
import '../../models/folder_item.dart';
import '../../models/home_section.dart';
import '../../services/db_service.dart';
import '../../services/home_settings_service.dart';
import '../../shared/widgets/section_header.dart';
import '../in_folder/in_folder_screen.dart';
import '../content_detail/content_detail_screen.dart';
import './widgets/stats_card.dart';
import './widgets/banner_card.dart';
import './widgets/page_dots.dart';
import './widgets/recent_saved_list.dart';
import './widgets/folder_list_preview.dart';

/// 홈 화면
/// AppBar(고정) + ScrollView(통계 카드, 배너, 섹션들) 구조
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<FolderItem> _folders = [];
  List<Content> _recentContents = [];
  int _totalCount = 0;

  /// 홈화면에 표시할 섹션 목록 (HomeSettingsService에서 로드)
  List<HomeSection> _activeSections = [];

  Map<int, FolderItem> get _folderMap => {for (final f in _folders) f.id: f};

  static const double _bannerHeight = 72.0;
  static const double _bannerOverlap = 36.0;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    final results = await Future.wait([
      DBService.getFolders(),
      DBService.getRecentContents(limit: 10),
      DBService.getTotalContentCount(),
      HomeSettingsService.load(),
    ]);
    if (mounted) {
      setState(() {
        _folders = results[0] as List<FolderItem>;
        _recentContents = results[1] as List<Content>;
        _totalCount = results[2] as int;
        _activeSections = results[3] as List<HomeSection>;
      });
    }
  }

  void _openContent(Content content, FolderItem? folder) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder:
                (_) => ContentDetailScreen(
                  item: content,
                  folderName: folder?.name ?? '',
                ),
          ),
        )
        .then((_) => refresh());
  }

  void _openFolder(FolderItem folder) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => InFolderScreen(folder: folder)))
        .then((_) => refresh());
  }

  // ── 섹션 빌더 ────────────────────────────────────────────────────
  /// [HomeSection]에 따라 알맞은 위젯을 반환합니다.
  /// 새 섹션 추가 시 case를 추가하면 됩니다.
  Widget _buildSection(HomeSection section) {
    switch (section) {
      case HomeSection.recentSaved:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '최근 저장', topPadding: 12),
            RecentSavedList(
              items: _recentContents,
              folderMap: _folderMap,
              onTap: _openContent,
            ),
          ],
        );

      case HomeSection.folderList:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '내 폴더', topPadding: 20),
            FolderListPreview(folders: _folders, onTap: _openFolder),
          ],
        );

      case HomeSection.imageList:
        // 이미지 타입 콘텐츠만 필터링
        final images = _recentContents.where((c) => c.type == 'image').toList();
        if (images.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '이미지 목록', topPadding: 20),
            RecentSavedList(
              items: images,
              folderMap: _folderMap,
              onTap: _openContent,
            ),
          ],
        );

      case HomeSection.linkList:
        // 링크 타입 콘텐츠만 필터링
        final links = _recentContents.where((c) => c.type == 'link').toList();
        if (links.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '링크 목록', topPadding: 20),
            RecentSavedList(
              items: links,
              folderMap: _folderMap,
              onTap: _openContent,
            ),
          ],
        );

      case HomeSection.noteList:
        // 노트(메모) 타입 콘텐츠만 필터링
        final notes = _recentContents.where((c) => c.type == 'memo').toList();
        if (notes.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: '노트 목록', topPadding: 20),
            RecentSavedList(
              items: notes,
              folderMap: _folderMap,
              onTap: _openContent,
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar 없음: 타이틀이 스크롤과 함께 움직임
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 상단 보라 배경 영역 (타이틀 + 통계 카드 + 배너 상단 절반) ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 보라 배경 컨테이너
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    _bannerOverlap + 12,
                  ),
                  child: Column(
                    children: [
                      // Storoo 타이틀 (스크롤과 함께 움직임)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: Text(
                            'Storoo',
                            style: AppTextStyles.storooTitle,
                          ),
                        ),
                      ),
                      StatsCard(totalCount: _totalCount),
                    ],
                  ),
                ),
                // 배너: Positioned(bottom: -_bannerOverlap)으로 경계를 가로질러 걸침
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: -_bannerOverlap,
                  height: _bannerHeight,
                  child: const BannerCard(),
                ),
              ],
            ),
            // 배너 하단 절반이 흰 영역에 걸치도록 공간 확보
            SizedBox(height: _bannerOverlap + 12),

            // ── 페이지 도트 ──
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: PageDots(count: 3, activeIndex: 0),
            ),

            // ── 사용자 설정 섹션 목록 ──────────────────────────────
            // HomeSettingsService.load()로 불러온 _activeSections 순서대로 렌더링
            ..._activeSections.map((section) => _buildSection(section)),

            const SizedBox(height: 100), // 하단 네비게이션 바 여백
          ],
        ),
      ),
    );
  }
}
