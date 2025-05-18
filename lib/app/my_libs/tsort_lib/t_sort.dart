// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';

class TSort {
  String title;
  Widget? icon;
  List<String> choose;
  TSort({
    required this.title,
    this.icon,
    required this.choose,
  });

  factory TSort.createChoose(String title, String currentChoose) {
    return TSort(title: title, choose: [currentChoose]);
  }

  static List<TSort> get getDefaultList => [
        TSort(
          title: 'Title',
          choose: [
            'A to Z',
            'Z to A',
          ],
        ),
        TSort(
          title: 'Date',
          choose: [
            'Oldest',
            'Newest',
          ],
        ),
        TSort(
          title: 'Size',
          choose: [
            'Smallest',
            'Largest',
          ],
        ),
      ];
}
