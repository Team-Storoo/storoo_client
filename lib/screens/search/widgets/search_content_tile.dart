import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/content.dart';

/// 폴더 내 항목 검색 결과 카드
/// 아이콘(또는 썸네일) + 제목 + 날짜/출처 + 폴더 경로 + 타입 표시
class SearchContentTile extends StatelessWidget {
  final Content content;
  final String folderName;
  final VoidCallback onTap;

  const SearchContentTile({
    super.key,
    required this.content,
    required this.folderName,
    required this.onTap,
  });

  // ── 헬퍼 ──────────────────────────────────────────────────

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';

  String _extractSource(String? url) {
    if (url == null || url.isEmpty) return '';
    try {
      final host = Uri.parse(url).host.toLowerCase();
      if (host.contains('youtube.com') || host.contains('youtu.be')) {
        return 'Youtube';
      }
      if (host.contains('instagram.com')) return 'Instagram';
      if (host.contains('twitter.com') || host.contains('x.com')) {
        return 'Twitter';
      }
      if (host.contains('naver.com')) return 'Naver';
      if (host.contains('tiktok.com')) return 'TikTok';
      final domain = host.startsWith('www.') ? host.substring(4) : host;
      final part = domain.split('.').first;
      return part.isEmpty ? domain : part[0].toUpperCase() + part.substring(1);
    } catch (_) {
      return '';
    }
  }

  String get _typeLabel {
    switch (content.type) {
      case 'image':
        return '이미지';
      case 'memo':
        return '노트';
      default:
        return '링크';
    }
  }

  String _dateSourceText() {
    final date = _formatDate(content.createdAt);
    if (content.type == 'link') {
      final source = _extractSource(content.url);
      return source.isNotEmpty ? '$date | $source' : date;
    }
    return date;
  }

  // ── 아이콘 / 썸네일 ────────────────────────────────────────

  Widget _buildThumbnail() {
    // 이미지 타입은 effectiveImageUrls.first (다중 경로 인코딩 대응)
    if (content.type == 'image') {
      final paths = content.effectiveImageUrls;
      if (paths.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            File(paths.first),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _iconBox(),
          ),
        );
      }
      return _iconBox();
    }
    // 링크 타입 OG 이미지
    final imageUrl = content.imageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconBox(),
        ),
      );
    }
    return _iconBox();
  }

  Widget _iconBox() {
    final IconData icon;
    switch (content.type) {
      case 'image':
        icon = Icons.image_outlined;
        break;
      case 'memo':
        icon = Icons.sticky_note_2_outlined;
        break;
      default:
        icon = Icons.link;
    }
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: AppColors.textSecondary, size: 26),
    );
  }

  // ── 빌드 ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildThumbnail(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _dateSourceText(),
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '폴더 > $folderName > $_typeLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
