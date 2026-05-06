import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_text_styles.dart';
import 'dashed_border.dart';

/// 태그 입력 위젯
/// - 추가된 태그 chip 목록 표시 (삭제 가능)
/// - '+ 태그 추가하기' 버튼으로 태그 추가
class TagInputRow extends StatelessWidget {
  const TagInputRow({
    super.key,
    required this.tags,
    required this.onAdd,
    required this.onRemove,
  });

  final List<String> tags;

  /// 태그 추가 버튼 탭 콜백 (부모에서 다이얼로그 열기)
  final VoidCallback onAdd;

  /// 태그 삭제 콜백 (인덱스 전달)
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '태그',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF888888),
          ),
        ),
        const SizedBox(height: 8),
        if (tags.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                tags
                    .asMap()
                    .entries
                    .map(
                      (e) => _TagChip(
                        label: e.value,
                        onRemove: () => onRemove(e.key),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 8),
        ],
        _AddTagChip(onTap: onAdd),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFCCCCCC)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 14,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.cancel,
              size: 16,
              color: Color(0xFF999999),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTagChip extends StatelessWidget {
  const _AddTagChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedBorderPainter(
          color: const Color(0xFFCCCCCC),
          radius: 20,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 6),
              const Text(
                '태그 추가하기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  color: Color(0xFF888888),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 태그 추가 다이얼로그
class TagAddDialog extends StatefulWidget {
  const TagAddDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const TagAddDialog(),
    );
  }

  @override
  State<TagAddDialog> createState() => _TagAddDialogState();
}

class _TagAddDialogState extends State<TagAddDialog> {
  final _ctrl = TextEditingController();
  static const int _maxLength = 20;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                '태그 추가',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '태그 이름',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              autofocus: true,
              maxLength: _maxLength,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) {
                if (_ctrl.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(_ctrl.text.trim());
                }
              },
              style: const TextStyle(fontFamily: 'Pretendard', fontSize: 15),
              decoration: InputDecoration(
                counterText: '${_ctrl.text.length}/$_maxLength',
                counterStyle: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 12,
                  color: Color(0xFF888888),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    overlayColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                  child: const Text(
                    '취소',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed:
                      _ctrl.text.trim().isEmpty
                          ? null
                          : () => Navigator.of(context).pop(_ctrl.text.trim()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    overlayColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    disabledForegroundColor: const Color(0xFFCCCCCC),
                  ),
                  child: const Text(
                    '추가',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
