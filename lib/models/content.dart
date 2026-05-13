import 'package:isar/isar.dart';

part 'content.g.dart';

@collection
class Content {
  static const int schemaId = 1; // 웹 호환을 위해 작은 값 지정
  Id id = Isar.autoIncrement;

  late String type;
  late String title;
  String? description;
  String? url;
  String? content;
  // 이미지 타입: 단일 경로 또는 '\n'으로 이어붙인 복수 경로
  // 링크 타입: OG 이미지 URL
  String? imageUrl;
  List<String> tags = [];

  /// 이미지 경로 목록 (단일/복수 모두 대응, 링크 타입에선 사용 안 함)
  List<String> get effectiveImageUrls {
    if (imageUrl == null || imageUrl!.isEmpty) return [];
    return imageUrl!.split('\n').where((p) => p.isNotEmpty).toList();
  }
  int? folderId;
  late DateTime createdAt;
  DateTime? deletedAt;
  bool favorite = false;
}
