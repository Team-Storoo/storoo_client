import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class PhoneMockup extends StatelessWidget {
  const PhoneMockup({super.key, required this.imagePath});

  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;

    return Align(
      alignment: Alignment.topCenter,
      child: Image.asset(
        imagePath,
        width: screenW * 0.82,
        fit: BoxFit.fitWidth,
        errorBuilder:
            (_, __, ___) => Center(
              child: Icon(
                Icons.smartphone,
                size: 48,
                color: AppColors.primary.withOpacity(0.2),
              ),
            ),
      ),
    );
  }
}
