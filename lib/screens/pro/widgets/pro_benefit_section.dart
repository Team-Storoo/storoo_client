import 'package:flutter/material.dart';
import 'pro_benefit_card.dart';

/// PRO 혜택 섹션 (제목 + 혜택 카드 목록)
class ProBenefitSection extends StatelessWidget {
  const ProBenefitSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 36, 20, 0),
      child: Column(
        children: [
          const Text(
            '한눈에 보는',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Storoo pro 혜택',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          const ProBenefitCard(
            icon: Icons.folder_open_rounded,
            title: '폴더 무제한 생성',
            description: '원하는 만큼 폴더를 만들어 콘텐츠를 체계적으로 정리하세요.',
          ),
          const SizedBox(height: 12),
          const ProBenefitCard(
            icon: Icons.block_rounded,
            title: '광고 없는 환경',
            description: 'PRO 구독 시 모든 광고가 제거되어 더욱 쾌적하게 이용할 수 있어요.',
          ),
          const SizedBox(height: 12),
          const ProBenefitCard(
            icon: Icons.star_rounded,
            title: '즐겨찾기 무제한',
            description: '중요한 콘텐츠를 즐겨찾기에 무제한으로 추가할 수 있어요.',
          ),
          const SizedBox(height: 12),
          const ProBenefitCard(
            icon: Icons.support_agent_rounded,
            title: '우선 고객 지원',
            description: 'PRO 구독자에게는 우선적으로 1:1 고객 지원을 제공해드려요.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
