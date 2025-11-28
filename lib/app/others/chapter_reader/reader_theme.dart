import 'package:flutter/material.dart';

class ReaderTheme {
  final String id;
  final String title;
  final Color fontColor;
  final Color bgColor;
  const ReaderTheme({
    required this.id,
    required this.title,
    required this.fontColor,
    required this.bgColor,
  });

  factory ReaderTheme.getId(String id) {
    final index = getDefaultList.indexWhere((e) => e.id == id);
    if (index != -1) return getDefaultList[index];
    return defaultLightTheme;
  }

  static List<ReaderTheme> get getDefaultList {
    return [
      defaultLightTheme,
      defaultDarkTheme,
      warmYellow,
      sepiaTheme,
      cobalt,
      blueLightFilter,
      greenTheme,
      greenPaper,
      gray,
    ];
  }

  static const ReaderTheme defaultLightTheme = ReaderTheme(
    id: '1',
    title: 'Light Theme',
    fontColor: Color.fromARGB(255, 10, 10, 10),
    bgColor: Colors.white,
  );
  static const ReaderTheme defaultDarkTheme = ReaderTheme(
    id: '2',
    title: 'Dark Theme',
    fontColor: Colors.grey,
    bgColor: Colors.black,
  );
  static const ReaderTheme sepiaTheme = ReaderTheme(
    id: '3',
    title: 'Sepia',
    fontColor: Color(0xFF5B4636),
    bgColor: Color(0xFFF5DEB3),
  );

  static const ReaderTheme blueLightFilter = ReaderTheme(
    id: '4',
    title: 'Blue Light Filter',
    fontColor: Colors.black,
    bgColor: Color(0xFFE6E6FA), // light lavender
  );

  static const ReaderTheme greenTheme = ReaderTheme(
    id: '5',
    title: 'Green Calm',
    fontColor: Color(0xFF003300),
    bgColor: Color(0xFFE8F5E9),
  );

  static const ReaderTheme greenPaper = ReaderTheme(
    id: '6',
    title: 'Green ',
    fontColor: Color.fromARGB(255, 4, 44, 4),
    bgColor: Color.fromARGB(255, 176, 187, 177),
  );

  static const ReaderTheme gray = ReaderTheme(
    id: '7',
    title: 'Gray',
    fontColor: Color(0xFF333333),
    bgColor: Color(0xFFF0F0F0),
  );

  static const ReaderTheme warmYellow = ReaderTheme(
    id: '8',
    title: 'Warm Yellow',
    fontColor: Color(0xFF5B4636),
    bgColor: Color(0xFFFFF8DC),
  );
  static const ReaderTheme cobalt = ReaderTheme(
    id: '9',
    title: 'Cobalt',
    fontColor: Color.fromARGB(255, 194, 194, 194),
    bgColor: Color.fromARGB(255, 7, 28, 46),
  );
}
