import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cf_lite/cf_lite.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart' hide Text;
import 'package:novel_v3/bloc_app/ui/fetcher/result_types.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/types/fetch_website.dart';
import 'package:novel_v3/bloc_app/ui/webview/fetch_webview_screen.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/core/utils.dart';
import 'package:t_client/t_client.dart';
import 'package:t_html_parser/core/types/attributes.dart';
import 'package:t_html_parser/t_html_parser.dart';

class FetchServices {
  static final FetchServices instance = FetchServices._();
  FetchServices._();
  factory FetchServices() => instance;
  final client = TClient();

  String getProxyUrl(String url) {
    final forward = getProxy();
    if (forward.isNotEmpty) {
      return '$forward${forward.contains('?') ? '&&' : '?'}url=$url';
    }
    return url;
  }

  String getProxy() {
    return CFLite.getInstance().getString('fetcher-proxy-url');
  }

  Future<void> setProxy(String proxyUrl) async {
    CFLite.getInstance().put('fetcher-proxy-url', proxyUrl);
  }

  Future<NovelDetailResult?> fetchNovelDetail(
    BuildContext context,
    String url, {
    required FetcherWebsite website,
  }) async {
    final html = await _fetchView(context, url, website.type);

    if (website.detailPageQuery != null) {
      return NovelDetailResult(
        title: website.detailPageQuery!.title.getResult(html).join(','),
        coverUrl: website.detailPageQuery!.coverUrl.getResult(html).join(''),
        author: website.detailPageQuery!.author.getResult(html).join(''),
        otherTitles:
            website.detailPageQuery!.otherTitles?.getResult(html) ?? [],
        translator:
            website.detailPageQuery!.translator?.getResult(html).join('') ?? '',
        description: website.detailPageQuery!.description
            .getResult(html)
            .join(''),
        tags: website.detailPageQuery!.tags.getResult(html),
      );
    }
    return null;
  }

  /// Fetch Fetch Type
  Future<String> _fetchView(
    BuildContext context,
    String url,
    FetchType type,
  ) async {
    final completer = Completer<String>();
    if (type == FetchType.webview) {
      if (Platform.isLinux) {
        final webview = await WebviewWindow.create(
          configuration: CreateConfiguration(
            title: 'Fetcher',
            windowWidth: 600,
            windowHeight: 400,
          ),
        );
        webview.launch(getProxyUrl(url));

        String cleanHtml = '';
        Future.delayed(Duration(seconds: 1)).then((_) async {
          final rawHtml = await webview.evaluateJavaScript(
            "document.querySelector('body').innerHTML",
          );
          if (rawHtml == null) return;
          try {
            final decodedHtml = jsonDecode(rawHtml);
            cleanHtml = decodedHtml;
          } catch (e) {
            cleanHtml = rawHtml;
          }
        });

        Future.delayed(Duration(seconds: 3)).then((_) async {
          final rawHtml = await webview.evaluateJavaScript(
            "document.querySelector('body').innerHTML",
          );
          if (rawHtml == null) return;
          try {
            final decodedHtml = jsonDecode(rawHtml);
            cleanHtml = decodedHtml;
          } catch (e) {
            cleanHtml = rawHtml;
          }
        });

        await webview.onClose;
        // \n, \r, \t တွေကို ရှာပြီး space တစ်ခုစာနဲ့ အစားထိုးမယ်
        cleanHtml = cleanHtml.replaceAll(RegExp(r'[\n\r\t]'), '');

        // Space အပိုတွေကို တစ်ခုတည်းဖြစ်အောင် ထပ်ရှင်းမယ် (Optional)
        cleanHtml = cleanHtml.replaceAll(RegExp(r'\s+'), ' ').trim();
        // print(cleanHtml);
        completer.complete(cleanHtml);
      } else {
        context.goRoute(
          builder: (context) => FetchWebviewScreen(
            url: url,
            onResult: (resultHtml) => completer.complete(resultHtml),
            onClosed: () {
              if (!completer.isCompleted) {
                completer.complete('');
              }
            },
          ),
        );
      }
    } else {
      final res = await client.get(getProxyUrl(url));
      completer.complete(res.data.toString());
    }
    return completer.future;
  }

