import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/content.dart';

class RecentSavedList extends StatelessWidget {
  final List<Content> items;

  const RecentSavedList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return SizedBox(
        height: 140,
        child: Center(
          child: Text(
            '아직 저장된 항목이 없어요',
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) => _RecentItemCard(item: items[index]),
      ),
    );
  }
}

class _RecentItemCard extends StatelessWidget {
  final Content item;

  const _RecentItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopArea(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const Spacer(),
                  _TypeBadge(type: item.type),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopArea() {
    if (item.type == 'image' && item.imageUrl != null && item.imageUrl!.isNotEmpty) {
      return SizedBox(
        height: 72,
        width: double.infinity,
        child: Image.network(
          item.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iconBox(Icons.broken_image_outlined, AppColors.divider, AppColors.textSecondary),
        ),
      );
    }

    switch (item.type) {
      case 'link':
        return _iconBox(Icons.link_rounded, AppColors.primaryLight, AppColors.primary);
      case 'image':
        return _iconBox(Icons.image_outlined, const Color(0xFFE8F5E9), const Color(0xFF43A047));
      case 'memo':
        return _iconBox(Icons.notes_rounded, const Color(0xFFFFF3E0), const Color(0xFFFF8F00));
      default:
        return _iconBox(Icons.insert_drive_file_outlined, AppColors.primaryLight, AppColors.primary);
    }
  }

  Widget _iconBox(IconData icon, Color bg, Color iconColor) {
    return Container(
      height: 72,
      width: double.infinity,
      color: bg,
      child: Icon(icon, color: iconColor, size: 30),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;

  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      'link' => ('링크', AppColors.primary),
      'image' => ('이미지', const Color(0xFF43A047)),
      'memo' => ('메모', const Color(0xFFFF8F00)),
      _ => ('기타', AppColors.textSecondary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pretendard',
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
