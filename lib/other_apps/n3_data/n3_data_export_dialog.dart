import 'package:flutter/material.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'n3_data_worker.dart';

class N3DataExportDialog extends StatefulWidget {
  Novel novel;
  bool isSetPassword;
  void Function()? onSuccess;
  N3DataExportDialog({
    super.key,
    required this.novel,
    this.isSetPassword = false,
    this.onSuccess,
  });

  @override
  State<N3DataExportDialog> createState() => _N3DataExportDialogState();
}

class _N3DataExportDialogState extends State<N3DataExportDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  double? progress;

  void init() async {
    N3DataWorker.exportProgress(
      widget.novel,
      isSetPassword: widget.isSetPassword,
      onProgress: (progress) {
        this.progress = progress;
        setState(() {});
      },
      onSuccess: () {
        if (!mounted) return;
        context.closeNavigator();
        widget.onSuccess?.call();
      },
      onError: (message) {
        if (!mounted) return;
        context.closeNavigator();
        debugPrint(message);
      },
    );
    // await N3DataWorker.export(widget.novel);
    // await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      content: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('N3Data ထုတ်ပေးနေပါတယ်...။\nပြီးသွားရင် အလိုအလျောက် ပိတ်ပါမယ်။'),
          LinearProgressIndicator(value: progress),
          _getPercent(),
        ],
      ),
      // actions: [
      //   IconButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     icon: Icon(Icons.close),
      //   ),
      // ],
    );
  }

  Widget _getPercent() {
    if (progress == null) {
      return SizedBox.shrink();
    }
    return Text('Progress: ${(progress! * 100).toStringAsFixed(2)}%');
  }
}
