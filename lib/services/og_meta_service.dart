import 'package:http/http.dart' as http;

/// Open Graph 메타 태그 파싱 서비스
/// OG title, image URL을 URL에서 자동 추출
class OgMetaService {
  OgMetaService._();

  static const _timeout = Duration(seconds: 10);
  static const _userAgent =
      'Mozilla/5.0 (compatible; StorooBot/1.0; +https://storoo.app)';

  // triple-quoted raw strings: 따옴표 클래스를 raw string 안에 안전하게 정의
  static const _q = r'''["']'''; // ["'] — " 또는 ' 매칭
  static const _nq = r'''[^"']*'''; // [^"']* — 따옴표 외 문자들

  /// [url]에서 OG title과 이미지 URL을 파싱하여 반환
  /// 실패 시 OgMeta() 반환 (저장은 정상 진행)
  static Future<OgMeta> fetch(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);

      if (response.statusCode != 200) return const OgMeta();

      final body = response.body;
      final title =
          _ogTag(body, 'og:title') ??
          _ogTag(body, 'twitter:title') ??
          _htmlTitle(body);
      final imageUrl =
          _ogTag(body, 'og:image') ?? _ogTag(body, 'twitter:image');

      return OgMeta(title: title, imageUrl: imageUrl);
    } catch (_) {
      return const OgMeta();
    }
  }

  // ── 파싱 헬퍼 ──────────────────────────────────────────────

  static String? _ogTag(String html, String property) {
    final prop = RegExp.escape(property);

    // pattern A: property="..." content="..."
    final a = RegExp(
      '<meta[^>]+property=$_q$prop${_q}[^>]+content=$_q($_nq)$_q',
      caseSensitive: false,
    ).firstMatch(html)?.group(1);
    if (a != null && a.isNotEmpty) return _decode(a);

    // pattern B: content="..." property="..."
    final b = RegExp(
      '<meta[^>]+content=$_q($_nq)${_q}[^>]+property=$_q$prop$_q',
      caseSensitive: false,
    ).firstMatch(html)?.group(1);
    if (b != null && b.isNotEmpty) return _decode(b);

    // pattern C: name="twitter:..." content="..."
    final c = RegExp(
      '<meta[^>]+name=$_q$prop${_q}[^>]+content=$_q($_nq)$_q',
      caseSensitive: false,
    ).firstMatch(html)?.group(1);
    return c != null && c.isNotEmpty ? _decode(c) : null;
  }

  static String? _htmlTitle(String html) {
    final m = RegExp(
      r'<title[^>]*>\s*([^<]+)\s*</title>',
      caseSensitive: false,
    ).firstMatch(html);
    final t = m?.group(1)?.trim();
    return t != null && t.isNotEmpty ? _decode(t) : null;
  }

  static String _decode(String text) =>
      text
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&quot;', '"')
          .replaceAll('&#39;', "'")
          .replaceAll('&nbsp;', ' ')
          .trim();
}

class OgMeta {
  final String? title;
  final String? imageUrl;
  const OgMeta({this.title, this.imageUrl});
}
