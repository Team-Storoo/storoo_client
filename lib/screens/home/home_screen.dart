import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/section_header.dart';
import './widgets/stats_card.dart';
import './widgets/banner_card.dart';
import './widgets/page_dots.dart';
import './widgets/recent_saved_list.dart';
import './widgets/folder_list_preview.dart';

/// 홈 화면
/// AppBar(고정) + ScrollView(통계 카드, 배너, 섹션들) 구조
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double _bannerHeight = 88.0;
  static const double _bannerOverlap = 44.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Storoo',
          style: AppTextStyles.headline1.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 상단 보라 배경 영역 (통계 카드 + 배너 상단 절반) ──
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 보라 배경 컨테이너
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    _bannerOverlap + 12,
                  ),
                  child: const StatsCard(),
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
            const FolderListPreview(),

            const SizedBox(height: 100), // 하단 네비게이션 바 여백
          ],
        ),
      ),
    );
  }
}
