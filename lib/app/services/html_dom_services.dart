import 'package:flutter/material.dart';
import 'package:html/dom.dart' as html;

class HtmlDomServices {
  static html.Document getHtmlDom(String content) {
    return html.Document.html(content);
  }

  static html.Element? getHtmlEle(String content) {
    final dom = html.Document.html(content);
    return dom.body;
  }

  static String getQuerySelectorAttr(
      html.Element ele, String selector, String attr) {
    var res = '';
    try {
      if (ele.querySelector(selector) == null) return '';
      res = ele.querySelector(selector)!.attributes[attr] ?? '';
    } catch (e) {
      debugPrint('$selector: ${e.toString()}');
    }
    return res.trim();
  }

  static String getQuerySelectorText(html.Element ele, String selector) {
    var res = '';

    try {
      if (ele.querySelector(selector) == null) return '';
      res = ele.querySelector(selector)!.text;
    } catch (e) {
      debugPrint('$selector: ${e.toString()}');
    }
    return res.trim();
  }

  static String getQuerySelectorHtml(html.Element ele, String selector) {
    var res = '';

    try {
      if (ele.querySelector(selector) == null) return '';
      res = ele.querySelector(selector)!.innerHtml;
    } catch (e) {
      debugPrint('$selector: ${e.toString()}');
    }
    return res.trim();
  }

  static String getNewLine(String html, {String replacer = '\n'}) {
    var res = '';

    res = html.replaceAll(RegExp(r'<[^/][^>]*>'), ''); // opening tag remove
    res = res.replaceAll(RegExp(r'</[^>]+>'), replacer); // closing tag -> \n

    return res.trim();
  }
}
