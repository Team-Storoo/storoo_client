import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/folder_item.dart';
import '../../services/db_service.dart';
import '../../shared/widgets/section_header.dart';
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

  static const double _bannerHeight = 72.0;
  static const double _bannerOverlap = 36.0;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    final folders = await DBService.getFolders();
    if (mounted) setState(() => _folders = folders);
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
                      const StatsCard(),
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

            // ── 최근 저장 섹션 ──
            const SectionHeader(title: '최근 저장', topPadding: 12),
            const RecentSavedList(),

            // ── 내 폴더 섹션 ──
            const SectionHeader(title: '내 폴더', topPadding: 20),
            FolderListPreview(folders: _folders),

            const SizedBox(height: 100), // 하단 네비게이션 바 여백
          ],
        ),
      ),
    );
  }
}