  Future<FetcherNovelResult> fetchNovelList(
    BuildContext context,
    String url, {
    required FetcherWebsite website,
  }) async {
    List<NovelItemResult> list = [];
    final html = await _fetchView(context, url, website.type);

    final dom = html.toHtmlDocument;
    for (var ele in dom.querySelectorAll(
      website.novelListPageQuery.querySelectorAll,
    )) {
      // print(ele.innerHtml);
      // final title = ele.getQuerySelectorText(selector: '.luf a h3');
      final title = ele.getQuerySelectorText(
        selector: website.novelListPageQuery.titleQuery.selector,
      );
      final pageUrl = ele.getQuerySelectorAttr(
        selector: website.novelListPageQuery.pageUrlQuery.selector,
        attr: Attribute(website.novelListPageQuery.pageUrlQuery.attribue),
      );
      final coverUrl = ele.getQuerySelectorAttr(
        selector: website.novelListPageQuery.coverUrlQuery.selector,
        attr: Attribute(website.novelListPageQuery.coverUrlQuery.attribue),
      );
      if (title.isEmpty) continue;
      list.add(
        NovelItemResult(
          title: title,
          pageUrl: pageUrl.formatUrl(website.hostUrl),
          coverUrl: coverUrl.formatUrl(website.hostUrl),
        ),
      );
    }
    // fetch next urls
    final nextUrls = <FetcherNovelNextUrl>[];
    if (website.novelListPageQuery.nextUrlQuery != null) {
      if (website
          .novelListPageQuery
          .nextUrlQuery!
          .querySelectorAll
          .isNotEmpty) {
        for (var ele in dom.querySelectorAll(
          website.novelListPageQuery.nextUrlQuery!.querySelectorAll,
        )) {
          final title = website.novelListPageQuery.nextUrlQuery!.itemTextQuery
              .getFromElement(ele);
          final nextUrl = website.novelListPageQuery.nextUrlQuery!.itemUrlQuery
              .getFromElement(ele);
          // print(url.formatUrl(website.hostUrl));

          nextUrls.add(
            FetcherNovelNextUrl(
              title: title,
              url: nextUrl.formatUrl(
                website.novelListPageQuery.nextUrlQuery!.hostUrl ??
                    website.hostUrl,
              ),
            ),
          );
        }
      }
    }

    return FetcherNovelResult(list: list, nextUrls: nextUrls);
  }

  Future<ChapterContentResult> fetchChapter(
    BuildContext context,
    String url, {
    required FetcherWebsite website,
  }) async {
    final html = await _fetchView(context, url, website.type);
    String? title, content;

    if (website.chapterPageQuery != null) {
      title = QueryResult(
        // index: website.chapterPageQuery!.titleQuery.index,
        attr: Attribute(website.chapterPageQuery!.titleQuery.attribue),
        selector: website.chapterPageQuery!.titleQuery.selector,
      ).getResult(html);

      // content = QueryResult(
      //   index: website.chapterPageQuery!.contentQuery.index,
      //   attr: Attribute(website.chapterPageQuery!.contentQuery.attribue),
      //   selector: website.chapterPageQuery!.contentQuery.selector,
      //   afterQuery: (attr, result) {
      //     return result?.cleanHtmlTag();
      //   },
      // ).getResult(html);
      final dom = html.toHtmlDocument;
      // ၁။ မလိုအပ်တဲ့ Tag တွေနဲ့ အထဲက Data တွေကို အကုန်အရင်ဖယ်ထုတ်မယ် (ဥပမာ script, style)
      dom
          .querySelectorAll('script, style, div[id^="pf-"]')
          .forEach((el) => el.remove());

      final ele = dom.querySelector(
        website.chapterPageQuery!.contentQuery.selector,
      );
      if (ele != null) {
        // ၂။ <br> tag တွေကို \n အဖြစ် ပြောင်းမယ်
        ele.querySelectorAll('br').forEach((br) {
          br.replaceWith(Text('\n'));
        });

        // ၃။ <p> ဒါမှမဟုတ် <div> တွေကိုလည်း line break အနေနဲ့ သတ်မှတ်ချင်ရင်
        ele.querySelectorAll('p, div').forEach((el) {
          el.append(Text('\n'));
        });
        content = ele.text.trim();
      }
    }
    return ChapterContentResult(title: title ?? '', content: content ?? '');
  }

  Future<List<MultiChapterResult>> fetchMultiChapter(
    BuildContext context,
    String url, {
    required FetcherWebsite website,
    bool startChapterNumberSmallToBig = true,
  }) async {
    final html = await _fetchView(context, url, website.type);

    final dom = html.toHtmlDocument;

    List<MultiChapterResult> list = [];
    if (website.chapterListPageQuery != null) {
      int chNumber = 1;

      final eles = dom.querySelectorAll(
        website.chapterListPageQuery!.querySelectorAll,
      );
      if (!startChapterNumberSmallToBig) {
        chNumber = eles.length;
      }
      for (var ele in eles) {
        // final url = ele.getQuerySelectorAttr(selector: 'a', attr: 'href');
        // final title = ele.getQuerySelectorText(selector: '.epl-title');
        final url = website.chapterListPageQuery!.pageUrlQuery.getFromElement(
          ele,
        );
        final title = website.chapterListPageQuery!.titleQuery.getFromElement(
          ele,
        );
        // print('CH: $chNumber - title: $title - url: $url');
        list.add(
          MultiChapterResult(chNumber: chNumber, title: title, url: url),
        );
        // auto chapter number
        if (startChapterNumberSmallToBig) {
          chNumber++;
        } else {
          chNumber--;
        }
      }
    }

    return list;
  }
}
