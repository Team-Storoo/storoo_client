import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 폴더 생성 다이얼로그
class CreateFolderDialog extends StatefulWidget {
  final String initialName;
  final bool isRename;

  const CreateFolderDialog({super.key, this.initialName = '', this.isRename = false});

  @override
  State<CreateFolderDialog> createState() => _CreateFolderDialogState();
}

class _CreateFolderDialogState extends State<CreateFolderDialog> {
  late final TextEditingController _ctrl;
  static const int _maxLength = 15;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialName);
  }

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
            Center(
              child: Text(
                widget.isRename ? '폴더 이름 수정' : '폴더 생성',
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
              '폴더 이름',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: Color(0xFF888888),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              maxLength: _maxLength,
              onChanged: (_) => setState(() {}),
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
                  child: Text(
                    widget.isRename ? '수정' : '추가',
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
