import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/content.dart';
import '../models/user_profile.dart';

class DBService {
  static Isar? _isar;

  static Isar get isar {
    if (_isar == null) {
      throw Exception('Isar가 초기화되지 않았습니다. 먼저 DBService.init()을 호출하세요.');
    }
    return _isar!;
  }

  /// 앱 시작 시 1회 호출
  static Future<void> init() async {
    if (_isar != null) return;

    if (kIsWeb) {
      debugPrint("웹은 현재 Isar 로컬 DB 예제를 생략합니다.");
      return;
    }

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [ContentSchema, UserProfileSchema],
      directory: dir.path,
      name: 'storoo_db',
    );

    debugPrint("DBService initialized");
  }

  /// -------------------------
  /// UserProfile 관련
  /// -------------------------

  static Future<UserProfile?> getUserProfile() async {
    if (kIsWeb) return null;
    return await isar.userProfiles.where().findFirst();
  }

  static Future<bool> hasCompletedOnboarding() async {
    final profile = await getUserProfile();
    return profile?.onboardingCompleted ?? false;
  }

  static Future<void> saveUserProfile(UserProfile profile) async {
    if (kIsWeb) return;

    profile.updatedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.userProfiles.put(profile);
    });
  }

  static Future<void> clearUserProfile() async {
    if (kIsWeb) return;

    await isar.writeTxn(() async {
      await isar.userProfiles.clear();
    });
  }

  /// -------------------------
  /// Content 관련
  /// -------------------------

  static Future<void> saveContent(Content content) async {
    if (kIsWeb) {
      debugPrint("Saved content (dummy): ${content.title}");
      return;
    }

    await isar.writeTxn(() async {
      await isar.contents.put(content);
    });
  }

  static Future<List<Content>> getContents() async {
    if (kIsWeb) {
      return [];
    }

    return await isar.contents.where().findAll();
  }

  /// -------------------------
  /// 앱 인트로 (최초 1회 표시)
  /// -------------------------

  static const _kIntroKey = 'intro_seen';

  static Future<bool> hasSeenIntro() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIntroKey) ?? false;
  }

  static Future<void> markIntroSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIntroKey, true);
  }
}
