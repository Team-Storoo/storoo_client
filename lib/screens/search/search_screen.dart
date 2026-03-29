import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 검색 화면 (추후 구현 예정)
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
        title: Text(
          '검색',
          style: AppTextStyles.headline1.copyWith(color: Colors.white),
        ),
      ),
      body: Center(child: Text('검색 화면 (추후 구현)', style: AppTextStyles.body)),
    );
  }
}
