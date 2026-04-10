import 'package:flutter/material.dart';

class IntroPageData {
  const IntroPageData({
    required this.title,
    this.subtitle,
    this.isFirstPage = false,
    this.iconPath,
    required this.imagePath,
  });

  final String title;
  final String? subtitle;
  final bool isFirstPage;
  final String? iconPath;
  final String imagePath;
}

const kIntroPages = [
  IntroPageData(
    isFirstPage: true,
    title: '링크 · 이미지 · 메모를\n한 곳으로 저장',
    subtitle: '나만의 작은 저장 공간',
    imagePath: 'assets/intro/page1.png',
  ),
  IntroPageData(
    iconPath: 'assets/intro/icon2.png',
    title: '내 저장한 자료들을\n폴더별로 분류하여 저장해요',
    imagePath: 'assets/intro/page2.png',
  ),
  IntroPageData(
    iconPath: 'assets/intro/icon3.png',
    title: '키워드 · 태그를 이용하여\n필요한 자료를 빠르게 찾아보세요',
    imagePath: 'assets/intro/page3.png',
  ),
  IntroPageData(
    iconPath: 'assets/intro/icon4.png',
    title: '내가 저장한 자료에 대한\n자세한 정보를 수정할 수 있어요',
    imagePath: 'assets/intro/page4.png',
  ),
  IntroPageData(
    iconPath: 'assets/intro/icon5.png',
    title: '키워드 · 태그를 이용하여\n필요한 자료를 빠르게 찾아보세요',
    imagePath: 'assets/intro/page5.png',
  ),
];
