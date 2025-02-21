import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/app_config_model.dart';

ValueNotifier<String> appRootPathNotifier = ValueNotifier('');
ValueNotifier<String> appDataRootPathNotifier = ValueNotifier('');
ValueNotifier<String> appConfigPathNotifier = ValueNotifier('');
ValueNotifier<bool> isDarkThemeNotifier = ValueNotifier(false);
//config
ValueNotifier<AppConfigModel> appConfigNotifier =
    ValueNotifier(AppConfigModel());

//home bottom bar
ValueNotifier<bool> isShowHomeBottomBarNotifier = ValueNotifier(true);
ValueNotifier<bool> isShowContentBottomBarNotifier = ValueNotifier(true);
