import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_list_item.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_install_confirm_dialog.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_install_dialog.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_services.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'n3_data.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class N3DataScannerScreen extends StatefulWidget {
  const N3DataScannerScreen({super.key});

  @override
  State<N3DataScannerScreen> createState() => _N3DataScannerState();
}

class _N3DataScannerState extends State<N3DataScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  List<N3Data> n3DataList = [];
  int currentSortId = 101;

  Future<void> init() async {
    try {
      // check storage persmission
      if (!await ThanPkg.platform.isStoragePermissionGranted()) {
        await ThanPkg.platform.requestStoragePermission();
        return;
      }

      setState(() {
        isLoading = true;
      });

      n3DataList = await N3DataServices.getScanList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _onSort();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      appBar: AppBar(
        title: Text('N3 Data Scanner'),
        actions: [
          // SortComponent(value: sortType, onChanged: _onSort),
          TPlatform.isDesktop
              ? IconButton(onPressed: init, icon: Icon(Icons.refresh))
              : SizedBox.shrink(),
        ],
      ),
      body: isLoading
          ? Center(child: TLoaderRandom())
          : n3DataList.isEmpty
          ? _getEmptyList()
          : RefreshIndicator.adaptive(
              onRefresh: init,
              child: CustomScrollView(slivers: [_getSliverList()]),
            ),
    );
  }

  Widget _getEmptyList() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('N3 Data Not Found...'),
          IconButton(
            color: Colors.blue,
            onPressed: init,
            icon: Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }

  Widget _getSliverList() {
    return SliverList.builder(
      itemCount: n3DataList.length,
      itemBuilder: (context, index) => N3DataListItem(
        cachePath: PathUtil.getCachePath(),
        n3data: n3DataList[index],
        onClicked: (n3data) => _showItemOnClickMenu(n3data),
        onRightClicked: _showItemMenu,
      ),
    );
  }

  void _onSort() {
    // if (sort.title == 'title') {
    //   n3DataList.sortTitle(aToZ: sort.isAsc);
    // }
    // if (sort.title == 'date') {
    //   n3DataList.sortDate(isNewest: !sort.isAsc);
    // }
    // sortType = sort;
    // setState(() {});
  }

  void _showItemOnClickMenu(N3Data n3data) {
    showTMenuBottomSheet(
      context,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(n3data.getTitle),
        ),
        Divider(),
        // ListTile(
        //   leading: Icon(Icons.info_outline_rounded),
        //   title: Text('Info'),
        //   onTap: () {
        //     closeContext(context);
        //     _showInfo(n3data);
        //   },
        // ),
        ListTile(
          leading: Icon(Icons.install_desktop),
          title: Text('ထည့်သွင်းမယ်'),
          onTap: () {
            closeContext(context);
            _installData(n3data);
          },
        ),
      ],
    );
  }

  // void _showInfo(N3Data n3data) {}
  void _installData(N3Data n3data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => N3DataInstallConfirmDialog(
        n3data: n3data,
        onInstall: (isInstallConfigFiles, isInstallFileOverride) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => N3DataInstallDialog(
              n3data: n3data,
              isInstallConfigFiles: isInstallConfigFiles,
              isInstallFileOverride: isInstallFileOverride,
              onSuccess: () {
                setState(() {});
                showTSnackBar(context, '${n3data.getTitle}: သွင်းပြီးပါပြီ');
              },
            ),
          );
        },
      ),
    );
  }

  // item right menu
  void _showItemMenu(N3Data n3data) {
    showTMenuBottomSheet(
      context,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(n3data.getTitle),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Rename'),
          onTap: () {
            closeContext(context);
            _rename(n3data);
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever_rounded),
          title: Text('Delete'),
          onTap: () {
            closeContext(context);
            _deleteConfirm(n3data);
          },
        ),
      ],
    );
  }

  void _rename(N3Data n3data) {
    showTReanmeDialog(
      context,
      barrierDismissible: false,
      title: Text('Rename'),
      submitText: 'Rename',
      text: n3data.getTitle.getName(withExt: false),
      onSubmit: (text) async {
        try {
          final index = n3DataList.indexWhere(
            (e) => e.getTitle == n3data.getTitle,
          );
          if (index == -1) return;
          await n3data.rename('${n3data.getParentPath}/$text.${N3Data.getExt}');
          n3DataList[index] = n3data;

          if (!mounted) return;
          setState(() {});
        } catch (e) {
          // NovelDirApp.showDebugLog(e.toString(), tag: 'N3DataScannerScreen:_rename');
        }
      },
    );
  }

  void _deleteConfirm(N3Data n3data) {
    showTConfirmDialog(
      context,
      submitText: 'Delete Forever!',
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      onSubmit: () async {
        await n3data.delete();
        // ui remove
        final index = n3DataList.indexWhere(
          (e) => e.getTitle == n3data.getTitle,
        );
        if (index == -1) return;
        n3DataList.removeAt(index);
        if (!mounted) return;
        setState(() {});
      },
    );
  }
}
