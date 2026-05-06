import '../models/home_section.dart';

/// 홈화면 표시 섹션 설정을 저장·불러오는 서비스 (SRP)
///
/// ⚠️ DB 작업자 구현 가이드 ─────────────────────────────────────────
/// 현재는 앱 메모리(in-memory)로만 동작합니다.
/// 실제 저장이 필요하면 아래 두 메서드를 구현해 주세요:
///
/// [load]
///   - SharedPreferences 또는 Isar UserProfile 등에서
///     List<String> 형태로 키 목록을 읽어와
///     `HomeSectionX.fromKey(key)` 로 변환 후 반환
///   - 저장값이 없으면 [_defaultSections] 반환
///
/// [save]
///   - `sections.map((s) => s.key).toList()` 를 직렬화해
///     SharedPreferences 또는 Isar에 저장
///
/// 예시 (SharedPreferences):
///   ```dart
///   static const _prefKey = 'home_sections';
///
///   static Future<List<HomeSection>> load() async {
///     final prefs = await SharedPreferences.getInstance();
///     final keys = prefs.getStringList(_prefKey);
///     if (keys == null) return List.of(_defaultSections);
///     return keys
///         .map(HomeSectionX.fromKey)
///         .whereType<HomeSection>()
///         .toList();
///   }
///
///   static Future<void> save(List<HomeSection> sections) async {
///     final prefs = await SharedPreferences.getInstance();
///     await prefs.setStringList(_prefKey, sections.map((s) => s.key).toList());
///   }
///   ```
/// ─────────────────────────────────────────────────────────────────
class HomeSettingsService {
  HomeSettingsService._();

  /// 기본 선택 섹션 (앱 최초 실행 / 저장값 없을 때)
  static const List<HomeSection> _defaultSections = [
    HomeSection.recentSaved,
    HomeSection.folderList,
  ];

  /// 선택 가능한 최소 섹션 수
  static const int minSections = 1;

  /// 선택 가능한 최대 섹션 수
  static const int maxSections = 3;

  // ── TODO: DB 저장값으로 교체 ──────────────────────────────────────
  /// 인메모리 캐시 (앱 재시작 시 초기화됨)
  static List<HomeSection> _cached = List.of(_defaultSections);

  /// 저장된 홈화면 섹션 설정을 불러옵니다.
  ///
  /// TODO(DB): SharedPreferences / Isar에서 실제 값을 읽도록 교체
  static Future<List<HomeSection>> load() async {
    // TODO(DB): 여기서 prefs / Isar를 읽어 _cached에 저장
    return List.of(_cached);
  }

  /// 홈화면 섹션 설정을 저장합니다.
  ///
  /// [sections]는 [minSections] 이상 [maxSections] 이하여야 합니다.
  ///
  /// TODO(DB): 여기서 prefs / Isar에 실제로 저장하도록 교체
  static Future<void> save(List<HomeSection> sections) async {
    assert(
      sections.length >= minSections && sections.length <= maxSections,
      '섹션은 $minSections ~ $maxSections 개 사이여야 합니다.',
    );
    _cached = List.of(sections);
    // TODO(DB): await prefs.setStringList(...) 또는 Isar write
  }
}
