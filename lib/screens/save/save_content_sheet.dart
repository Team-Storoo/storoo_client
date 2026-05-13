import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../models/content.dart';
import '../../services/db_service.dart';

class SaveContentSheet extends StatefulWidget {
  final int folderId;
  final String folderName;
  final VoidCallback? onSaved;

  const SaveContentSheet({
    super.key,
    required this.folderId,
    required this.folderName,
    this.onSaved,
  });

  @override
  State<SaveContentSheet> createState() => _SaveContentSheetState();
}

class _SaveContentSheetState extends State<SaveContentSheet> {
  String _type = 'link';
  final _urlCtrl = TextEditingController();
  final _linkTitleCtrl = TextEditingController();
  final _imageTitleCtrl = TextEditingController();
  final _memoTitleCtrl = TextEditingController();
  final _memoContentCtrl = TextEditingController();
  XFile? _pickedImage;
  bool _saving = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _linkTitleCtrl.dispose();
    _imageTitleCtrl.dispose();
    _memoTitleCtrl.dispose();
    _memoContentCtrl.dispose();
    super.dispose();
  }

  void _changeType(String type) {
    setState(() {
      _type = type;
      _pickedImage = null;
    });
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image != null) setState(() => _pickedImage = image);
  }

  Future<void> _save() async {
    final content = Content()
      ..type = _type
      ..folderId = widget.folderId
      ..createdAt = DateTime.now();

    if (_type == 'link') {
      final url = _urlCtrl.text.trim();
      if (url.isEmpty) {
        _showSnack('URL을 입력해 주세요.(필수)');
        return;
      }
      content
        ..title = _linkTitleCtrl.text.trim().isEmpty ? url : _linkTitleCtrl.text.trim()
        ..url = url;
    } else if (_type == 'image') {
      if (_pickedImage == null) {
        _showSnack('이미지를 선택해 주세요.(필수)');
        return;
      }
      content
        ..title = _imageTitleCtrl.text.trim().isEmpty ? '이미지' : _imageTitleCtrl.text.trim()
        ..imageUrl = _pickedImage!.path;
    } else {
      final memoTitle = _memoTitleCtrl.text.trim();
      final memoContent = _memoContentCtrl.text.trim();
      if (memoTitle.isEmpty) {
        _showSnack('제목을 입력해 주세요.(필수)');
        return;
      }
      if (memoContent.isEmpty) {
        _showSnack('내용을 입력해 주세요.(선택)');
        return;
      }
      content
        ..title = memoTitle
        ..content = memoContent;
    }

    setState(() => _saving = true);
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
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: screenH * 0.88),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
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
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${widget.folderName}에 저장',
                  style: const TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _TypeChip(label: '링크', selected: _type == 'link', onTap: () => _changeType('link')),
                  const SizedBox(width: 8),
                  _TypeChip(label: '이미지', selected: _type == 'image', onTap: () => _changeType('image')),
                  const SizedBox(width: 8),
                  _TypeChip(label: '메모', selected: _type == 'memo', onTap: () => _changeType('memo')),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildForm(),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    if (_type == 'link') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('URL'),
          const SizedBox(height: 6),
          _InputField(controller: _urlCtrl, hint: 'https://...', keyboardType: TextInputType.url),
          const SizedBox(height: 16),
          const _Label('제목 (필수)'),
          const SizedBox(height: 6),
          _InputField(controller: _linkTitleCtrl, hint: '링크 제목을 입력하세요(필수)'),
          const SizedBox(height: 8),
        ],
      );
    } else if (_type == 'image') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('이미지'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: _pickedImage == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.textSecondary),
                        SizedBox(height: 8),
                        Text(
                          '갤러리에서 선택',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_pickedImage!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          const _Label('제목 (필수)'),
          const SizedBox(height: 6),
          _InputField(controller: _imageTitleCtrl, hint: '이미지 제목을 입력하세요(필수)'),
          const SizedBox(height: 8),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('제목'),
          const SizedBox(height: 6),
          _InputField(controller: _memoTitleCtrl, hint: '메모 제목을 입력하세요(필수)'),
          const SizedBox(height: 16),
          const _Label('내용'),
          const SizedBox(height: 6),
          _InputField(controller: _memoContentCtrl, hint: '내용을 입력하세요(필수)', maxLines: 5),
          const SizedBox(height: 8),
        ],
      );
    }
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'Pretendard',
        fontSize: 14,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
