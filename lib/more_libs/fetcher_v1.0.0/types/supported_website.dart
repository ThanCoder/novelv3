import '../interfaces/fetcher_interface.dart';
class SupportedWebSite extends SupportedWebSiteInterface {
  SupportedWebSite({
    required super.title,
    required super.url,
    required super.titleQuery,
    super.authorQuery,
    super.coverUrlQuery,
    super.descriptionQuery,
    super.tagsQuery,
    super.translatorQuery,
    super.webChapterList,
  });
}
