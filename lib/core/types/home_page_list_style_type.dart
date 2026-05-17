import 'package:flutter/material.dart';

enum HomeListStyleType {
  list,
  grid;

  static HomeListStyleType getType(String type) {
    if (type == grid.name) {
      return grid;
    }
    return list;
  }
}

final currentHomeListStyleNotifier = ValueNotifier<HomeListStyleType>(
  HomeListStyleType.list,
);
