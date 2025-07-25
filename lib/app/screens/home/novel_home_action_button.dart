import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/dialogs/core/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/home/create_novel_from_pdf_scanner_screen.dart';
import 'package:novel_v3/app/screens/tables/novel_table_screen.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/my_libs/novel_data/novel_data_scanner_screen.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/t_history_record.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/t_history_screen.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/t_history_services.dart';
import 'package:t_widgets/extensions/index.dart';

class NovelHomeActionButton extends ConsumerStatefulWidget {
  const NovelHomeActionButton({super.key});

  @override
  ConsumerState<NovelHomeActionButton> createState() =>
      _NovelHomeActionButtonState();
}

class _NovelHomeActionButtonState extends ConsumerState<NovelHomeActionButton> {
  void _newNovel() {
    final provider = ref.read(novelNotifierProvider.notifier);
    final list = provider.getList;
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        title: 'New Novel',
        onCheckIsError: (text) {
          final founds = list.where((nv) => nv.title == text);
          if (founds.isNotEmpty) {
            return 'Already Exists && Chooose Another Name!';
          }
          return null;
        },
        onCancel: () {},
        onSubmit: (title) {
          try {
            final novel = NovelModel.create(title.trim());
            provider.insertUI(novel);
            goNovelEditForm(context, ref, novel);
            //set record
            THistoryServices.instance.add(THistoryRecord.create(
              title: title,
              desc: 'Novel အသစ်ဖန်တီးခြင်း',
            ));
          } catch (e) {
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _newNovelFromPdf() {
    final provider = ref.read(novelNotifierProvider.notifier);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNovelFromPdfScannerScreen(
          onChoosed: (pdf) async {
            try {
              // title ကို စစ်ဆေးမယ်
              final novelDir = Directory(
                  '${PathUtil.getSourcePath()}/${pdf.title.getName(withExt: false).trim()}');
              if (novelDir.existsSync()) {
                throw ErrorDescription(
                    'PDF အမည်နဲ့ Novel ရှိနေပြီးသားဖြစ်နေပါတယ်!');
              }

              // novel ဖန်တီးမယ်
              await novelDir.create();
              // pdf move မယ်
              await pdf.moveTo('${novelDir.path}/${pdf.title}.pdf');
              // pdf thumbnail path ကို copy ကူးမယ်
              await pdf.copyCover('${novelDir.path}/cover.png');

              final novel = NovelModel.fromPath(novelDir.path);
              // set ui
              provider.insertUI(novel);
              // go edit screen
              goNovelEditForm(context, ref, novel);
              //set record
              THistoryServices.instance.add(THistoryRecord.create(
                title: novel.title,
                desc: 'Novel အသစ်ဖန်တီးခြင်း',
              ));

              if (!mounted) return;
              showMessage(context, 'New Novel Created');
            } catch (e) {
              if (!mounted) return;
              showDialogMessage(context, e.toString());
            }
          },
        ),
      ),
    );
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Novel'),
                onTap: () {
                  Navigator.pop(context);
                  _newNovel();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('New Novel From Pdf'),
                onTap: () {
                  Navigator.pop(context);
                  _newNovelFromPdf();
                },
              ),
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Import Data'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NovelDataScannerScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined),
                title: const Text('Table Style'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NovelTableScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('History Record'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const THistoryScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showMenu,
      icon: const Icon(Icons.more_vert),
    );
  }
}
