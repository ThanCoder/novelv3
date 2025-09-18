import '../interfaces/fetcher_interface.dart';

class WebSite extends SupportedWebSiteInterface {
  WebSite({
    required super.title,
    required super.url,
    required super.info,
    super.webChapterList,
  });
}
