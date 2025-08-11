class SortType {
  String title;
  bool isAsc; // or desc
  SortType({
    required this.title,
    required this.isAsc,
  });

  SortType copyWith({
    String? title,
    bool? isAsc,
  }) {
    return SortType(
      title: title ?? this.title,
      isAsc: isAsc ?? this.isAsc,
    );
  }

  static List<SortType> get getDefaultList {
    return [
      SortType(title: 'Title', isAsc: true),
      SortType(title: 'Completed', isAsc: true),
      SortType(title: 'Adult', isAsc: true),
      SortType(title: 'Date', isAsc: true),
    ];
  }

  static SortType get getDefaultValue => SortType(title: 'Title', isAsc: true);
}
