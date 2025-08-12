class SortType {
  String title;
  bool isAsc; // or desc
  SortType({required this.title, required this.isAsc});

  SortType copyWith({String? title, bool? isAsc}) {
    return SortType(title: title ?? this.title, isAsc: isAsc ?? this.isAsc);
  }

  static List<SortType> get getDefaultList {
    return [
      SortType(title: 'title', isAsc: true),
      SortType(title: 'date', isAsc: true),
    ];
  }

  static SortType getDefaultTitle({bool isAsc = true}) =>
      SortType(title: 'title', isAsc: isAsc);
  static SortType getDefaultDate({bool isAsc = false}) =>
      SortType(title: 'date', isAsc: isAsc);
}
