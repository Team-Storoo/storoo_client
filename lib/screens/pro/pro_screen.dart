import 'package:flutter/material.dart';
import 'widgets/pro_plan_card.dart';
import 'widgets/pro_benefit_section.dart';

enum _ProPlan { annual, monthly }

/// PRO 구독 화면
class ProScreen extends StatefulWidget {
  const ProScreen({super.key});

  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  _ProPlan _selected = _ProPlan.annual;

  // 그라데이션 배경: 원본보다 밝게 (화이트 믹스)
  static const _bgGradient = LinearGradient(
    colors: [Color(0xFFD9B8FF), Color(0xFFFDB5FC), Color(0xFFFFCDB5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const _proGradient = LinearGradient(
    colors: [Color(0xFF9138FF), Color(0xFFF95BF6), Color(0xFFFF7A41)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            color: Colors.black,
            size: 20,
          ),
        ),
        title: const Text(
          'Storoo Pro 구독',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── 그라데이션 헤더 ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(gradient: _bgGradient),
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Storoo + PRO 뱃지
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'Storoo',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ShaderMask(
                                shaderCallback:
                                    (bounds) =>
                                        _proGradient.createShader(bounds),
                                child: const Text(
                                  'PRO',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '링크·이미지·노트를 한 곳으로 저장',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 28),
                        // 연간 구독 카드
                        ProPlanCard(
                          badge: 'Best',
                          title: '연간 구독',
                          description: '결제하면 1년 동안 PRO 혜택 유지',
                          price: '연 5,000원',
                          subPrice: '월 416원',
                          isSelected: _selected == _ProPlan.annual,
                          onTap:
                              () => setState(() => _selected = _ProPlan.annual),
                        ),
                        const SizedBox(height: 20),
                        // 월간 구독 카드
                        ProPlanCard(
                          badge: 'Hot',
                          title: '월간 구독',
                          description: '결제하면 1개월 동안 PRO 혜택 유지',
                          price: '월 500원',
                          isSelected: _selected == _ProPlan.monthly,
                          onTap:
                              () =>
                                  setState(() => _selected = _ProPlan.monthly),
                        ),
                      ],
                    ),
                  ),

                  // ── 혜택 섹션 ──────────────────────────────────────────
                  const ProBenefitSection(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // ── 하단 고정 구독 버튼 ─────────────────────────────────
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: GestureDetector(
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: const Text('준비 중이에요'),
                          content: const Text('구독 기능은 곧 제공될 예정이에요!'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('확인'),
                            ),
                          ],
                        ),
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: _proGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _selected == _ProPlan.annual
                          ? '연간 구독 결제하기'
                          : '월간 구독 결제하기',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
