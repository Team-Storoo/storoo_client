import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 홈 화면 내 폴더 미리보기 목록 (세로 리스트)
/// FolderScreen의 전체 목록과 구분하기 위해 별도 위젯으로 분리
/// TODO: DB 연결 후 실제 폴더 목록 데이터 연결
class FolderListPreview extends StatelessWidget {
  const FolderListPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      // 부모 SingleChildScrollView에 스크롤 위임
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
                    Text(
                      '폴더 이름 ${index + 1}', // TODO: 실제 폴더 이름으로 교체
                      style: AppTextStyles.subtitle,
                    ),
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
