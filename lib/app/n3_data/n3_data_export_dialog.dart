import 'package:flutter/material.dart';
import 'package:novel_v3/app/n3_data/n3_data_worker.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/routes_helper.dart';
import 'package:t_widgets/t_widgets.dart';

class N3DataExportDialog extends StatefulWidget {
  Novel novel;

  N3DataExportDialog({super.key, required this.novel});

  @override
  State<N3DataExportDialog> createState() => _N3DataExportDialogState();
}

class _N3DataExportDialogState extends State<N3DataExportDialog> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    await N3DataWorker.export(widget.novel);
    if (!mounted) return;
    closeContext(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      content: Column(
        spacing: 8,
        children: [
          Text('N3Data ထုတ်ပေးနေပါတယ်...။\nပြီးသွားရင် အလိုအလျောက် ပိတ်ပါမယ်။'),
          Center(child: TLoaderRandom()),
        ],
      ),
    );
  }
}
