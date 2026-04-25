import 'package:flutter/material.dart';

import '../intro_page_data.dart';
import 'phone_mockup.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key, required this.data});

  final IntroPageData data;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return data.isFirstPage
        ? _buildFirstPage(topPad)
        : _buildNormalPage(topPad);
  }

  Widget _buildFirstPage(double topPad) {
    return Padding(
      padding: EdgeInsets.only(left: 28, right: 28, top: topPad + 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Storoo',
            style: TextStyle(
              fontFamily: 'A2GExtraBold',
              fontSize: 42,
              color: Color(0xFF1A1A1A),
              letterSpacing: 0,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            data.subtitle!,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6B6B6B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A1A),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 28),
          Expanded(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: double.infinity,
              child: PhoneMockup(imagePath: data.imagePath),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalPage(double topPad) {
    return Padding(
      padding: EdgeInsets.only(left: 28, right: 28, top: topPad + 40),
      child: Column(
        children: [
          if (data.iconPath != null)
            Image.asset(
              data.iconPath!,
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder:
                  (_, __, ___) => const SizedBox(width: 40, height: 40),
            ),
          const SizedBox(height: 20),
          Text(
            data.title,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          Expanded(
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: double.infinity,
              child: PhoneMockup(imagePath: data.imagePath),
            ),
          ),
        ],
      ),
    );
  }
}
