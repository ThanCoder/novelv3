// ignore_for_file: public_member_api_docs, sort_constructors_first
class TSortType {
  final String field;
  final String title;
  final bool isAsc;
  TSortType({required this.field, required this.title, required this.isAsc});

  @override
  String toString() {
    return field;
  }
}
