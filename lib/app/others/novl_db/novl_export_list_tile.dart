import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/others/novl_db/novl_export_progress_manager.dart';
import 'package:novel_v3/app/others/novl_db/novl_info_edit_dialog.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:t_widgets/progress_manager/progress_dialog.dart';

class NovlExportListTile extends StatefulWidget {
  final Novel novel;
  final VoidCallback? onClosed;
  const NovlExportListTile({super.key, required this.novel, this.onClosed});

  @override
  State<NovlExportListTile> createState() => _NovlExportListTileState();
}

class _NovlExportListTileState extends State<NovlExportListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.share),
      title: Text('Export Novl Data'),
      onTap: _export,
    );
  }

  void _export() {
    showAdaptiveDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NovlInfoEditDialog(
        novel: widget.novel,
        onSubmit: (info) {
          showAdaptiveDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => ProgressDialog(
              progressManager: NovlExportProgressManager(
                novel: widget.novel,
                info: info,
                outPath: PathUtil.getOutPath(name: widget.novel.meta.title),
                onDone: widget.onClosed,
              ),
            ),
          );
        },
      ),
    );
  }
}
