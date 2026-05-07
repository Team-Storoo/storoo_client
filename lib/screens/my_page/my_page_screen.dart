import 'package:flutter/material.dart';
import '../../services/db_service.dart';
import './widgets/my_page_header.dart';
import './widgets/storage_type_section.dart';
import './widgets/my_page_menu_section.dart';
import './support/notice_screen.dart';
import './support/inquiry_screen.dart';
import './support/bug_report_screen.dart';
import './policy/terms_screen.dart';
import './policy/privacy_screen.dart';
import './policy/marketing_screen.dart';
import './policy/data_policy_screen.dart';
import './settings/notification_screen.dart';
import './settings/theme_screen.dart';
import './settings/home_setting_screen.dart';

/// 마이페이지 화면
class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => MyPageScreenState();
}

class MyPageScreenState extends State<MyPageScreen> {
  String _nickname = '';
  final _storageKey = GlobalKey<StorageTypeSectionState>();

  @override
  void initState() {
    super.initState();
    _loadNickname();
  }

  Future<void> refresh() async {
    await _storageKey.currentState?.refresh();
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _loadNickname() async {
    final profile = await DBService.getUserProfile();
    if (mounted) {
      setState(() {
        _nickname = profile?.nickname ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 상단 보라 헤더 ──
            MyPageHeader(nickname: _nickname),

            // ── 저장 유형 분포 ──
            StorageTypeSection(key: _storageKey),

            // ── 고객 지원 ──
            MyPageMenuSection(
              title: '고객 지원',
              items: const ['공지사항', '서비스 문의', '버그 제보하기'],
              onTaps: [
                () => _push(const NoticeScreen()),
                () => _push(const InquiryScreen()),
                () => _push(const BugReportScreen()),
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
                () => _push(const TermsScreen()),
                () => _push(const PrivacyScreen()),
                () => _push(const MarketingScreen()),
                () => _push(const DataPolicyScreen()),
              ],
            ),

            // ── 설정 ──
            MyPageMenuSection(
              title: '설정',
              items: const ['알림 설정', '테마 설정', '홈화면 설정', '로그아웃'],
              onTaps: [
                () => _push(const NotificationScreen()),
                () => _push(const ThemeScreen()),
                () => _push(const HomeSettingScreen()),
                () {}, // TODO: 로그아웃
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
