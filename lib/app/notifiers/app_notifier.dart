import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/core/app_config_model.dart';

//path
ValueNotifier<String> appRootPathNotifier = ValueNotifier('');
ValueNotifier<String> appExternalPathNotifier = ValueNotifier('');
ValueNotifier<String> appConfigPathNotifier = ValueNotifier('');
//theme
ValueNotifier<bool> isDarkThemeNotifier = ValueNotifier(false);
//config
ValueNotifier<AppConfigModel> appConfigNotifier =
    ValueNotifier(AppConfigModel());

//home bottom bar
ValueNotifier<bool> isShowHomeBottomBarNotifier = ValueNotifier(true);
ValueNotifier<bool> isShowContentBottomBarNotifier = ValueNotifier(true);

//wifi host
ValueNotifier<String> appWififHostAddressNotifier = ValueNotifier('');

//file drop
ValueNotifier<bool> isFileDropHomePageNotifier = ValueNotifier(true);
