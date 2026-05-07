import 'package:flutter/material.dart';

/// PRO 구독 플랜 카드 (연간 / 월간)
class ProPlanCard extends StatelessWidget {
  final String badge;
  final String title;
  final String description;
  final String price;
  final String? subPrice;
  final bool isSelected;
  final VoidCallback onTap;

  const ProPlanCard({
    super.key,
    required this.badge,
    required this.title,
    required this.description,
    required this.price,
    this.subPrice,
    required this.isSelected,
    required this.onTap,
  });

  static const _gradient = LinearGradient(
    colors: [Color(0xFF9138FF), Color(0xFFF95BF6), Color(0xFFFF7A41)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border:
                    isSelected
                        ? Border.all(color: const Color(0xFF9138FF), width: 1.5)
                        : Border.all(
                          color: Colors.white.withOpacity(0.7),
                          width: 1.5,
                        ),
              ),
              child: Row(
                children: [
                  // 라디오 버튼
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF9138FF),
                        width: 2,
                      ),
                      color:
                          isSelected
                              ? const Color(0xFF9138FF)
                              : Colors.transparent,
                    ),
                    child:
                        isSelected
                            ? const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 8,
                            )
                            : null,
                  ),
                  const SizedBox(width: 12),
                  // 플랜 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          description,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 가격
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      if (subPrice != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subPrice!,
                          style: const TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          // 뱃지 (Best / Hot)
          Positioned(
            top: 0,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: _gradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 11,
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
