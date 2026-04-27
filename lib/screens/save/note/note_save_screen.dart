import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../folder/folder_item.dart';
import '../../folder/widgets/create_folder_dialog.dart';
import '../save_dummy_data.dart';
import '../widgets/folder_selector.dart';
import '../widgets/memo_field.dart';
import '../widgets/tag_input_row.dart';
import '../widgets/save_button.dart';

/// 노트 저장 화면
/// 필수: 노트 내용, 제목, 저장 폴더
/// 선택: 메모(최대 200자), 태그
class NoteSaveScreen extends StatefulWidget {
  const NoteSaveScreen({super.key});

  @override
  State<NoteSaveScreen> createState() => _NoteSaveScreenState();
}

class _NoteSaveScreenState extends State<NoteSaveScreen> {
  final _noteCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();

  late List<FolderItem> _folders;
  String? _selectedFolderId;
  final List<String> _tags = [];

  bool get _canSave =>
      _noteCtrl.text.trim().isNotEmpty &&
      _titleCtrl.text.trim().isNotEmpty &&
      _selectedFolderId != null;

  @override
  void initState() {
    super.initState();
    _folders = createDummyFolders();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    _titleCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  Future<void> _showAddFolderDialog() async {
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

  Future<void> _showAddTagDialog() async {
    final tag = await TagAddDialog.show(context);
    if (tag == null || tag.isEmpty) return;
    setState(() => _tags.add(tag));
  }

  void _onSave() {
    // TODO: DB 연동 시 실제 저장 로직 추가
    Navigator.pop(context);
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
          centerTitle: true,
          title: Text('저장', style: AppTextStyles.headline2),
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            behavior: HitTestBehavior.opaque,
            child: const Center(
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 20,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 노트 ──
                    const Text(
                      '노트',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteCtrl,
                      maxLines: 6,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.body,
                      decoration: InputDecoration(
                        hintText: '내용을 입력해주세요.',
                        hintStyle: AppTextStyles.caption,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── 제목 ──
                    const Text(
                      '제목',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _InputField(
                      controller: _titleCtrl,
                      hint: '제목을 입력해주세요.',
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // ── 저장 폴더 ──
                    FolderSelector(
                      folders: _folders,
                      selectedFolderId: _selectedFolderId,
                      onSelect: (id) => setState(() => _selectedFolderId = id),
                      onAddFolder: _showAddFolderDialog,
                    ),
                    const SizedBox(height: 20),

                    // ── 메모 ──
                    MemoField(
                      controller: _memoCtrl,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 20),

                    // ── 태그 ──
                    TagInputRow(
                      tags: _tags,
                      onAdd: _showAddTagDialog,
                      onRemove: (i) => setState(() => _tags.removeAt(i)),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ── 저장 버튼 ──
            Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                8,
                20,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: SaveButton(enabled: _canSave, onTap: _onSave),
            ),
          ],
        ),
      ),
    );
  }
}

/// 공통 단일 라인 입력 필드
class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: (_) => onChanged(),
      style: AppTextStyles.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.caption,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
