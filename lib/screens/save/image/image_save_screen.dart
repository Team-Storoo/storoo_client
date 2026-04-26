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

/// 이미지 저장 화면
/// 필수: 이미지 1장 이상(최대 5장), 제목, 저장 폴더
/// 선택: 메모(최대 200자), 태그
class ImageSaveScreen extends StatefulWidget {
  const ImageSaveScreen({super.key});

  @override
  State<ImageSaveScreen> createState() => _ImageSaveScreenState();
}

class _ImageSaveScreenState extends State<ImageSaveScreen> {
  final _titleCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();

  late List<FolderItem> _folders;
  String? _selectedFolderId;
  final List<String> _tags = [];

  /// 더미 이미지 목록 (색상 코드로 표현, 최대 5개)
  final List<Color> _images = [];
  static const int _maxImages = 5;

  /// 더미용 색상 팔레트
  static const List<Color> _palette = [
    Color(0xFFB39DDB),
    Color(0xFF80CBC4),
    Color(0xFFFFCC80),
    Color(0xFFEF9A9A),
    Color(0xFFA5D6A7),
  ];

  bool get _canSave =>
      _images.isNotEmpty &&
      _titleCtrl.text.trim().isNotEmpty &&
      _selectedFolderId != null;

  @override
  void initState() {
    super.initState();
    _folders = createDummyFolders();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  void _addImage() {
    if (_images.length >= _maxImages) return;
    setState(() {
      _images.add(_palette[_images.length % _palette.length]);
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
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
                    // ── 이미지 ──
                    const Text(
                      '이미지',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _ImagePickerRow(
                      images: _images,
                      maxImages: _maxImages,
                      onAdd: _addImage,
                      onRemove: _removeImage,
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

/// 이미지 추가 영역 — 추가 버튼 + 첨부된 이미지 썸네일 가로 스크롤
class _ImagePickerRow extends StatelessWidget {
  const _ImagePickerRow({
    required this.images,
    required this.maxImages,
    required this.onAdd,
    required this.onRemove,
  });

  final List<Color> images;
  final int maxImages;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;

  static const double _itemSize = 88.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _itemSize,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 추가 버튼 (이미지가 최대 개수 미만일 때만 표시)
          if (images.length < maxImages)
            GestureDetector(
              onTap: onAdd,
              child: Container(
                width: _itemSize,
                height: _itemSize,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 28,
                      color: Color(0xFFAAAAAA),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '사진 첨부',
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                    Text(
                      '${images.length}/$maxImages',
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),

          // 첨부된 이미지 썸네일
          ...images.asMap().entries.map(
            (e) => _ImageThumbnail(
              color: e.value,
              index: e.key,
              onRemove: () => onRemove(e.key),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  const _ImageThumbnail({
    required this.color,
    required this.index,
    required this.onRemove,
  });

  final Color color;
  final int index;
  final VoidCallback onRemove;

  static const double _size = 88.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showRemoveDialog(context),
      child: Container(
        width: _size,
        height: _size,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.image,
                size: 32,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 13, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRemoveDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              '이미지 삭제',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: const Text(
              '첨부된 이미지를 삭제하시겠습니까?',
              style: TextStyle(fontFamily: 'Pretendard', fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  overlayColor: Colors.transparent,
                ),
                child: const Text(
                  '취소',
                  style: TextStyle(fontFamily: 'Pretendard'),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  onRemove();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  overlayColor: Colors.transparent,
                ),
                child: const Text(
                  '삭제',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
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
