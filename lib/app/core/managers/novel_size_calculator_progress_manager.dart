// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelSizeCalculatorProgressManager extends TProgressManagerSimple {
  final BuildContext context;
  bool isCanceld = false;
  NovelSizeCalculatorProgressManager({required this.context});

  @override
  void cancel() {
    isCanceld = true;
  }

  @override
  Future<void> startWorking(StreamController<TProgress> controller) async {
    await context.read<NovelProvider>().calculateSize(
      isCanceld: () => isCanceld,
      onProgress: (total, loaded, message) {
        controller.add(
          TProgress.progress(
            index: loaded,
            indexLength: total,
            loaded: loaded,
            total: total,
            message: message,
          ),
        );
      },
    );
    await controller.close();
  }
}
