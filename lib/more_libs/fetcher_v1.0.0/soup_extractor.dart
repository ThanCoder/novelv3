// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:novel_v3/more_libs/fetcher_v1.0.0/fetcher.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/selector_rules.dart';
import 'package:t_html_parser/t_html_parser.dart';

class SoupExtractor {
  final Map<String, SelectorRules> rules;
  SoupExtractor({required this.rules});

  Future<Map<String, String?>> extractFromUrl(String url) async {
    final html = await Fetcher.instance.onGetHtmlContent(url);
    return extract(html);
  }

  Map<String, String?> extract(String html, {bool isCleanHtmlTag = true}) {
    final result = <String, String?>{};
    // clean script
    final ele = html.toHtmlElement;
    if (ele == null) return result;

    if (isCleanHtmlTag) {
      ele.querySelectorAll('script,style,noscript').forEach((e) => e.remove());
    }

    rules.forEach((key, val) {
      if (val.attribute == null) {
        // is text
        final res = ele.getQuerySelectorHtml(selector: val.selector, attr: '');

        result[key] = isCleanHtmlTag ? cleanHtmlTag(res) : res;
      } else {
        // is attr
        final res = ele.getQuerySelectorAttr(
          selector: val.selector,
          attr: val.attribute!,
        );
        result[key] = res;
      }
    });
    return result;
  }

  static String cleanHtmlTag(String htmlStr) {
    // remove tag
    var res = htmlStr.replaceAll(
      RegExp(r'<br\s*/?>', caseSensitive: false),
      '\n',
    );
    res = res.replaceAll(
      RegExp(r'</?(p|div|h[1-6])[^>]*>', caseSensitive: false),
      '\n',
    );
    res = res.replaceAll(RegExp(r'<[^>]+>'), '');
    res = res.replaceAll(RegExp(r'\n\s*\n+'), '\n\n');
    return res;
  }
}
