import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 폴더 그리드 단일 카드 위젯
///
/// [index] 임시 인덱스 (추후 Folder 모델로 교체)
/// TODO: DB 연결 후 Folder 모델 파라미터로 교체
class FolderCard extends StatelessWidget {
  const FolderCard({super.key, required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '폴더 ${index + 1}', // TODO: 실제 폴더 이름으로 교체
                  style: AppTextStyles.subtitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GestureDetector(
                onTap: () {}, // TODO: 폴더 옵션 메뉴 구현
                child: const Icon(
                  Icons.more_vert,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            '저장된 항목 0개', // TODO: 실제 개수로 교체
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
