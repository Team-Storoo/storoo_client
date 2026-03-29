import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

/// 홈 배너 카드
/// 보라/흰 경계에 걸쳐서 표시되는 공지/안내 배너
/// TODO: 실제 이미지 에셋 및 배너 데이터 연결
class BannerCard extends StatelessWidget {
  const BannerCard({super.key});

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
          // 오른쪽: 메가폰 아이콘 (TODO: 실제 이미지 에셋으로 교체)
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
