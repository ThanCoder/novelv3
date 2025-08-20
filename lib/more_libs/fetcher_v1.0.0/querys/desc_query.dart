// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/desc_query_types.dart';

class DescQuery {
  String startHostUrl;
  String title;
  String selector;
  DescQueryTypes type;
  DescQuery({
    required this.startHostUrl,
    required this.title,
    required this.type,
    required this.selector,
  });
}
