import 'package:t_html_parser/t_html_parser.dart';

class FQuery {
  final String selector;
  final String? attr;
  final bool isParentElement;
  FQuery({required this.selector, this.attr, this.isParentElement = false});

  String getResult(Element ele, {bool isHtmlStyleText = false}) {
    if (isParentElement && ele.parent != null) {
      ele = ele.parent!;
    }
    // print(ele.outerHtml);
    if (selector.isEmpty && attr != null) {
      return ele.attributes[attr!].toString();
    }
    if (selector.isEmpty) {
      if (isHtmlStyleText) {
        final html = ele.outerHtml;
        return html.cleanHtmlTag();
      }
      return ele.text;
    }
    if (attr != null) {
      return ele.getQuerySelectorAttr(selector: selector, attr: attr!);
    } else {
      if (isHtmlStyleText) {
        final html = ele.querySelector(selector)?.outerHtml ?? '';
        return html.cleanHtmlTag();
      }
      // text
      return ele.getQuerySelectorText(selector: selector);
    }
  }
}
