import 'package:isar/isar.dart';

part 'content.g.dart';

@collection
class Content {
  Id id = Isar.autoIncrement;

  /// 콘텐츠 유형: link, memo, image
  late String type;

  /// 제목
  late String title;

  /// 설명 (링크 전용)
  String? description;

  /// 링크 주소 (link 전용)
  String? url;

  /// 메모 내용 (memo 전용)
  String? content;

  /// 이미지 주소 (image 전용)
  String? imageUrl;

  /// 태그 배열
  List<String> tags = [];

  /// 폴더 ID
  int? folderId;

  /// 생성 시간
  late DateTime createdAt;

  /// 삭제 시간
  DateTime? deletedAt;

  /// 즐겨찾기 여부
  bool favorite = false;
}
