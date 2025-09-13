import 'package:flutter/material.dart';

import '../app_config.dart';

//config
ValueNotifier<AppConfig> appConfigNotifier = ValueNotifier(
  AppConfig.create(),
);
