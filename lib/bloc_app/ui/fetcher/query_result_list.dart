import 'package:t_html_parser/core/q_result/attributes.dart';
import 'package:t_html_parser/core/q_result/web_utils.dart';
import 'package:t_html_parser/t_html_parser.dart';

class QueryResultList {
  final Attribute attr;
  final String selector;
  final String cleanDomTags;
  final bool isCleanDomTags;
  QueryResultList({
    required this.attr,
    required this.selector,
    this.isCleanDomTags = false,
    this.cleanDomTags = 'script,style,noscript',
  });

  // String _getText(List<>)

  List<String> getResult(String html) {
    List<String> results = [];
    // dom
    final dom = html.toHtmlDocument;
    if (isCleanDomTags && cleanDomTags.isNotEmpty) {
      dom.cleanDomTag(tagNames: cleanDomTags);
    }
    // query selector
    for (var ele in dom.querySelectorAll(selector)) {
      String? result;
      // print(ele.attributes);
      if (attr.value == 'text') {
        result = ele.text.trim();
      } else if (attr.value == 'textContent') {
        result = ele.textContent;
      } else if (attr.value == 'html') {
        result = ele.innerHtml.trim();
      } else if (attr.value == 'outerHtml') {
        result = ele.outerHtml.trim();
      } else {
        // attribute
        result = ele.attributes[attr.value];
      }
      if (result == null) continue;
      results.add(result);
    }
    return results;
  }
}
