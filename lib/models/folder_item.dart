import 'package:isar/isar.dart';

part 'folder_item.g.dart';

@collection
class FolderItem {
  Id id = Isar.autoIncrement;   // Isar 자동 증가 ID
  late String name;             // 폴더 이름
  late DateTime createdAt;      // 생성 시각
  int itemCount = 0;            // 폴더 안 콘텐츠 개수
}
