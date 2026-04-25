import 'package:isar/isar.dart';

part 'user_profile.g.dart'; // Isar가 자동 생성 파일을 만들 때 필요

@collection
class UserProfile {
  Id id = Isar.autoIncrement; // 고유 번호

  String? nickname;
  String? gender;
  int? birthYear;
  String? email;

  bool agreedAge14 = false; // 14세 이상 동의
  bool agreedService = false; // 서비스 이용약관 동의
  bool agreedPrivacy = false; // 개인정보 수집 동의
  bool agreedMarketing = false; // 마케팅 동의
  bool agreedAds = false; // 광고성 정보 수신 동의

  bool onboardingCompleted = false; // false면 → 온보딩 보여줌 | true면 → 메인 화면 바로 진입

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
