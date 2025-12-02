import '../types/desc_query_types.dart';

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
