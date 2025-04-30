import 'types/fetcher_data_types.dart';
import 'types/fetcher_query_types.dart';

class FetcherQuery {
  String title;
  String query;
  String attr;
  FetcherQueryTypes type;
  FetcherDataTypes dataType;
  bool isUsedForwardProxy;

  FetcherQuery({
    this.title = 'Untitled',
    required this.query,
    this.attr = '',
    this.type = FetcherQueryTypes.text,
    this.dataType = FetcherDataTypes.text,
    this.isUsedForwardProxy = false,
  });
}
