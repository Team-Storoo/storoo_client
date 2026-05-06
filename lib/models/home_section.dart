/// 홈화면에 표시 가능한 섹션 목록
///
/// 사용자가 최소 1개 ~ 최대 3개를 선택하여 홈화면에 노출할 수 있습니다.
/// 새 섹션 추가 시 이 enum에 항목을 추가하고, [HomeSection.label] / [HomeSection.key]를
/// 정의하면 설정 화면과 홈화면에 자동 반영됩니다.
enum HomeSection {
  /// 최근 저장된 콘텐츠 가로 스크롤 목록
  recentSaved,

  /// 내 폴더 목록 미리보기
  folderList,

  /// 이미지 타입 콘텐츠 목록
  imageList,

  /// 링크 타입 콘텐츠 목록
  linkList,

  /// 노트(메모) 타입 콘텐츠 목록
  noteList,
}

/// [HomeSection] 표시 이름 및 DB 저장 키 확장
extension HomeSectionX on HomeSection {
  /// 설정 화면 / 섹션 헤더에 표시할 사람이 읽기 좋은 이름
  String get label {
    switch (this) {
      case HomeSection.recentSaved:
        return '최근 저장';
      case HomeSection.folderList:
        return '내 폴더 목록';
      case HomeSection.imageList:
        return '이미지 목록';
      case HomeSection.linkList:
        return '링크 목록';
      case HomeSection.noteList:
        return '노트 목록';
    }
  }

  /// DB/SharedPreferences 저장 시 사용할 문자열 키
  /// ⚠️ DB 작업자: 이 값으로 저장·불러오기를 구현해 주세요.
  String get key {
    switch (this) {
      case HomeSection.recentSaved:
        return 'recentSaved';
      case HomeSection.folderList:
        return 'folderList';
      case HomeSection.imageList:
        return 'imageList';
      case HomeSection.linkList:
        return 'linkList';
      case HomeSection.noteList:
        return 'noteList';
    }
  }

  /// [key] 문자열로부터 [HomeSection]을 복원합니다.
  static HomeSection? fromKey(String key) {
    for (final s in HomeSection.values) {
      if (s.key == key) return s;
    }
    return null;
  }
}
