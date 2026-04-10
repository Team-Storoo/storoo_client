import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class IntroBottomArea extends StatelessWidget {
  const IntroBottomArea({
    super.key,
    required this.current,
    required this.total,
    required this.onNext,
  });

  final int current;
  final int total;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.9),
            Colors.white,
          ],
          stops: const [0.0, 0.4, 0.65],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.transparent,
                splashFactory: NoSplash.splashFactory,
                overlayColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ).copyWith(elevation: WidgetStateProperty.all(0)),
              child: Text(
                current == total - 1 ? '시작하기' : '다음',
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(total, (i) {
              final isActive = i == current;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 8 : 6,
                height: isActive ? 8 : 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      isActive
                          ? const Color(0xFF1A1A1A)
                          : const Color(0xFFCCCCCC),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
