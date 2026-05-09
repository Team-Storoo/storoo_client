import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import './confirm_action_dialog.dart';

/// 저장/수정 화면에서 변경사항이 있을 때 뒤로가기 시 표시되는 취소 확인 팝업
///
/// - true 반환 : 사용자가 "나가기" 선택 → 변경사항 버리고 화면 종료
/// - false 반환: 사용자가 "계속 수정" 선택 → 그대로 화면 유지
class ConfirmDiscardDialog {
  static Future<bool> show(BuildContext context) {
    return ConfirmActionDialog.show(
      context,
      iconColor: AppColors.primary,
      title: '작성을 취소하시겠어요?',
      message: '수정하신 내용은 저장되지 않습니다.',
      confirmLabel: '나가기',
      confirmColor: AppColors.primary,
      cancelLabel: '계속 수정',
    );
  }
}

