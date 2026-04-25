import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 마이페이지 상단 보라 헤더
/// - "Storoo" 타이틀 (중앙)
/// - 인사 + 이름 (왼쪽)
/// - 프로필 편집 버튼 (오른쪽)
/// TODO: 실제 사용자 이름 데이터 연결
class MyPageHeader extends StatelessWidget {
  const MyPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Storoo 타이틀 (중앙)
          Center(child: Text('Storoo', style: AppTextStyles.storooTitle)),
          const SizedBox(height: 20),
          // 인사말
          Text(
            '안녕하세요👋',
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 2),
          // 이름
          Text(
            'OOO님', // TODO: 실제 사용자 이름으로 교체
            style: AppTextStyles.headline1.copyWith(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 프로필 편집 버튼 (이름 아래, 우측 정렬)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {}, // TODO: 프로필 편집 화면 이동
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Text(
                  '프로필 편집  →',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
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
