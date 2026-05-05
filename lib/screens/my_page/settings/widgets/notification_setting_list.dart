import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 알림 설정 토글 목록 위젯
/// TODO: DB 연동 후 실제 설정 값 저장
class NotificationSettingList extends StatefulWidget {
  const NotificationSettingList({super.key});

  @override
  State<NotificationSettingList> createState() => _NotificationSettingListState();
}

class _NotificationSettingListState extends State<NotificationSettingList> {
  bool _pushAll = true;
  bool _newFeature = true;
  bool _marketing = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ToggleRow(
            label: '앱 푸시 알림 전체',
            description: '모든 알림을 켜거나 끕니다',
            value: _pushAll,
            onChanged: (v) => setState(() {
              _pushAll = v;
              _newFeature = v;
              _marketing = v;
            }),
          ),
          const Divider(height: 24, thickness: 1, color: AppColors.divider),
          _ToggleRow(
            label: '신규 기능 알림',
            description: '업데이트 및 새 기능 소식',
            value: _newFeature,
            onChanged: _pushAll
                ? (v) => setState(() => _newFeature = v)
                : null,
          ),
          const SizedBox(height: 12),
          _ToggleRow(
            label: '마케팅 알림',
            description: '이벤트 및 프로모션 안내',
            value: _marketing,
            onChanged: _pushAll
                ? (v) => setState(() => _marketing = v)
                : null,
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.subtitle),
            const SizedBox(height: 2),
            Text(description, style: AppTextStyles.caption),
          ],
        ),
        Switch(
          value: value,
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
