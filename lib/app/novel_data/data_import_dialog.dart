import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/core/app_components.dart';
import 'package:novel_v3/app/novel_data/novel_data_services.dart';

class DataImportDialog extends StatefulWidget {
  String path;
  void Function() onDone;
  DataImportDialog({
    super.key,
    required this.path,
    required this.onDone,
  });

  @override
  State<DataImportDialog> createState() => _DataImportDialogState();
}

class _DataImportDialogState extends State<DataImportDialog> {
  double? progress;
  String? message;
  bool isAlreadyExistsOverride = false;
  bool isConfigFilesAdd = false;
  bool isWorking = false;
  late Isolate isolate;

  void _startInstall() async {
    isolate = await NovelDataServices.importIsolate(
      widget.path,
      isAlreadyExistsOverride: isAlreadyExistsOverride,
      isConfigFilesAdd: isConfigFilesAdd,
      onProgress: (progress, message) {
        if (!mounted) return;
        setState(() {
          this.progress = progress;
          this.message = message;
          isWorking = true;
        });
      },
      onDone: () {
        if (!mounted) return;
        Navigator.pop(context);
        widget.onDone();
      },
      onError: (msg) {
        if (!mounted) return;
        Navigator.pop(context);
        showDialogMessage(context, msg);
      },
    );
  }

  List<Widget> _getConfigForm() {
    if (progress != null) {
      return [];
    }
    return [
      SwitchListTile.adaptive(
        title: Text(
            'Already Files ${isAlreadyExistsOverride ? 'install' : 'skip'}'),
        subtitle: const Text('ရှိနေပြီးသား files များ'),
        value: isAlreadyExistsOverride,
        onChanged: (value) {
          setState(() {
            isAlreadyExistsOverride = value;
          });
        },
      ),
      SwitchListTile.adaptive(
        title: Text('Config Files ${isConfigFilesAdd ? 'install' : 'skip'}'),
        subtitle: const Text(
          'Readed,pdf config,bookmark,',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        value: isConfigFilesAdd,
        onChanged: (value) {
          setState(() {
            isConfigFilesAdd = value;
          });
        },
      ),
    ];
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
          ..._getConfigForm(),
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
        TextButton(
          onPressed: isWorking ? null : _startInstall,
          child: const Text('သွင်းမယ်'),
        ),
      ],
    );
  }
}
