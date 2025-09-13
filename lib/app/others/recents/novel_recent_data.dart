class NovelRecentData {
  String title;
  NovelRecentData({required this.title});

  factory NovelRecentData.fromMap(Map<String, dynamic> map) {
    return NovelRecentData(title: map['title'] as String);
  }
  Map<String, dynamic> toMap() => {'title': title};
}
