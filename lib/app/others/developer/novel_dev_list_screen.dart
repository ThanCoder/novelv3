import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/n3_data/n3_data.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_export_confirm_dialog.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_export_dialog.dart';
import 'package:novel_v3/app/ui/novel_dir_app.dart';
import 'package:novel_v3/app/others/developer/novel_config_export_dialog.dart';
import 'package:novel_v3/app/others/developer/novel_dev_list_item.dart';
import 'package:novel_v3/app/ui/main_ui/screens/forms/edit_novel_form.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/novel_v3_uploader.dart'
    as uploader
    hide NovelExtension;
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../ui/routes_helper.dart';

class NovelDevListScreen extends StatefulWidget {
  const NovelDevListScreen({super.key});

  @override
  State<NovelDevListScreen> createState() => _NovelDevListScreenState();
}

class _NovelDevListScreenState extends State<NovelDevListScreen> {
  @override
  void initState() {
    sortList.add(
      TSort(id: 0, title: 'Size', ascTitle: 'အသေးဆုံး', descTitle: 'အကြီးဆုံး'),
    );
    sortList.add(
      TSort(
        id: 1,
        title: 'Completed',
        ascTitle: 'isCompleted',
        descTitle: 'OnGoing',
      ),
    );
    sortList.add(
      TSort(id: 2, title: 'Adult', ascTitle: 'IsAdult', descTitle: 'No Adult'),
    );
    sortList.add(
      TSort(
        id: 3,
        title: 'Description',
        ascTitle: 'ထည့်သွင်းပြီးသား',
        descTitle: 'မထည့်သွင်းရသေး',
      ),
    );
    sortList.add(
      TSort(
        id: 4,
        title: 'VData',
        ascTitle: 'ထုတ်ထားပြီးပြီ',
        descTitle: 'မထုတ်ရသေး',
      ),
    );
    sortList.addAll(TSort.getDefaultList);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  bool isOnlineListLoading = false;
  List<uploader.Novel> onlineList = [];
  List<Novel> localList = [];
  List<TSort> sortList = [];
  int currentSortId = TSort.getDateId;
  bool isAsc = false;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      // localList = await NovelServices.getList(isAllCalc: true);

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
      onlineList = await uploader.NovelServices.getApiDatabase.getAll();

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
      body: RefreshIndicator.adaptive(
        onRefresh: init,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text('Novel Dev List'),
              snap: true,
              floating: true,
              actions: [
                TPlatform.isDesktop
                    ? IconButton(onPressed: init, icon: Icon(Icons.refresh))
                    : SizedBox.shrink(),
                _getOnlineListDownloader(),
                _getSortWidget(),
              ],
            ),
            _getListWidget(),
          ],
        ),
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

  // sorting
  Widget _getSortWidget() {
    final resList = List.of(sortList);
    if (onlineList.isNotEmpty) {
      resList.add(
        TSort(
          id: 10,
          title: 'Online',
          ascTitle: 'ရှိပြီးသား',
          descTitle: 'မရှိသေး',
        ),
      );
    }

    return IconButton(
      onPressed: () {
        showTSortDialog(
          context,
          currentId: currentSortId,
          sortList: resList,
          isAsc: isAsc,
          showSortType: TShowSortTypes.title,
          submitText: Text('စစ်ထုတ်မယ်'),
          sortDialogCallback: (id, isAsc) {
            currentSortId = id;
            this.isAsc = isAsc;
            _onSortList();
          },
        );
      },
      icon: Icon(Icons.sort),
    );
  }

  void _onSortList() async {
    if (currentSortId == TSort.getDateId) {
      localList.sortDate(isNewest: !isAsc);
    }
    if (currentSortId == TSort.getTitleId) {
      localList.sortTitle(aToZ: isAsc);
    }
    if (currentSortId == 0) {
      localList.sortSize(isSmallest: isAsc);
    }
    if (currentSortId == 1) {
      localList.sortCompleted(isCompleted: isAsc);
    }
    if (currentSortId == 2) {
      localList.sortAdult(isAdult: isAsc);
    }
    if (currentSortId == 3) {
      localList.sortDesc(isAdded: isAsc);
    }
    if (currentSortId == 4) {
      localList.sortN3Data(isExported: isAsc);
    }
    if (currentSortId == 10) {
      final titleList = onlineList.map((e) => e.title).toSet().toList();
      localList.sort((a, b) {
        if (isAsc) {
          // ရှိနေပြီးသား
          if (titleList.contains(a.title)) return -1;
          if (!titleList.contains(a.title)) return 1;
        } else {
          //မရှိသေး
          if (titleList.contains(a.title)) return 1;
          if (!titleList.contains(a.title)) return -1;
        }
        return 0;
      });
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
      title: Text(novel.title),
      children: [
        ListTile(
          leading: Icon(Icons.open_in_browser),
          title: Text('Content'),
          onTap: () {
            closeContext(context);
            _goNovelContent(novel);
          },
        ),
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
        novel.isN3DataExported
            ? ListTile(
                leading: Icon(Icons.edit_document),
                title: Text('Edit N3Data Name'),
                onTap: () {
                  closeContext(context);
                  _editN3DataName(novel);
                },
              )
            : SizedBox.shrink(),
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

  // delete novel
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
            await file.writeAsString(jsonEncode(novel.toMap()));
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

  void _editN3DataName(Novel novel) {
    showTReanmeDialog(
      context,
      barrierDismissible: false,
      title: Text('Edit N3Data Name'),
      text: novel.title,
      onSubmit: (text) {
        final oldFile = File(
          '${PathUtil.getOutPath()}/${novel.title}.${N3Data.getExt}',
        );
        if (!oldFile.existsSync()) return;
        oldFile.renameSync('${PathUtil.getOutPath()}/$text.${N3Data.getExt}');
        setState(() {});
      },
    );
  }

  void _goNovelContent(Novel novel) {
    goNovelContentScreen(context, novel);
  }

  void _editNovel(Novel novel) {
    goRoute(context, builder: (context) => EditNovelForm(novel: novel));
  }
}
