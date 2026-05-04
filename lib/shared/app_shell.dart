import 'package:flutter/material.dart';
import 'widgets/nav_bar.dart';
import '../core/theme/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/folder/folder_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/my_page/my_page_screen.dart';
import '../screens/save/save_link_screen.dart';
import '../screens/save/save_image_screen.dart';
import '../screens/save/save_note_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final _homeKey = GlobalKey<HomeScreenState>();
  final _folderKey = GlobalKey<FolderScreenState>();

  late final List<Widget> _screens = [
    HomeScreen(key: _homeKey),
    FolderScreen(key: _folderKey),
    const SearchScreen(),
    const MyPageScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 0) {
      _homeKey.currentState?.refresh();
    }
    setState(() => _selectedIndex = index);
  }

  Future<void> _onSaveFabTapped() async {
    final type = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _TypePickerSheet(),
    );
    if (type == null || !mounted) return;

    void onSaved() {
      _homeKey.currentState?.refresh();
      _folderKey.currentState?.refresh();
    }

    Widget screen;
    if (type == 'link') {
      screen = SaveLinkScreen(onSaved: onSaved);
    } else if (type == 'image') {
      screen = SaveImageScreen(onSaved: onSaved);
    } else {
      screen = SaveNoteScreen(onSaved: onSaved);
    }

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: SizedBox(
        height: 92,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AppNavBar(
                selectedIndex: _selectedIndex,
                onTap: _onTabTapped,
              ),
            ),
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(child: _SaveFab(onTap: _onSaveFabTapped)),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypePickerSheet extends StatelessWidget {
  const _TypePickerSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '무엇을 저장할까요?',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _TypeOption(
                  icon: Icons.link_rounded,
                  label: '링크',
                  iconColor: const Color(0xFF4A90E2),
                  bgColor: const Color(0xFFEDF4FF),
                  onTap: () => Navigator.of(context).pop('link'),
                ),
                const SizedBox(width: 12),
                _TypeOption(
                  icon: Icons.image_outlined,
                  label: '이미지',
                  iconColor: const Color(0xFF2DAB6F),
                  bgColor: const Color(0xFFE8F8F0),
                  onTap: () => Navigator.of(context).pop('image'),
                ),
                const SizedBox(width: 12),
                _TypeOption(
                  icon: Icons.edit_note_rounded,
                  label: '노트',
                  iconColor: const Color(0xFFE07B2A),
                  bgColor: const Color(0xFFFFF3E8),
                  onTap: () => Navigator.of(context).pop('note'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _TypeOption({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: iconColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveFab extends StatelessWidget {
  const _SaveFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
