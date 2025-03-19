import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/services/novel_data_services.dart';
import 'package:novel_v3/app/services/novel_isolate_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';

class ImportNovelDataDialog extends StatefulWidget {
  BuildContext dialogContext;
  String dataFilePath;
  void Function()? onCompleted;
  ImportNovelDataDialog({
    super.key,
    required this.dialogContext,
    required this.dataFilePath,
    this.onCompleted,
  });

  @override
  State<ImportNovelDataDialog> createState() => _ImportNovelDataDialogState();
}

class _ImportNovelDataDialogState extends State<ImportNovelDataDialog> {
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
    setState(() {
      isLoading = true;
    });

    importNovelDataIsolate(
      filePath: widget.dataFilePath,
      outDirPath: PathUtil.instance.getSourcePath(),
      onProgress: (_max, _progress, _title) {
        setState(() {
          isLoading = false;
          title = _title;
          max = _max;
          progress = _progress;
        });
      },
      onSuccess: (novelPath) async {
        try {
          setState(() {
            isLoading = false;
          });
          Navigator.pop(widget.dialogContext);
          showDialogMessage(context, 'ထည့်သွင်းပြီးပါပြီး');
          if (widget.onCompleted != null) {
            widget.onCompleted!();
          }
          //add
          final novelList = await getNovelListFromPathIsolate();
          novelListNotifier.value = novelList;
        } catch (e) {
          debugPrint(e.toString());
        }
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
      title: const Text('Import Novel Data'),
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
                Expanded(child: Text(isLoading ? 'Loading...' : title)),
                const Spacer(),
                Text('$progress/$max'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
