import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../terms_content/service_terms.dart';
import '../terms_content/privacy_terms.dart';
import '../terms_content/marketing_terms.dart';
import '../terms_content/ads_terms.dart';
import '../terms_content/terms_detail_page.dart';

void _openTermsPage(
  BuildContext context, {
  required String title,
  required String content,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => TermsDetailPage(title: title, content: content),
    ),
  );
}

/// 온보딩 Step 0: 이용약관 동의
class TermsStep extends StatelessWidget {
  const TermsStep({
    super.key,
    required this.agreedAge14,
    required this.agreedService,
    required this.agreedPrivacy,
    required this.agreedMarketing,
    required this.agreedAds,
    required this.allAgreed,
    required this.onAge14Changed,
    required this.onServiceChanged,
    required this.onPrivacyChanged,
    required this.onMarketingChanged,
    required this.onAdsChanged,
    required this.onToggleAll,
  });

  final bool agreedAge14;
  final bool agreedService;
  final bool agreedPrivacy;
  final bool agreedMarketing;
  final bool agreedAds;
  final bool allAgreed;
  final ValueChanged<bool> onAge14Changed;
  final ValueChanged<bool> onServiceChanged;
  final ValueChanged<bool> onPrivacyChanged;
  final ValueChanged<bool> onMarketingChanged;
  final ValueChanged<bool> onAdsChanged;
  final ValueChanged<bool> onToggleAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TermItem(
          label: '[필수] 만 14세 이상 입니다.',
          checked: agreedAge14,
          onTap: () => onAge14Changed(!agreedAge14),
        ),
        _TermItem(
          label: '[필수] 서비스 이용약관 동의',
          checked: agreedService,
          onTap: () => onServiceChanged(!agreedService),
          onChevronTap:
              () => _openTermsPage(
                context,
                title: kServiceTermsTitle,
                content: kServiceTermsContent,
              ),
        ),
        _TermItem(
          label: '[필수] 개인정보 수집 및 이용 동의',
          checked: agreedPrivacy,
          onTap: () => onPrivacyChanged(!agreedPrivacy),
          onChevronTap:
              () => _openTermsPage(
                context,
                title: kPrivacyTermsTitle,
                content: kPrivacyTermsContent,
              ),
        ),
        _TermItem(
          label: '[선택] 마케팅 활용 동의',
          checked: agreedMarketing,
          onTap: () => onMarketingChanged(!agreedMarketing),
          onChevronTap:
              () => _openTermsPage(
                context,
                title: kMarketingTermsTitle,
                content: kMarketingTermsContent,
              ),
        ),
        _TermItem(
          label: '[선택] 광고성 정보 수신 동의',
          checked: agreedAds,
          onTap: () => onAdsChanged(!agreedAds),
          onChevronTap:
              () => _openTermsPage(
                context,
                title: kAdsTermsTitle,
                content: kAdsTermsContent,
              ),
        ),
        const SizedBox(height: 8),
        // ── 전체 동의 (항목 바로 아래) ──
        GestureDetector(
          onTap: () => onToggleAll(!allAgreed),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Icon(
                  allAgreed ? Icons.check_circle : Icons.check_circle_outline,
                  color:
                      allAgreed ? AppColors.primary : AppColors.textSecondary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  '전체 동의',
                  style: AppTextStyles.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text('(선택항목 포함)', style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 이용약관 단일 항목
class _TermItem extends StatelessWidget {
  const _TermItem({
    required this.label,
    required this.checked,
    required this.onTap,
    this.onChevronTap,
  });

  final String label;
  final bool checked;
  final VoidCallback onTap;
  final VoidCallback? onChevronTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Icon(
              Icons.check,
              size: 18,
              color: checked ? AppColors.primary : AppColors.divider,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color:
                      checked ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ),
            if (onChevronTap != null)
              GestureDetector(
                onTap: onChevronTap,
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
