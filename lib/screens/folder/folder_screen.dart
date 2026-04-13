import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'folder_item.dart';
import '../in_folder/in_folder_screen.dart';
import './widgets/folder_filter_row.dart';
import './widgets/folder_grid.dart';
import './widgets/create_folder_dialog.dart';

/// 폴더 화면
/// 로친 상태로 폴더 목록 관리 (개발/테스트 용)
class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key});

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final List<FolderItem> _folders = [];
  FolderSortFilter _filter = FolderSortFilter.total;

  List<FolderItem> get _sorted {
    final list = List<FolderItem>.from(_folders);
    switch (_filter) {
      case FolderSortFilter.name:
        list.sort((a, b) => a.name.compareTo(b.name));
      case FolderSortFilter.recent:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case FolderSortFilter.total:
      case FolderSortFilter.custom:
        break;
    }
    return list;
  }

  Future<void> _showCreateDialog() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreateFolderDialog(),
    );
    if (name == null || name.isEmpty) return;
    setState(() {
      _folders.add(
        FolderItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          createdAt: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          title: Text(
            '내 폴더',
            style: AppTextStyles.headline1.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: _showCreateDialog,
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Icon(Icons.add, color: AppColors.textPrimary),
              ),
            ),
            GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.only(
                  left: 4,
                  right: 16,
                  top: 12,
                  bottom: 12,
                ),
                child: Icon(Icons.more_vert, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            FolderFilterRow(
              total: _folders.length,
              selectedFilter: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
            Expanded(
              child: FolderGrid(
                folders: _sorted,
                onAddTap: _showCreateDialog,
                onFolderTap: (folder) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => InFolderScreen(folder: folder),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
