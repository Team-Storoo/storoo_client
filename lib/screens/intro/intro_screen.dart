import 'package:flutter/material.dart';

import '../../services/db_service.dart';
import '../login/login_screen.dart';
import 'intro_page_data.dart';
import 'widgets/intro_bottom_area.dart';
import 'widgets/intro_page.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final _pageCtrl = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_current < kIntroPages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await DBService.markIntroSeen();
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _onPrev() {
    if (_current > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 페이지 콘텐츠 (폰 목업이 버튼 뒤까지 확장됨)
          PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) => setState(() => _current = i),
            itemCount: kIntroPages.length,
            itemBuilder: (_, i) => IntroPage(data: kIntroPages[i]),
          ),
          // 하단 버튼 + 점 인디케이터 오버레이
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IntroBottomArea(
              current: _current,
              total: kIntroPages.length,
              onNext: _onNext,
              onPrev: _onPrev,
            ),
          ),
        ],
      ),
    );
  }
}
