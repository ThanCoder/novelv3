import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/my_libs/general_server/index.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/app/setting/app_notifier.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/t_history_services.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ThanPkg.instance.init();
  await TWidgets.instance.init(
    defaultImageAssetsPath: 'assets/cover.png',
    getDarkMode: () {
      return appConfigNotifier.value.isDarkTheme;
    },
  );

  //init config
  await initAppConfigService();
  await GeneralServices.instance.init();
  THistoryServices.instance
      .init('${PathUtil.getCachePath()}/t_history_record.json');

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
