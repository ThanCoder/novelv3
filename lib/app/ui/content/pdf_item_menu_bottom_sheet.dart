import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/managers/copy_progress_manager.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/core/providers/pdf_provider.dart';
import 'package:novel_v3/app/others/pdf_reader/dialogs/edit_pdf_config_dialog.dart';
import 'package:novel_v3/app/others/pdf_reader/pdf_reader.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class PdfItemMenuBottomSheet extends StatefulWidget {
  final PdfFile pdf;
  final VoidCallback? onClosedMenu;
  const PdfItemMenuBottomSheet({
    super.key,
    required this.pdf,
    this.onClosedMenu,
  });

  @override
  State<PdfItemMenuBottomSheet> createState() => _PdfItemMenuBottomSheetState();
}

class _PdfItemMenuBottomSheetState extends State<PdfItemMenuBottomSheet> {
  PdfProvider get getRProvider => context.read<PdfProvider>();

  @override
  Widget build(BuildContext context) {
    return TScrollableColumn(
      spacing: 0,
      children: [
        ListTile(
          leading: Icon(Icons.info_outline_rounded),
          title: Text('Info'),
          onTap: _showInfo,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.drive_file_rename_outline),
          title: Text('Rename'),
          onTap: _renameDialog,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit Config'),
          onTap: _editConfigDialog,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.restore, color: Colors.green),
          title: Text('Copy Outside'),
          onTap: _copyOutside,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.restore, color: Colors.yellow),
          title: Text('Move Outside'),
          onTap: _moveOutside,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.image),
          title: Text('Set Pdf Cover'),
          onTap: _setPdfCover,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.delete, color: Colors.red),
          title: Text('Delete'),
          onTap: _deletePdfDialog,
        ),
      ],
    );
  }

  void _showInfo() {
    closeContext(context);
    showTAlertDialog(
      context,
      title: Text('Info'),
      content: TScrollableColumn(
        children: [
          Text('Name: ${widget.pdf.title}'),
          Text('Parent: ${widget.pdf.getParentPath}'),
          Text('Size: ${widget.pdf.getSize.toFileSizeLabel()}'),
          Text('Config Name: ${widget.pdf.getCurrentConfigPath.getName()}'),
          Text(
            'Bookmark Name: ${widget.pdf.getCurrentBookmarkConfigPath.getName()}',
          ),
          Text('Date: ${widget.pdf.date.toParseTime()}'),
        ],
      ),
    );
  }

  void _renameDialog() {
    showTReanmeDialog(
      context,
      barrierDismissible: false,
      title: Text('Rename PDF Name'),
      text: widget.pdf.title.getName(withExt: false),
      submitText: 'Rename',
      onSubmit: (text) async {
        if (text.isEmpty) return;
        final newName = '$text.pdf';
        await getRProvider.rename(
          widget.pdf.copyWith(
            title: newName,
            path: pathJoin(widget.pdf.getParentPath, newName),
          ),
          oldName: widget.pdf.title,
        );

        widget.onClosedMenu?.call();
      },
    );
  }

  void _editConfigDialog() {
    final pdfConfig = PdfConfig.fromPath(widget.pdf.getCurrentConfigPath);
    closeContext(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => EditPdfConfigDialog(
        pdfConfig: pdfConfig,
        onUpdated: (updatedConfig) {
          updatedConfig.savePath(widget.pdf.getCurrentConfigPath);
        },
      ),
    );
  }

  void _copyOutside() async {
    final file = File(widget.pdf.path);
    final outFile = File(PathUtil.getOutPath(name: file.getName()));
    if (outFile.existsSync()) {
      showTMessageDialogError(context, 'အပြင်ဘက်မှာ PDF File ရှိနေပါတယ်!...');
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TProgressDialog(
        manager: CopyProgressManager(
          list: [CopyItem(sourcePath: file.path, destPath: outFile.path)],
        ),
        onSuccess: () {
          showTSnackBar(context, 'ကူးယူပြီးပါပြီ');
          closeContext(context);
        },
      ),
    );
  }

  void _moveOutside() async {
    final file = File(widget.pdf.path);
    final outFile = File(PathUtil.getOutPath(name: file.getName()));
    if (outFile.existsSync()) {
      showTMessageDialogError(context, 'အပြင်ဘက်မှာ PDF File ရှိနေပါတယ်!...');
      return;
    }
    await file.rename(outFile.path);
    if (!mounted) return;

    showTSnackBar(context, 'ရွေ့ထုတ်ပြီးပါပြီ');

    await getRProvider.init(widget.pdf.getParentPath);

    widget.onClosedMenu?.call();
  }

  void _setPdfCover() async {
    final novelProvider = context.read<NovelProvider>();
    final pdfCoverFile = File(widget.pdf.getCoverPath);
    final novelCoverFile = File(novelProvider.currentNovel!.getCoverPath);
    if (novelCoverFile.existsSync()) {
      await novelCoverFile.delete();
    }
    if (pdfCoverFile.existsSync()) {
      await pdfCoverFile.copy(novelCoverFile.path);
    }
    await ThanPkg.appUtil.clearImageCache();

    if (!mounted) return;
    showTSnackBar(context, 'Cover Changed');

    novelProvider.refersh();

    widget.onClosedMenu?.call();
  }

  void _deletePdfDialog() {
    showTConfirmDialog(
      context,
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      submitText: 'Delete Forever',
      onSubmit: () async {
        await getRProvider.deleteForever(widget.pdf);

        widget.onClosedMenu?.call();
      },
    );
  }
}
