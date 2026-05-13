/// 프로필 편집 화면 유효성 검사
///
/// SRP: 유효성 검사 로직만 담당
class ProfileEditValidator {
  const ProfileEditValidator._();

  /// 한글·영문 대소문자·숫자·밑줄·마침표 / 2~15자 (필수)
  static bool isValidNickname(String v) {
    if (v.length < 2) return false;
    return RegExp(r'^[가-힣a-zA-Z0-9_.]+$').hasMatch(v);
  }

  /// 이메일: 비어있으면 통과, 값이 있으면 유효한 형식 (선택)
  static bool isEmailValidOrEmpty(String v) {
    if (v.isEmpty) return true;
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.(com|net|org|edu|gov|io|co|kr|me|app|dev|info|biz|[a-zA-Z]{2,})$',
    );
    return regex.hasMatch(v);
  }
}
