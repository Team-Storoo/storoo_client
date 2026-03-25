import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/content.dart';

// Isar 데이터베이스 초기화 및 접근을 담당
class DBService {
  static late Isar isar;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    isar = await Isar.open([ContentSchema], directory: dir.path);
  }
}
