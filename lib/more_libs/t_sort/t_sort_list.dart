import 't_sort_type.dart';

class TSortList {
  final List<TSortType> _items = [];

  void add(
    String field, {
    required String ascTitle,
    required String descTitle,
  }) {
    _items.add(TSortType(field: field, title: ascTitle, isAsc: true));
    _items.add(TSortType(field: field, title: descTitle, isAsc: false));
  }

  // set
  void addAll(List<TSortType> res) {
    _items.addAll(res);
  }

  void setAll(List<TSortType> res) {
    _items.clear();
    _items.addAll(res);
  }

  List<TSortType> get getAll => _items;
  List<String> get getFields => _items.map((e) => e.field).toSet().toList();

  static TSortList get getDefaultList {
    final sort = TSortList();
    sort.setAll(getDefaultTypeList);
    return sort;
  }

  static List<TSortType> get getDefaultTypeList {
    final list = TSortList();
    list.add('Title', ascTitle: 'A-Z', descTitle: 'Z-A');
    list.add('Date', ascTitle: 'Oldest', descTitle: 'Newest');
    return list.getAll;
  }
}
