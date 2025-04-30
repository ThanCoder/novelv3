// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:novel_v3/app/fetcher/fetcher_query.dart';

class Fetcher {
  String title;
  String url;
  String testUrl;
  String minVersion;
  FetcherQuery titleQuery;
  FetcherQuery contentQuery;

  Fetcher({
    required this.title,
    required this.url,
    required this.testUrl,
    this.minVersion = '1',
    required this.titleQuery,
    required this.contentQuery,
  });
}
