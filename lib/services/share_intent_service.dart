import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Android ACTION_SEND 공유 인텐트 수신 서비스
/// SRP: MethodChannel 통신만 담당
class ShareIntentService {
  static const _channel = MethodChannel('com.example.storoo/share');

  /// 앱 시작 시 공유된 텍스트(URL) 조회 (1회성)
  /// 조회 후 Android 측 값은 초기화됨
  static Future<String?> getInitialSharedText() async {
    try {
      return await _channel.invokeMethod<String>('getSharedText');
    } catch (_) {
      return null;
    }
  }

  /// 앱 실행 중 새 공유 수신 시 콜백 등록
  static void listenForSharedText(ValueChanged<String> onShared) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNewSharedText') {
        final text = call.arguments as String?;
        if (text != null && text.isNotEmpty) onShared(text);
      }
    });
  }

  /// 공유된 텍스트에서 첫 번째 URL 추출
  /// 일부 앱이 "제목\nURL" 형식으로 공유할 때 URL만 분리
  static String? extractUrl(String? text) {
    if (text == null || text.isEmpty) return null;
    final match = RegExp(r'https?://\S+', caseSensitive: false).firstMatch(text);
    return match?.group(0);
  }
}
