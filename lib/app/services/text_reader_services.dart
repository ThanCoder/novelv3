import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/text_reader_config_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';

void setTextReaderConfig(TextReaderConfigModel config) {
  try {
    final path = '${currentNovelNotifier.value!.path}/$textReaderConfigName';
    final file = File(path);
    file.writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(config.toMap()));
  } catch (e) {
    debugPrint('setTextReaderConfig: ${e.toString()}');
  }
}

TextReaderConfigModel getTextReaderConfig() {
  TextReaderConfigModel config = TextReaderConfigModel();
  try {
    final path = '${currentNovelNotifier.value!.path}/$textReaderConfigName';
    config = TextReaderConfigModel.fromPath(path);
  } catch (e) {
    debugPrint('setTextReaderConfig: ${e.toString()}');
  }
  return config;
}
