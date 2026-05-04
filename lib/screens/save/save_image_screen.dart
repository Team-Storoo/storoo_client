import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../models/content.dart';
import '../../models/folder_item.dart';
import '../../services/db_service.dart';
import '../folder/widgets/create_folder_dialog.dart';

class SaveImageScreen extends StatefulWidget {
  final VoidCallback? onSaved;

  const SaveImageScreen({super.key, this.onSaved});

  @override
  State<SaveImageScreen> createState() => _SaveImageScreenState();
}

class _SaveImageScreenState extends State<SaveImageScreen> {
  final _titleCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  final _tagFocusNode = FocusNode();

  List<FolderItem> _folders = [];
  FolderItem? _selectedFolder;
  XFile? _pickedImage;
  final List<String> _tags = [];
  bool _showTagInput = false;
  bool _saving = false;
  bool _loadingFolders = true;

  static const int _maxFolders = 5;
  static const int _maxTags = 10;

  @override
  void initState() {
    super.initState();
    _loadFolders();
    _titleCtrl.addListener(() => setState(() {}));
    _tagFocusNode.addListener(() {
      if (!_tagFocusNode.hasFocus && _showTagInput) {
        _addTag();
      }
    });
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _memoCtrl.dispose();
    _tagCtrl.dispose();
    _tagFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadFolders() async {
    final folders = await DBService.getFolders();
    if (mounted) {
      setState(() {
        _folders = folders;
        _selectedFolder ??= folders.isNotEmpty ? folders.first : null;
        _loadingFolders = false;
      });
    }
  }

  Future<void> _createFolder() async {
    if (_folders.length >= _maxFolders) {
      _showSnack('폴더는 최대 $_maxFolders개까지 만들 수 있어요.');
      return;
    }

    final name = await showDialog<String>(
      context: context,
      builder: (_) => const CreateFolderDialog(),
    );
    if (name == null || name.isEmpty || !mounted) return;

    final folder = FolderItem()
      ..name = name
      ..createdAt = DateTime.now()
      ..itemCount = 0;

    await DBService.saveFolder(folder);
    final newId = folder.id;

    final updated = await DBService.getFolders();
    if (mounted) {
      setState(() {
        _folders = updated;
        _selectedFolder = _folders.firstWhere(
          (f) => f.id == newId,
          orElse: () => _folders.last,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) setState(() => _pickedImage = image);
  }

  void _addTag() {
    final tag = _tagCtrl.text.trim();
    if (tag.isEmpty) {
      setState(() => _showTagInput = false);
      return;
    }
    if (_tags.contains(tag)) {
      _showSnack('이미 추가된 태그예요.');
      setState(() {
        _showTagInput = false;
        _tagCtrl.clear();
      });
      return;
    }
    if (_tags.length >= _maxTags) {
      _showSnack('태그는 최대 $_maxTags개까지 추가할 수 있어요.');
      return;
    }
    setState(() {
      _tags.add(tag);
      _tagCtrl.clear();
      _showTagInput = false;
    });
  }

  Future<void> _save() async {
    if (_pickedImage == null) {
      _showSnack('이미지를 선택해 주세요.');
      return;
    }
    if (_selectedFolder == null) {
      _showSnack('저장할 폴더를 선택해 주세요.');
      return;
    }

    setState(() => _saving = true);
    final memo = _memoCtrl.text.trim();
    final content = Content()
      ..type = 'image'
      ..folderId = _selectedFolder!.id
      ..title = _titleCtrl.text.trim()
      ..imageUrl = _pickedImage!.path
      ..content = memo.isEmpty ? null : memo
      ..tags = List.from(_tags)
      ..createdAt = DateTime.now();

    await DBService.saveContentToFolder(content);
    if (mounted) {
      setState(() => _saving = false);
      widget.onSaved?.call();
      Navigator.of(context).pop();
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Pretendard')),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          behavior: HitTestBehavior.opaque,
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary,
            size: 24,
          ),
        ),
        title: const Text(
          '이미지 저장',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 24, 20, bottomInset + 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionLabel('이미지', isRequired: true),
                  const SizedBox(height: 8),
                  _buildImagePicker(),
                  const SizedBox(height: 24),
                  const _SectionLabel('제목', isRequired: true),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _titleCtrl,
                    hint: '이미지 제목을 입력하세요',
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('저장 폴더', isRequired: true),
                  const SizedBox(height: 10),
                  if (_loadingFolders)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    _buildFolderGrid(),
                  const SizedBox(height: 24),
                  const _SectionLabel('메모'),
                  const SizedBox(height: 8),
                  _InputField(
                    controller: _memoCtrl,
                    hint: '추가 메모를 입력하세요 (선택)',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  _buildTagSection(),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
            ),
            padding: EdgeInsets.fromLTRB(20, 12, 20, safeBottom + 20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_saving ||
                        _selectedFolder == null ||
                        _pickedImage == null ||
                        _titleCtrl.text.trim().isEmpty)
                    ? null
                    : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primaryLight,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        '저장하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickedImage == null ? _pickImage : null,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _pickedImage != null ? AppColors.primary : AppColors.divider,
            width: _pickedImage != null ? 1.5 : 1,
          ),
        ),
        child: _pickedImage == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 10),
                  Text(
                    '탭하여 갤러리에서 선택',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.file(
                      File(_pickedImage!.path),
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _pickedImage = null),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              '변경',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFolderGrid() {
    final showAddCard = _folders.length < _maxFolders;
    final itemCount = _folders.length + (showAddCard ? 1 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemCount: itemCount,
      itemBuilder: (_, i) {
        if (i == _folders.length) {
          return _AddFolderCard(onTap: _createFolder);
        }
        final folder = _folders[i];
        return _FolderSelectCard(
          folder: folder,
          selected: _selectedFolder?.id == folder.id,
          onTap: () => setState(() => _selectedFolder = folder),
        );
      },
    );
  }

  Widget _buildTagSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('태그'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ..._tags.map(_buildTagChip),
            if (_showTagInput)
              SizedBox(
                width: 130,
                height: 36,
                child: TextField(
                  controller: _tagCtrl,
                  focusNode: _tagFocusNode,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _addTag(),
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '태그 입력 후 완료',
                    hintStyle: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: () {
                  setState(() => _showTagInput = true);
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => _tagFocusNode.requestFocus(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: AppColors.primary, size: 14),
                      SizedBox(width: 4),
                      Text(
                        '태그 추가하기',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 7, bottom: 7),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '#$tag',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _tags.remove(tag)),
            child: const Icon(Icons.close, color: AppColors.primary, size: 14),
          ),
        ],
      ),
    );
  }
}

class _FolderSelectCard extends StatelessWidget {
  final FolderItem folder;
  final bool selected;
  final VoidCallback onTap;

  const _FolderSelectCard({
    required this.folder,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : const Color(0xFFF8F8F8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder_outlined,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    folder.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${folder.itemCount}개',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 11,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}

class _AddFolderCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddFolderCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD0D0D0)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.create_new_folder_outlined,
              color: AppColors.textSecondary,
              size: 26,
            ),
            SizedBox(height: 6),
            Text(
              '폴더 만들기',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const _SectionLabel(this.text, {this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '(필수)',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 15,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 15,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
