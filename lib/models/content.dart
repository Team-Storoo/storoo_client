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
  String? imageUrl;
  List<String> tags = [];
  int? folderId;
  late DateTime createdAt;
  DateTime? deletedAt;
  bool favorite = false;
}
