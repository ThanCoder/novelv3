import 'package:flutter/material.dart';

final homePageListStyleNotifier = ValueNotifier<ListStyleType>(
  ListStyleType.list,
);

enum ListStyleType {
  list,
  grid;

  static ListStyleType getType(String type) {
    if (type == grid.name) {
      return grid;
    }
    return list;
  }
}
