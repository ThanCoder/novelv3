import 'package:flutter/widgets.dart';
import 'package:novel_v3/more_libs/assets_helper/assets_button.dart';
import 'package:novel_v3/more_libs/assets_helper/assets_list_tile.dart';

class AssetsHelper {
  static final AssetsHelper instance = AssetsHelper._();
  AssetsHelper._();
  factory AssetsHelper() => instance;

  Widget getListTile = AssetsListTile();
  Widget getButton = AssetsButton();
}
