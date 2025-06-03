import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/my_libs/novel_data/novel_data_list_item.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:t_widgets/t_widgets.dart';

import 'package:than_pkg/than_pkg.dart';

import '../../app/components/index.dart';
import '../../app/dialogs/index.dart';
import '../../app/services/index.dart';
import 'data_import_dialog.dart';

class NovelDataScannerScreen extends ConsumerStatefulWidget {
  const NovelDataScannerScreen({super.key});

  @override
  ConsumerState<NovelDataScannerScreen> createState() =>
      _NovelDataScannerScreenState();
}

class _NovelDataScannerScreenState
    extends ConsumerState<NovelDataScannerScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  bool isSorted = true;
  List<NovelDataModel> list = [];

  Future<void> init() async {
    if (Platform.isAndroid) {
      if (!await ThanPkg.android.permission.isStoragePermissionGranted()) {
        await ThanPkg.android.permission.requestStoragePermission();
        return;
      }
    }

    setState(() {
      isLoading = true;
    });
    list = await NovelDataServices.instance.dataScanner();
    //gen cover
    await NovelDataServices.instance.genCover(list: list);

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void _installData(NovelDataModel novelData) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DataImportDialog(
        path: novelData.path,
        onDone: () async {
          await ref
              .read(novelNotifierProvider.notifier)
              .initList(isReset: true);
          if (!mounted) return;
          setState(() {});
        },
      ),
    );
  }

  void _deleteConfirm(NovelDataModel novelData) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`${novelData.title}` ကိုဖျက်ချင်တာ သေချာပြီလား?`',
        submitText: 'Delete',
        onCancel: () {},
        onSubmit: () async {
          try {
            //ui
            list = list.where((pf) => pf.path != novelData.path).toList();
            novelData.delete();

            setState(() {});
          } catch (e) {
            if (!mounted) return;
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _showInfo(NovelDataModel novelData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${novelData.title}'),
              Text('Size: ${novelData.size.toDouble().toFileSizeLabel()}'),
              Text(
                  'Date: ${DateTime.fromMillisecondsSinceEpoch(novelData.date).toParseTime()}'),
              Text(
                  'Ago: ${DateTime.fromMillisecondsSinceEpoch(novelData.date).toAutoParseTime()}'),
              Text('Path: ${novelData.path}'),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(NovelDataModel novelData) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            spacing: 5,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  novelData.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const Divider(),
              //info
              ListTile(
                leading: const Icon(Icons.info_outlined),
                title: const Text('Infomation'),
                onTap: () {
                  Navigator.pop(context);
                  _showInfo(novelData);
                },
              ),
              //copy title
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Name'),
                onTap: () {
                  Navigator.pop(context);
                  copyText(novelData.title);
                  if (Platform.isLinux) {
                    showMessage(context, 'Copied');
                  }
                },
              ),
              //delete
              ListTile(
                iconColor: Colors.red,
                leading: const Icon(Icons.delete_forever_rounded),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteConfirm(novelData);
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
    return Scaffold(
      body: isLoading
          ? TLoader()
          : RefreshIndicator(
              onRefresh: init,
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    snap: true,
                    floating: true,
                    title: const Text('Data Scanner'),
                    actions: [
                      PlatformExtension.isDesktop()
                          ? IconButton(
                              onPressed: init,
                              icon: const Icon(Icons.refresh),
                            )
                          : const SizedBox.shrink(),
                      IconButton(
                        onPressed: () {
                          final res = list.reversed.toList();
                          list = res;
                          isSorted = !isSorted;
                          setState(() {});
                        },
                        icon: const Icon(
                          Icons.sort_by_alpha_sharp,
                        ),
                      ),
                    ],
                  ),
                  SliverList.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) => NovelDataListItem(
                      novelData: list[index],
                      isAlreadyInstalled: (novelData) {
                        return ref
                            .read(novelNotifierProvider.notifier)
                            .isExists(novelData.title);
                      },
                      onClicked: _installData,
                      onLongClicked: _showMenu,
                    ),
                  ),
                ],
              )),
    );
  }
}
