import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/n3_data_list_item.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/services/n3_data_services.dart';
import 'package:novel_v3/app/types/n3_data.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_component.dart';
import 'package:novel_v3/more_libs/sort_dialog_v1.0.0/sort_type.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class N3DataScanner extends StatefulWidget {
  void Function(BuildContext context, N3Data n3data)? onClicked;
  N3DataScanner({super.key, this.onClicked});

  @override
  State<N3DataScanner> createState() => _N3DataScannerState();
}

class _N3DataScannerState extends State<N3DataScanner> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  List<N3Data> n3DataList = [];
  SortType sortType = SortType(title: 'date', isAsc: false);

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
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString(), tag: 'N3DataScanner:init');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      appBar: AppBar(
        title: Text('N3 Data Scanner'),
        actions: [
          SortComponent(value: sortType, onChanged: _onSort),
          PlatformExtension.isDesktop()
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
        onClicked: (n3data) => widget.onClicked?.call(context, n3data),
        onRightClicked: _showItemMenu,
      ),
    );
  }

  void _onSort(SortType sort) {
    // if (sort.title == 'title') {
    //   list.sortTitle(aToZ: sort.isAsc);
    // }
    // if (sort.title == 'date') {
    //   list.sortDate(isNewest: !sort.isAsc);
    // }
    // sortType = sort;
    // setState(() {});
  }

  // item menu
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
          final index = n3DataList.indexWhere((e) => e.getTitle == n3data.getTitle);
          if (index == -1) return;
          await n3data.rename('${n3data.getParentPath}/$text.${N3Data.getExt}');
          n3DataList[index] = n3data;

          if (!mounted) return;
          setState(() {});
        } catch (e) {
          NovelDirApp.showDebugLog(e.toString(), tag: 'N3DataScanner:_rename');
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
        final index = n3DataList.indexWhere((e) => e.getTitle == n3data.getTitle);
        if (index == -1) return;
        n3DataList.removeAt(index);
        if (!mounted) return;
        setState(() {});
      },
    );
  }
}
