import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/core/app_components.dart';
import 'package:novel_v3/app/novel_data/novel_data_services.dart';

class DataExportDialog extends StatefulWidget {
  String novelPath;
  void Function(String savedPath) onDone;
  DataExportDialog({
    super.key,
    required this.novelPath,
    required this.onDone,
  });

  @override
  State<DataExportDialog> createState() => _DataExportDialogState();
}

class _DataExportDialogState extends State<DataExportDialog> {
  double? progress;
  String? message;
  bool isWorking = false;
  late Isolate isolate;

  @override
  void initState() {
    super.initState();
    _startExport();
  }

  void _startExport() async {
    isolate = await NovelDataServices.exportIsolate(
      widget.novelPath,
      onProgress: (progress, message) {
        if (!mounted) return;
        setState(() {
          this.progress = progress;
          this.message = message;
          isWorking = true;
        });
      },
      onDone: (savedPath) {
        if (!mounted) return;
        Navigator.pop(context);
        widget.onDone(savedPath);
      },
      onError: (msg) {
        if (!mounted) return;
        Navigator.pop(context);
        showDialogMessage(context, msg);
      },
    );
  }

  List<Widget> _getProgressContent() {
    if (progress == null) return [];
    return [
      Text('${(progress! * 100).toStringAsFixed(2)}%'),
      LinearProgressIndicator(value: progress),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Column(
        spacing: 5,
        children: [
          message == null
              ? const SizedBox.shrink()
              : Text(
                  message!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
          ..._getProgressContent(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (isWorking) {
              // NovelDataServices.setIsolateRunning = false;
              isolate.kill(priority: Isolate.immediate);
              Navigator.pop(context);
              return;
            }
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
