import 'package:t_html_parser/t_html_parser.dart';

class FQuery {
  final String selector;
  final String? attr;
  final bool isParentElement;
  final bool isHtmlStyleText;
  final bool isMultiSelector;
  final String multiSelectorValueJoiner;
  FQuery({
    required this.selector,
    this.attr,
    this.isParentElement = false,
    this.isHtmlStyleText = false,
    this.isMultiSelector = false,
    this.multiSelectorValueJoiner = ',',
  });

  String getResult(Element ele) {
    if (isParentElement && ele.parent != null) {
      ele = ele.parent!;
    }
    // print(ele.outerHtml);
    if (selector.isEmpty && attr != null) {
      return ele.attributes[attr!].toString().trim();
    }
    if (selector.isEmpty) {
      if (isHtmlStyleText) {
        final html = ele.outerHtml;
        return html.cleanHtmlTag().trim();
      }
      return ele.text;
    }
    if (attr != null) {
      return ele.getQuerySelectorAttr(selector: selector, attr: attr!).trim();
    } else {
      if (isHtmlStyleText) {
        final html = ele.querySelector(selector)?.outerHtml ?? '';
        return html.cleanHtmlTag().trim();
      }
      // is multi selector text
      if (isMultiSelector) {
        List<String> mulV = [];
        for (var mulE in ele.querySelectorAll(selector)) {
          mulV.add(mulE.text.trim());
        }
        return mulV.join(multiSelectorValueJoiner);
      }

      // text
      return ele.getQuerySelectorText(selector: selector).trim();
    }
  }
}
