import '../folder/folder_item.dart';

/// 더미 폴더 3개 — DB 연동 전 UI 개발용
List<FolderItem> createDummyFolders() => [
  FolderItem(id: 'dummy_1', name: '맛집', createdAt: DateTime(2024)),
  FolderItem(id: 'dummy_2', name: '코디', createdAt: DateTime(2024)),
  FolderItem(id: 'dummy_3', name: '여행', createdAt: DateTime(2024)),
];
