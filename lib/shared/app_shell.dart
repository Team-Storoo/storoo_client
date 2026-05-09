import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'widgets/nav_bar.dart';
import '../core/theme/app_colors.dart';
import 'widgets/confirm_action_dialog.dart';
import '../screens/home/home_screen.dart';
import '../screens/folder/folder_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/my_page/my_page_screen.dart';
import '../screens/save/link/link_save_screen.dart';
import '../screens/save/image/image_save_screen.dart';
import '../screens/save/note/note_save_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  final _homeKey = GlobalKey<HomeScreenState>();
  final _folderKey = GlobalKey<FolderScreenState>();
  final _myPageKey = GlobalKey<MyPageScreenState>();

  late final List<Widget> _screens = [
    HomeScreen(key: _homeKey),
    FolderScreen(
      key: _folderKey,
      onContentSaved: () => _homeKey.currentState?.refresh(),
    ),
    const SearchScreen(),
    MyPageScreen(key: _myPageKey),
  ];

  void _onTabTapped(int index) {
    if (index == 0) _homeKey.currentState?.refresh();
    if (index == 3) _myPageKey.currentState?.refresh();
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
      _myPageKey.currentState?.refresh();
    }

    Widget screen;
    if (type == 'link') {
      screen = SaveLinkScreen(onSaved: onSaved);
    } else if (type == 'image') {
      screen = SaveImageScreen(onSaved: onSaved);
    } else {
      screen = SaveNoteScreen(onSaved: onSaved);
    }

    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<bool> _onWillPop() async {
    return ConfirmActionDialog.show(
      context,
      iconColor: AppColors.primary,
      title: '앱을 종료하시겠어요?',
      message: '언제든지 Storoo로 돌아오실 수 있습니다!',
      confirmLabel: '종료',
      confirmColor: AppColors.primary,
      cancelLabel: '취소',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final exit = await _onWillPop();
        if (exit) SystemNavigator.pop();
      },
      child: Scaffold(
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
      ),
    );
  }
}

class _TypePickerSheet extends StatelessWidget {
  const _TypePickerSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
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
                    onTap: () => Navigator.of(context).pop('link'),
                  ),
                  const SizedBox(width: 12),
                  _TypeOption(
                    icon: Icons.image_outlined,
                    label: '이미지',
                    onTap: () => Navigator.of(context).pop('image'),
                  ),
                  const SizedBox(width: 12),
                  _TypeOption(
                    icon: Icons.edit_note_rounded,
                    label: '노트',
                    onTap: () => Navigator.of(context).pop('note'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TypeOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider, width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 32),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
