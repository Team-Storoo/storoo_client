/// 로컬 상태용 폴더 모델 (DB 미연결)
class FolderItem {
  final String id;
  final String name;
  final DateTime createdAt;
  int itemCount;

  FolderItem({
    required this.id,
    required this.name,
    required this.createdAt,
    this.itemCount = 0,
  });
}
