import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// 홈 화면
/// AppBar는 Scaffold에 넣으면 자동 상단 고정 (스크롤과 무관)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  /// 배너 카드 총 높이
  static const double _bannerHeight = 88.0;

  /// 배너가 흰색 영역으로 내려오는 높이 (절반)
  static const double _bannerOverlap = 44.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Storoo',
          style: AppTextStyles.headline1.copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 보라색 배경 + 배너 겹침 구역 ─────────────────────
            // Stack(clipBehavior: Clip.none) → 자식이 Stack 바깥으로 나올 수 있음
            Stack(
              clipBehavior: Clip.none,
              children: [
                // 보라색 배경 컨테이너 (통계 카드 포함)
                // 하단 패딩: 배너 절반 높이 + 여유 공간 확보
                Container(
                  color: AppColors.primary,
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16, 8, 16, _bannerOverlap + 12),
                  child: const _StatsCard(),
                ),
                // 배너 카드: bottom: -_bannerOverlap
                // → 상단 절반은 보라 영역, 하단 절반은 흰색 영역에 걸침
                Positioned(
                  bottom: -_bannerOverlap,
                  left: 16,
                  right: 16,
                  height: _bannerHeight,
                  child: const _BannerCard(),
                ),
              ],
            ),

            // 배너 하단 여백 (튀어나온 높이만큼 공간 보정)
            SizedBox(height: _bannerOverlap + 10),

            // 페이지 인디케이터 (점) - 흰색 배경 위에 표시
            const _PageDots(count: 3, activeIndex: 0),
            const SizedBox(height: 20),

            // ── 최근 저장 섹션 ─────────────────────────────────
            const _SectionHeader(title: '최근 저장'),
            const _RecentSavedPlaceholder(),

            // ── 내 폴더 섹션 ───────────────────────────────────
            const _SectionHeader(title: '내 폴더', topPadding: 20),
            const _FolderListPlaceholder(),

            const SizedBox(height: 100), // 하단 네비게이션 바 여백
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 통계 카드: "저장된 내 자료는 총 N 개"
class _StatsCard extends StatelessWidget {
  const _StatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '저장된 내 자료는 총',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '-', // TODO: DB 연결 후 실제 개수로 교체
                style: AppTextStyles.headline1.copyWith(
                  fontSize: 28,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Text(' 개', style: AppTextStyles.body),
            ],
          ),
        ],
      ),
    );
  }
}

// 배너 카드 (보라/흰 경계에 걸쳐서 표시)
class _BannerCard extends StatelessWidget {
  const _BannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 왼쪽: 캐릭터 영역 (TODO: 실제 이미지 에셋으로 교체)
          Container(
            width: 58,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF2D2D3A),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('🐿️', style: TextStyle(fontSize: 26)),
          ),
          // 중앙: 텍스트 3줄
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('이제 다람쥐도 정리하며 사는 시대!', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text('내 자료 저장은? Storoo!', style: AppTextStyles.subtitle),
                  const SizedBox(height: 2),
                  Text(
                    'Storoo 사용 방법 보러가기 >',
                    style: AppTextStyles.caption.copyWith(
                      color: const Color(0xFFFF6B35), // 주황색 링크
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 오른쪽: 메가폰 아이콘 영역
          Container(
            width: 42,
            height: 42,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF0EA),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Text('📢', style: TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
  }
}

// 배너 페이지 인디케이터 (점 3개)
class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.activeIndex});

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final bool isActive = i == activeIndex;
        return Container(
          width: isActive ? 16 : 6,
          height: 6,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// 섹션 헤더 (이미지처럼 subtitle 크기로 작게)
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.topPadding = 0});

  final String title;
  final double topPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, topPadding, 16, 10),
      child: Text(title, style: AppTextStyles.subtitle),
    );
  }
}

// 최근 저장 가로 스크롤 자리표시자
class _RecentSavedPlaceholder extends StatelessWidget {
  const _RecentSavedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: 3, // TODO: 실제 데이터로 교체
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          return Container(
            width: 160,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            alignment: Alignment.center,
            child: Text(
              '최근 항목 ${index + 1}\n(추후 구현)',
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
          );
        },
      ),
    );
  }
}

// 내 폴더 목록 자리표시자
class _FolderListPlaceholder extends StatelessWidget {
  const _FolderListPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3, // TODO: 실제 폴더 데이터로 교체
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('폴더 이름 ${index + 1}', style: AppTextStyles.subtitle),
                    const SizedBox(height: 4),
                    Text('저장된 항목 0개', style: AppTextStyles.caption),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        );
      },
    );
  }
}
