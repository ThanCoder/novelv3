import 'package:html/dom.dart' as html;
import 'package:novel_v3/app/services/dio_services.dart';

class MediafireServicesResponse {
  String title;
  String downloadUrl;
  MediafireServicesResponse({
    required this.title,
    required this.downloadUrl,
  });
}

class MediafireServices {
  static Future<MediafireServicesResponse> fetchDirectDownloadLink(
      String url) async {
    String title = '';
    String downloadUrl = '';
    String resHtml = await DioServices.instance.getForwardProxyHtml(url);
    final doc = html.Document.html(resHtml);
    //fetch
    title = getQuerySelectorText(doc, '.dl-btn-label');
    downloadUrl = getQuerySelector(doc, '#downloadButton', 'href');
    //file
    // final file = File('${Directory.current.path}/res.html');
    // await file.writeAsString(resHtml);

    return MediafireServicesResponse(title: title, downloadUrl: downloadUrl);
  }

  static getQuerySelectorText(html.Document doc, String selector) {
    if (doc.querySelector(selector) == null) return '';
    String res = doc.querySelector(selector)!.text;
    return res.trim();
  }

  static getQuerySelector(html.Document doc, String selector, String attr) {
    if (doc.querySelector(selector) == null) return '';
    String res = doc.querySelector(selector)!.attributes[attr] ?? '';
    return res.trim();
  }
}
