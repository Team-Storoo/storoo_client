import 'package:flutter/foundation.dart';

class DBService {
  /// 웹/모바일 공통 초기화
  static Future<void> init() async {
    if (kIsWeb) {
      // 웹에서는 DB 초기화 대신 더미 처리
      debugPrint("DBService initialized (dummy for web)");
    } else {
      // 모바일/데스크톱에서는 실제 Isar 초기화 코드 작성
      // 예: await Isar.open([...]);
      debugPrint("DBService initialized (real DB for mobile/desktop)");
    }
  }

  /// 더미 저장 함수 (웹 확인용)
  static Future<void> saveContent(Map<String, dynamic> content) async {
    if (kIsWeb) {
      debugPrint("Saved content (dummy): $content");
    } else {
      // 실제 DB 저장 로직 작성
    }
  }

  /// 더미 조회 함수 (웹 확인용)
  static Future<List<Map<String, dynamic>>> getContents() async {
    if (kIsWeb) {
      return [
        {
          "id": 1,
          "type": "memo",
          "title": "웹 확인용 더미 제목",
          "content": "이건 웹에서 UI 확인용 더미 데이터입니다.",
        },
      ];
    } else {
      // 실제 DB 조회 로직 작성
      return [];
    }
  }
}
