import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/dialogs/mediafire_downloader_dialog.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/screens/index.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:provider/provider.dart';

import '../dialogs/export_novel_data_dialog.dart';

class NovelContentModalBottomSheet extends StatefulWidget {
  NovelModel novel;
  void Function()? onBackPress;
  NovelContentModalBottomSheet({
    super.key,
    required this.novel,
    this.onBackPress,
  });

  @override
  State<NovelContentModalBottomSheet> createState() =>
      _NovelContentModalBottomSheetState();
}

class _NovelContentModalBottomSheetState
    extends State<NovelContentModalBottomSheet> {
  //delete
  void deleteNovelConfim() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('အတည်ပြုခြင်း'),
        content: const Text('ဖျက်ချင်တာ သေချာပြီလား?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await deleteNovel(novel: widget.novel);
                if (widget.onBackPress != null) {
                  widget.onBackPress!();
                }
              } catch (e) {
                if (!mounted) return;
                showMessage(context, e.toString());
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  //download
  void _downloadPdf() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RenameDialog(
        title: 'Mediafire Downloader',
        renameLabelText: const Text('PDF Url'),
        renameText: '',
        submitText: 'Download',
        onCancel: () {},
        onSubmit: (url) {
          if (url.isEmpty) return;
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => MediafireDownloaderDialog(
              url: url,
              saveDirPath: widget.novel.path,
              onSuccess: () {
                showDialogMessage(context, 'PDF Downloaded');
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 200),
        child: Column(
          children: [
            //edit novel
            ListTile(
              onTap: () {
                Navigator.pop(context);

                final novel = context.read<NovelProvider>().getNovel;

                if (novel != null) {
                  //go edit form
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NovelFromScreen(novel: novel),
                    ),
                  );
                }
              },
              leading: const Icon(Icons.add),
              title: const Text('Edit Novel'),
            ),
            //add chapter
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChapterAddFromScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.add),
              title: const Text('Add Chapter'),
            ),
            //add pdf
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfAddFormScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.add),
              title: const Text('Add PDF Files'),
            ),
            //download pdf
            ListTile(
              onTap: () {
                Navigator.pop(context);
                _downloadPdf();
              },
              leading: const Icon(Icons.download),
              title: const Text('Download PDF'),
            ),

            //export novel data
            ListTile(
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      ExportNovelDataDialog(dialogContext: context),
                );
              },
              leading: const Icon(Icons.import_export),
              title: const Text('Novel Data ထုတ်မယ်'),
            ),

            //delete novel
            ListTile(
              onTap: () {
                Navigator.pop(context);
                deleteNovelConfim();
              },
              leading: const Icon(Icons.delete_forever),
              title: const Text(
                'Delete Novel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
