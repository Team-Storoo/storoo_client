import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/content.dart';
import '../models/user_profile.dart';
import '../models/folder_item.dart';

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
      [ContentSchema, UserProfileSchema,  FolderItemSchema],
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

  static Future<void> saveContentToFolder(Content content) async {
    if (kIsWeb) {
      debugPrint("Saved content (dummy): ${content.title}");
      return;
    }

    await isar.writeTxn(() async {
      await isar.contents.put(content);
    });

    if (content.folderId != null) {
      await _syncFolderCount(content.folderId!);
    }
  }

  static Future<List<Content>> getContents() async {
    if (kIsWeb) return [];
    return await isar.contents.where().findAll();
  }

  static Future<List<Content>> getContentsByFolder(int folderId, String type) async {
    if (kIsWeb) return [];
    return await isar.contents
        .filter()
        .folderIdEqualTo(folderId)
        .and()
        .typeEqualTo(type)
        .and()
        .deletedAtIsNull()
        .sortByCreatedAtDesc()
        .findAll();
  }

  static Future<void> deleteContentAndSync(int contentId, int? folderId) async {
    if (kIsWeb) return;
    await isar.writeTxn(() async {
      await isar.contents.delete(contentId);
    });
    if (folderId != null) {
      await _syncFolderCount(folderId);
    }
  }

  static Future<void> _syncFolderCount(int folderId) async {
    if (kIsWeb) return;
    final folder = await isar.folderItems.get(folderId);
    if (folder == null) return;
    final count = await isar.contents
        .filter()
        .folderIdEqualTo(folderId)
        .and()
        .deletedAtIsNull()
        .count();
    folder.itemCount = count;
    await isar.writeTxn(() async {
      await isar.folderItems.put(folder);
    });
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

  /// -------------------------
  /// FolderItem 관련
  /// -------------------------

  static Future<void> saveFolder(FolderItem folder) async {
    await isar.writeTxn(() async {
      await isar.folderItems.put(folder);
    });
  }

  static Future<List<FolderItem>> getFolders() async {
    return await isar.folderItems.where().findAll();
  }

  static Future<List<Content>> getAllActiveContents() async {
    if (kIsWeb) return [];
    return await isar.contents.filter().deletedAtIsNull().findAll();
  }

  static Future<List<Content>> getRecentContents({int limit = 10}) async {
    if (kIsWeb) return [];
    return await isar.contents
        .filter()
        .deletedAtIsNull()
        .sortByCreatedAtDesc()
        .limit(limit)
        .findAll();
  }

  static Future<void> deleteFolder(int id) async {
    await isar.writeTxn(() async {
      await isar.folderItems.delete(id);
    });
  }

  /// -------------------------
  /// 폴더 사용자 지정순
  /// -------------------------

  static const _kFolderOrderKey = 'folder_custom_order';

  static Future<List<int>> getCustomFolderOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList(_kFolderOrderKey);
    if (ids == null) return [];
    return ids.map(int.parse).toList();
  }

  static Future<void> saveCustomFolderOrder(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _kFolderOrderKey,
      ids.map((id) => id.toString()).toList(),
    );
  }
}


