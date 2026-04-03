import 'package:flutter/material.dart';
import './widgets/my_page_header.dart';
import './widgets/storage_type_section.dart';
import './widgets/my_page_menu_section.dart';

/// 마이페이지 화면
/// AppBar 없음 — 헤더가 스크롤과 함께 올라감
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 상단 보라 헤더 ──
            const MyPageHeader(),

            // ── 저장 유형 분포 (구분선 없음 — 첫 번째 섹션) ──
            const StorageTypeSection(),

            // ── 고객 지원 ──
            MyPageMenuSection(
              title: '고객 지원',
              items: const ['공지사항', '서비스 문의', '버그 제보하기'],
              onTaps: [
                () {}, // TODO: 공지사항
                () {}, // TODO: 서비스 문의
                () {}, // TODO: 버그 제보하기
              ],
            ),

            // ── 약관 및 정책 ──
            MyPageMenuSection(
              title: '약관 및 정책',
              items: const [
                '서비스 이용약관',
                '개인정보 처리방침',
                '마케팅 활용 및 정보 수신',
                '데이터 제공 정책',
              ],
              onTaps: [
                () {}, // TODO: 서비스 이용약관
                () {}, // TODO: 개인정보 처리방침
                () {}, // TODO: 마케팅 활용 및 정보 수신
                () {}, // TODO: 데이터 제공 정책
              ],
            ),

            // ── 설정 ──
            MyPageMenuSection(
              title: '설정',
              items: const ['알림 설정', '테마 설정', '로그아웃'],
              onTaps: [
                () {}, // TODO: 알림 설정
                () {}, // TODO: 테마 설정
                () {}, // TODO: 로그아웃
              ],
            ),

            const SizedBox(height: 100), // 하단 네비게이션 바 여백
          ],
        ),
      ),
    );
  }
}
