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
  String? imageUrl;         // 하위 호환 썸네일 (단일 이미지 기존 데이터)
  List<String> imageUrls = []; // 다중 이미지 (최대 5장)
  List<String> tags = [];

  /// imageUrls 우선, 없으면 imageUrl fallback
  List<String> get effectiveImageUrls =>
      imageUrls.isNotEmpty
          ? imageUrls
          : (imageUrl != null && imageUrl!.isNotEmpty ? [imageUrl!] : []);
  int? folderId;
  late DateTime createdAt;
  DateTime? deletedAt;
  bool favorite = false;
}
