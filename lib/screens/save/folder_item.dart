/// UI 개발용 폴더 모델 (DB 연동 전 더미 데이터 전용)
/// DB 연동 시에는 /models/folder_item.dart(Isar 모델)로 교체 예정
class FolderItem {
  final String id;
  final String name;
  final DateTime createdAt;

  const FolderItem({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}
