import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/text_reader_config_model.dart';

class TextReaderServices {
  static final TextReaderServices instance = TextReaderServices._();
  TextReaderServices._();
  factory TextReaderServices() => instance;

  void setTextReaderConfig(
      {required TextReaderConfigModel config, required String novelPath}) {
    try {
      final path = '$novelPath/$textReaderConfigName';
      final file = File(path);
      file.writeAsStringSync(
          const JsonEncoder.withIndent('  ').convert(config.toMap()));
    } catch (e) {
      debugPrint('setTextReaderConfig: ${e.toString()}');
    }
  }

  TextReaderConfigModel getTextReaderConfig({required String novelPath}) {
    TextReaderConfigModel config = TextReaderConfigModel();
    try {
      final path = '$novelPath/$textReaderConfigName';
      config = TextReaderConfigModel.fromPath(path);
    } catch (e) {
      debugPrint('setTextReaderConfig: ${e.toString()}');
    }
    return config;
  }
}
