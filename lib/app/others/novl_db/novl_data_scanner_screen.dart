import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/novl_db/novl_data.dart';
import 'package:novel_v3/app/others/novl_db/novl_data_extension.dart';
import 'package:novel_v3/app/others/novl_db/novl_data_install_screen.dart';
import 'package:novel_v3/app/others/novl_db/novl_data_services.dart';
import 'package:novel_v3/app/others/novl_db/novl_list_item.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class NovlDataScannerScreen extends StatefulWidget {
  const NovlDataScannerScreen({super.key});

  @override
  State<NovlDataScannerScreen> createState() => _N3DataScannerState();
}

class _N3DataScannerState extends State<NovlDataScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  List<NovlData> list = [];
  int currentSortId = TSort.getDateId;
  final sortList = TSort.getDefaultList
    ..add(
      TSort(id: 1, title: 'Size', ascTitle: 'Smallest', descTitle: 'Biggest'),
    );
  bool isSortAsc = false;

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

      list = await NovlDataServices.getScanList();

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
        title: Text('Novl Data Scanner'),
        actions: [
          _getSortWidget(),
          TPlatform.isDesktop
              ? IconButton(onPressed: init, icon: Icon(Icons.refresh))
              : SizedBox.shrink(),
        ],
      ),
      body: isLoading
          ? Center(child: TLoaderRandom())
          : list.isEmpty
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
          Text('Novl Data Not Found...'),
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
      itemCount: list.length,
      itemBuilder: (context, index) =>
          NovlListItem(data: list[index], onClicked: _showItemOnClickMenu),
    );
  }

  Widget _getSortWidget() {
    return IconButton(
      onPressed: () {
        showTSortDialog(
          context,
          currentId: currentSortId,
          isAsc: isSortAsc,
          sortList: sortList,
          sortDialogCallback: (id, isAsc) {
            currentSortId = id;
            isSortAsc = isAsc;
            _onSort();
          },
        );
      },
      icon: Icon(Icons.sort),
    );
  }

  void _onSort() {
    if (currentSortId == TSort.getTitleId) {
      list.sortTitle(aToZ: isSortAsc);
    }
    if (currentSortId == TSort.getDateId) {
      list.sortDate(isNewest: !isSortAsc);
    }
    if (currentSortId == 1) {
      list.sortSize(isSmallest: isSortAsc);
    }
    setState(() {});
  }

  void _showItemOnClickMenu(NovlData data) {
    showTMenuBottomSheet(
      context,
      children: [
        Padding(padding: const EdgeInsets.all(8.0), child: Text(data.title)),
        Divider(),
        ListTile(
          leading: Icon(Icons.info_outline_rounded),
          title: Text('Info'),
          onTap: () {
            closeContext(context);
            _showInfo(data);
          },
        ),
        ListTile(
          leading: Icon(Icons.install_desktop),
          title: Text('ထည့်သွင်းမယ်'),
          onTap: () {
            closeContext(context);
            _installData(data);
          },
        ),
        ListTile(
          leading: Icon(Icons.delete_forever, color: Colors.red),
          title: Text('ဖျက်မယ်'),
          onTap: () {
            closeContext(context);
            _deleteConfirm(data);
          },
        ),
      ],
    );
  }

  void _showInfo(NovlData data) {
    showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        scrollable: true,
        title: Text('အချက်အလက်များ'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textIconWidget(data.title, iconData: Icons.title),
            textIconWidget(data.type, iconData: Icons.insert_drive_file),
            textIconWidget(
              data.size.toFileSizeLabel(),
              iconData: Icons.sd_card,
            ),
            textIconWidget(data.date.toParseTime(), iconData: Icons.date_range),
            SizedBox(height: 10),

            // Novel Meta
            ExpansionTile(
              tilePadding: EdgeInsets.all(0),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: Text(
                'Novl Info',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Novl အချက်အလက်များ'),
              children: [Text(data.info.desc)],
            ),

            // Novel Meta
            ExpansionTile(
              tilePadding: EdgeInsets.all(0),
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: Text(
                'Novel Meta',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Novel အချက်အလက်များ'),
              children: [
                textIconWidget(data.novelMeta.title, iconData: Icons.title),
                Text('Author: ${data.novelMeta.author}'),
                Text('translator: ${data.novelMeta.translator}'),
                Text('MC: ${data.novelMeta.mc}'),
                Text('originalTitle: ${data.novelMeta.originalTitle}'),
                Text('englishTitle: ${data.novelMeta.englishTitle}'),
                Text('isAdult: ${data.novelMeta.isAdult}'),
                Text('isCompleted: ${data.novelMeta.isCompleted}'),
                Text('otherTitleList: ${data.novelMeta.otherTitleList}'),
                Text('Tags: ${data.novelMeta.tags}'),
                Divider(),
                Text(data.novelMeta.desc),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              closeContext(context);
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _installData(NovlData data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovlDataInstallScreen(
          data: data,
          onClosed: () => closeContext(context),
        ),
      ),
    );
  }

  void _deleteConfirm(NovlData data) {
    showTConfirmDialog(
      context,
      submitText: 'Delete Forever!',
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      onSubmit: () async {
        await data.deleteForever();
        // ui remove
        final index = list.indexWhere((e) => e.title == data.title);
        if (index == -1) return;
        list.removeAt(index);
        if (!mounted) return;
        setState(() {});
      },
    );
  }
}
