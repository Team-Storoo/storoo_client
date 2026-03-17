# 📎 Storoo

> **Save everything. Find anything.**
> 링크, 메모, 스크린샷, 사진을 하나의 앱에서 저장하고 검색하는 통합 콘텐츠 저장 앱

<br>

## 📱 소개

우리는 인터넷을 사용하면서 유용한 링크, 메모, 사진, 스크린샷 등 다양한 형태의 정보를 저장하고 싶을 때가 많습니다.  
하지만 기존 앱들은 각각 한 가지 유형만 저장할 수 있어 여러 앱을 동시에 사용해야 하는 불편함이 있습니다.

**Storoo**는 이 문제를 해결하기 위해 만들어진 앱입니다.  
링크, 메모, 스크린샷, 사진을 하나의 앱에서 폴더별로 분류하고, 키워드 검색으로 빠르게 찾을 수 있습니다.

<br>

## ✨ 주요 기능

### 콘텐츠 저장
- **링크 저장** — URL 입력 시 사이트 제목, 설명, 미리보기 이미지 자동 추출
- **메모 저장** — 텍스트 직접 입력, 볼드/리스트 등 서식 지원
- **사진 저장** — 갤러리에서 선택 또는 카메라 직접 촬영
- **스크린샷 저장** — 기기 스크린샷 바로 저장
- **Share Extension** — 다른 앱(브라우저, 카카오톡 등)에서 공유 버튼으로 Storoo에 바로 저장

### 폴더 및 태그 관리
- 폴더 생성 · 수정 · 삭제 및 이모지 커스터마이징
- 항목에 태그(#) 추가 — 폴더 구분 없이 태그로도 묶어서 조회 가능
- 정렬 기능 — 최신순 / 이름순 / 사용자 지정순

### 검색
- 키워드 검색 — 제목, 메모 내용, URL, 태그 전체 대상 통합 검색
- 필터 검색 — 콘텐츠 유형(링크/메모/사진/스크린샷) / 날짜 범위 / 폴더 / 태그별 필터
- 검색 히스토리 저장 및 재사용

### 기타
- 그리드 / 리스트 뷰 전환
- 즐겨찾기 기능
- 휴지통 — 삭제 항목 30일 보관 후 자동 제거
- 다크 모드 지원

<br>

## 🛠 기술 스택

| 분류 | 기술 | 설명 |
|------|------|------|
| UI 프레임워크 | Flutter (Dart) | Android 앱 개발, 추후 iOS 확장 가능한 구조 |
| 상태 관리 | Riverpod | 타입 안전성 높고 테스트 용이 |
| 로컬 DB | Isar Database | Flutter 최적화 고속 로컬 DB, 전문 검색 지원 |
| 클라우드 / 인증 | Firebase (Auth + Firestore) | 서버 직접 구축 없이 인증 · 동기화 가능 |
| 이미지 저장 | 로컬 저장 + Firebase Storage | 원본은 기기에, 압축본만 클라우드에 저장하여 용량 절감 |
| 디자인 | Figma → Flutter | Figma로 화면 설계 후 Flutter로 구현 |
| CI/CD | GitHub Actions | 자동 빌드 · 테스트 파이프라인 |

<br>

## 📂 화면 구성

```
Storoo
├── Loading Page        # 스플래시 화면
├── Main Page           # 홈 — 최근 저장 항목 / 내 폴더 요약
├── Folder Page         # 전체 폴더 목록 (그리드)
├── In Folder Page      # 폴더 내 항목 목록 (링크 / 이미지 / 메모 탭)
├── Search Page         # 키워드 + 필터 통합 검색
├── Detail & Save Page  # 저장 항목 상세 보기 및 편집
└── My Page             # 프로필 / 설정 / 동기화 등
```

**네비게이션바**: 홈 · 폴더 · +(저장) · 검색 · 마이페이지

<br>

## 🗂 프로젝트 구조

```
lib/
├── domain/
│   ├── entities/         # ContentItem, Folder, Tag 엔티티
│   ├── repositories/     # Repository 인터페이스
│   └── value_objects/    # Url, TagName 등
├── application/
│   ├── use_cases/        # SaveLinkUseCase, SearchUseCase 등
│   └── dtos/             # 입출력 데이터 객체
├── infrastructure/
│   ├── repositories/     # Isar 기반 Repository 구현체
│   ├── datasources/      # 로컬 / 클라우드 데이터소스
│   └── services/         # OgMetaService, OCRService 등
├── presentation/
│   ├── screens/          # 각 화면 위젯
│   ├── widgets/          # 공통 컴포넌트
│   └── view_models/      # 화면별 상태 관리
└── core/
    ├── di/               # Riverpod Provider 설정
    ├── error/            # Failure, AppException
    └── utils/            # 공통 유틸리티

변경될 가능성 있음
```

<br>

## 🚀 개발 환경 세팅

```bash
# 1. 레포지토리 클론
git clone https://github.com/Team-Storoo/storoo_client

# 2. 패키지 설치
flutter pub get

# 3. Firebase 설정
# google-services.json을 android/app/ 경로에 추가 예정

# 4. 앱 실행
flutter run
```

**요구 환경**
- Flutter 3.x 이상
- Dart 3.x 이상
- Android Studio 또는 VS Code
- Android SDK (API 29 이상)

<br>

## 📅 개발 일정

이후 설계 예정

<br>

## 👥 팀원

| 이름 | 학번 | 소속 | 담당 역할 |
|------|------|------|-----------|
| 김수종 | 202395007 | 신라대학교 컴퓨터공학과 | 앱 UI/UX 디자인 (Figma), 프론트엔드 개발 |
| 박수연 | 202395016 | 신라대학교 컴퓨터공학부 | 프로젝트 기획 및 설계, 요구사항 정의, 아키텍처 설계 |

<br>

## 📄 라이선스

All rights reserved

<br>

---

> 📌 본 README는 개발 진행에 따라 지속적으로 업데이트됩니다.