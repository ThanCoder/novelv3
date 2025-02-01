import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/services/novel_data_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class ExportNovelDataDialog extends StatefulWidget {
  BuildContext dialogContext;
  ExportNovelDataDialog({super.key, required this.dialogContext});

  @override
  State<ExportNovelDataDialog> createState() => _ExportNovelDataDialogState();
}

class _ExportNovelDataDialogState extends State<ExportNovelDataDialog> {
  @override
  void initState() {
    init();
    super.initState();
  }

  String title = "";
  int max = 100;
  int progress = 0;
  bool isLoading = false;

  void init() {
    final novel = currentNovelNotifier.value;
    if (novel == null) return;

    setState(() {
      isLoading = true;
    });

    exportNovelDataIsolate(
      folderPath: novel.path,
      outDirPath: getOutPath(),
      onProgress: (_max, _progress, _title) {
        setState(() {
          isLoading = false;
          title = _title;
          max = _max;
          progress = _progress;
        });
      },
      onSuccess: (filePath) {
        setState(() {
          isLoading = false;
        });
        Navigator.pop(widget.dialogContext);
        showDialogMessage(context, 'ပြီးပါပြီး \npath: $filePath');
      },
      onError: (err) {
        setState(() {
          isLoading = false;
        });
        Navigator.pop(widget.dialogContext);
        showDialogMessage(context, 'ပြသနာရှိနေပါတယ် \nerror: $err');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Novel Data'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 120,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: progress / max,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$progress/$max'),
                Expanded(child: Text(isLoading ? 'Loading...' : title)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
