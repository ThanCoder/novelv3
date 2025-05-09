import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/general_server/index.dart';
import 'package:novel_v3/app/my_app.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:than_pkg/than_pkg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ThanPkg.windowManagerensureInitialized();

  //init config
  await initAppConfigService();
  await GeneralServices.instance.init();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
