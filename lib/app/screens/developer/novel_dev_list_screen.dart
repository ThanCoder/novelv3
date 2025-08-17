import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/n3_data/n3_data_export_confirm_dialog.dart';
import 'package:novel_v3/app/n3_data/n3_data_export_dialog.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/app/screens/developer/novel_config_export_dialog.dart';
import 'package:novel_v3/app/screens/developer/novel_dev_list_item.dart';
import 'package:novel_v3/app/screens/forms/edit_novel_form.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/novel_v3_uploader.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:novel_v3/more_libs/t_sort/t_sort_action_button.dart';
import 'package:novel_v3/more_libs/t_sort/t_sort_list.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../routes_helper.dart';

class NovelDevListScreen extends StatefulWidget {
  const NovelDevListScreen({super.key});

  @override
  State<NovelDevListScreen> createState() => _NovelDevListScreenState();
}

class _NovelDevListScreenState extends State<NovelDevListScreen> {
  @override
  void initState() {
    sortList.setAll(TSortList.getDefaultTypeList);
    sortList.add('Size', ascTitle: 'အသေးဆုံး', descTitle: 'အကြီးဆုံး');
    sortList.add('Completed', ascTitle: 'isCompleted', descTitle: 'OnGoing');
    sortList.add('Adult', ascTitle: 'IsAdult', descTitle: 'No Adult');
    sortList.add(
      'Description',
      ascTitle: 'ထည့်သွင်းပြီးသား',
      descTitle: 'မထည့်သွင်းရသေး',
    );
    sortName = 'Date';

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  bool isOnlineListLoading = false;
  List<UploaderNovel> onlineList = [];
  List<Novel> localList = [];
  final sortList = TSortList();
  late String sortName;
  bool isAsc = false;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      localList = await NovelServices.getList();
      // await localList.initCalcSize();

      _onSortList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  Future<void> initOnlineList() async {
    try {
      final isOnline = await ThanPkg.platform.isInternetConnected();
      if (!isOnline) {
        if (!mounted) return;
        showTMessageDialogError(context, 'Internet ဖွင့်ပေးပါ...');
        return;
      }
      setState(() {
        isOnlineListLoading = true;
      });
      onlineList = await OnlineNovelServices.getNovelList();
      if (!mounted) return;
      setState(() {
        isOnlineListLoading = false;
      });
      showTSnackBar(context, 'Online List အဆင်သင့်ဖြစ်ပါပြီ...');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isOnlineListLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('Novel Dev List'),
            snap: true,
            floating: true,
            actions: [_getOnlineListDownloader(), _getSortWidget()],
          ),
          _getListWidget(),
        ],
      ),
    );
  }

  Widget _getOnlineListDownloader() {
    if (isOnlineListLoading) {
      return TLoader(size: 30);
    }
    return IconButton(
      onPressed: initOnlineList,
      icon: Icon(Icons.cloud_download_rounded),
    );
  }

  Widget _getListWidget() {
    if (isLoading) {
      return SliverFillRemaining(child: TLoader.random());
    }
    return SliverList.builder(
      itemCount: localList.length,
      itemBuilder: (context, index) => NovelDevListItem(
        novel: localList[index],
        onClicked: _showItemMenu,
        onExistsTitle: (novel) => _checkNovelTitleAlreadyExists(novel.title),
      ),
    );
  }

  Widget _getSortWidget() {
    return TSortActionButton(
      fieldName: sortName,
      sortList: sortList,
      isAscDefault: isAsc,
      sortDialogCallback: (field, isAsc) {
        sortName = field;
        this.isAsc = isAsc;
        _onSortList();
      },
    );
  }

  void _onSortList() async {
    switch (sortName) {
      case 'Date':
        localList.sortDate(isNewest: !isAsc);
        break;
      case 'Title':
        localList.sortTitle(aToZ: isAsc);
        break;
      case 'Size':
        localList.sortSize(isSmallest: isAsc);
        break;
      case 'Completed':
        localList.sortCompleted(isCompleted: isAsc);
        break;
      case 'Adult':
        localList.sortAdult(isAdult: isAsc);
        break;
      case 'Description':
        localList.sortDesc(isAdded: isAsc);
        break;
    }
    setState(() {});
  }

  bool _checkNovelTitleAlreadyExists(String title) {
    final index = onlineList.indexWhere((e) => e.title == title);
    return index != -1;
  }

  // item menu
  void _showItemMenu(Novel novel) {
    showTMenuBottomSheet(
      context,
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(novel.title)),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit'),
          onTap: () {
            closeContext(context);
            _editNovel(novel);
          },
        ),
        ListTile(
          leading: Icon(Icons.import_export),
          title: Text('Export N3Data'),
          onTap: () {
            closeContext(context);
            _exportN3Data(novel);
          },
        ),
        ListTile(
          leading: Icon(Icons.import_export),
          title: Text('Export Config'),
          onTap: () {
            closeContext(context);
            _exportConfig(novel);
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever_rounded),
          title: Text('Delete'),
          onTap: () {
            Navigator.pop(context);
            _deleteConfirm(novel);
          },
        ),
      ],
    );
  }

  // export n3data
  void _exportN3Data(Novel novel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => N3DataExportConfirmDialog(
        onExport: (isSetPassword) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => N3DataExportDialog(
              isSetPassword: isSetPassword,
              novel: novel,
              onSuccess: () {
                showTSnackBar(
                  context,
                  'N3Data ထုတ်ပြီးပါပြီ...',
                  showCloseIcon: true,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _deleteConfirm(Novel novel) {
    showTConfirmDialog(
      context,
      submitText: 'Delete Forever',
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      onSubmit: () async {
        await context.read<NovelProvider>().delete(novel);
        if (!mounted) return;

        // ui delete
        final index = localList.indexWhere((e) => e.title == novel.title);
        if (index == -1) return;
        localList.removeAt(index);
        setState(() {});

        closeContext(context);
      },
    );
  }

  void _exportConfig(Novel novel) {
    showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => NovelConfigExportDialog(
        onApply: (isIncludeCover) async {
          try {
            final file = File(
              '${PathUtil.getOutPath()}/${novel.title}.config.json',
            );
            // config
            await file.writeAsString(await novel.getConfigJson());
            // cover
            if (isIncludeCover) {
              final coverFile = File('${novel.path}/cover.png');
              if (coverFile.existsSync()) {
                await coverFile.copy(
                  '${PathUtil.getOutPath()}/${novel.title}.png',
                );
              }
            }
            if (!context.mounted) return;
            showTSnackBar(context, 'Config Exported');
          } catch (e) {
            NovelDirApp.showDebugLog(
              e.toString(),
              tag: 'NovelDevListScreen:_exportConfig',
            );
            if (!context.mounted) return;
            showTMessageDialogError(context, e.toString());
          }
        },
      ),
    );
  }

  void _editNovel(Novel novel) {
    goRoute(context, builder: (context) => EditNovelForm(novel: novel));
  }
}
