import 'package:flutter/material.dart';
import './folder_card.dart';

/// 폴더 2열 그리드 목록
/// TODO: DB 연결 후 실제 폴더 목록 데이터 연결
class FolderGrid extends StatelessWidget {
  const FolderGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2열 고정
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4, // 카드 가로:세로 비율
      ),
      itemCount: 6, // TODO: 실제 폴더 목록 개수로 교체
      itemBuilder: (_, index) => FolderCard(index: index),
    );
  }
}
