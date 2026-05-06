import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 이미지 타입 상세 화면 상단 캐러셀 (페이지 점 인디케이터 포함)
class DetailImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  const DetailImageCarousel({super.key, required this.imagePaths});

  @override
  State<DetailImageCarousel> createState() => _DetailImageCarouselState();
}

class _DetailImageCarouselState extends State<DetailImageCarousel> {
  final _pageCtrl = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imagePaths.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: widget.imagePaths.length,
              onPageChanged: (i) => setState(() => _current = i),
              itemBuilder: (_, i) {
                final path = widget.imagePaths[i];
                return path.startsWith('http')
                    ? Image.network(
                      path,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              const ColoredBox(color: Color(0xFFF0F0F0)),
                    )
                    : Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) =>
                              const ColoredBox(color: Color(0xFFF0F0F0)),
                    );
              },
            ),
          ),
        ),
        if (widget.imagePaths.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.imagePaths.length, (i) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _current == i ? 8 : 6,
                height: _current == i ? 8 : 6,
                decoration: BoxDecoration(
                  color: _current == i ? AppColors.primary : AppColors.divider,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
