import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 마케팅 정보 수신 동의 토글 위젯
/// TODO: DB 연동 후 실제 동의 상태 저장
class MarketingToggle extends StatefulWidget {
  const MarketingToggle({super.key});

  @override
  State<MarketingToggle> createState() => _MarketingToggleState();
}

class _MarketingToggleState extends State<MarketingToggle> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('마케팅 정보 수신 동의', style: AppTextStyles.subtitle),
                      const SizedBox(height: 4),
                      Text(
                        '신규 기능, 이벤트 등 유용한 정보를 받아볼 수 있어요',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _agreed,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _agreed = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '동의하지 않아도 서비스 이용에는 지장이 없습니다.',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
