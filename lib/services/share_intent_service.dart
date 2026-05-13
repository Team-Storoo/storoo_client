import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 공유 인텐트 수신 서비스
/// Android: ACTION_SEND 인텐트 (ShareActivity.kt)
/// iOS: URL 스킴 storoo://share (AppDelegate.swift + ShareExtension)
class ShareIntentService {
  static const _channel = MethodChannel('com.example.storoo/share');

  /// 공유 타입 조회: "link" | "note" | "image"
  static Future<String> getShareType() async {
    try {
      return await _channel.invokeMethod<String>('getShareType') ?? 'link';
    } catch (_) {
      return 'link';
    }
  }

  /// 앱 시작 시 공유된 텍스트(URL 또는 일반 텍스트) 조회 (1회성)
  static Future<String?> getInitialSharedText() async {
    try {
      return await _channel.invokeMethod<String>('getSharedText');
    } catch (_) {
      return null;
    }
  }

  /// 이미지 공유 시 캐시/App Group에 복사된 파일 경로 목록 조회 (최대 5개)
  static Future<List<String>> getImagePaths() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getImagePaths');
      return result?.cast<String>() ?? [];
    } catch (_) {
      return [];
    }
  }

  /// iOS 전용: URL 스킴으로 실행됐는지 여부 (공유 콜드 스타트 감지)
  static Future<bool> isShareLaunch() async {
    if (!Platform.isIOS) return false;
    try {
      return await _channel.invokeMethod<bool>('isShareLaunch') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// 앱 실행 중 새 공유 수신 시 콜백 등록
  /// [onAndroidText]: Android에서 새 텍스트 공유가 들어올 때
  /// [onIosShare]: iOS에서 앱이 실행 중에 storoo://share로 열릴 때
  static void listenForShare({
    ValueChanged<String>? onAndroidText,
    VoidCallback? onIosShare,
  }) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onNewSharedText') {
        final text = call.arguments as String?;
        if (text != null && text.isNotEmpty) onAndroidText?.call(text);
      } else if (call.method == 'onShareReceived') {
        onIosShare?.call();
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

  // 기존 호환성 유지
  @Deprecated('Use listenForShare instead')
  static void listenForSharedText(ValueChanged<String> onShared) {
    listenForShare(onAndroidText: onShared);
  }
}
