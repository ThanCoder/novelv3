import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hb_db/hb_db.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/novl_db/novl_data.dart';
import 'package:novel_v3/app/others/novl_db/novl_db.dart';
import 'package:novel_v3/app/others/novl_db/novl_install_progress_manager.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/progress_manager/progress_dialog.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/utils/f_path.dart';

class NovlDataInstallScreen extends StatefulWidget {
  final NovlData data;
  final VoidCallback? onClosed;
  const NovlDataInstallScreen({super.key, required this.data, this.onClosed});

  @override
  State<NovlDataInstallScreen> createState() => _NovlDataInstallScreenState();
}

class _NovlDataInstallScreenState extends State<NovlDataInstallScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  List<DBFEntry> list = [];
  List<String> selectedNameList = [];
  bool isLoading = false;
  bool selectAll = true;

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });
      list = await NovlDB.readFiles(widget.data.path);
      list.sort((a, b) => a.name.compareTo(b.name));

      // selectedNameList = list.map((e) => e.name).toList();
      _checkExistsAndAutoRemove();
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

  String get getInstallNovelPath =>
      PathUtil.getSourcePath(name: widget.data.novelMeta.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppbar(),
      body: isLoading ? Center(child: TLoader.random()) : _getListWiget(),
      floatingActionButton: selectedNameList.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: _install,
              child: Icon(Icons.install_mobile),
            ),
    );
  }

  AppBar _getAppbar() {
    return AppBar(
      title: Text(
        'Install `${widget.data.novelMeta.title}`',
        style: TextStyle(fontSize: 11),
      ),
      actions: [
        TextButton(onPressed: _checkExistsAndAutoRemove, child: Text('Auto')),
        Checkbox.adaptive(
          value: selectAll,
          onChanged: (value) {
            selectAll = value!;
            _selectAll();
          },
        ),
        Text(
          'Install Count: ${selectedNameList.length}',
          style: TextStyle(fontSize: 11),
        ),
        SizedBox(width: 10),
      ],
    );
  }

  Widget _getListWiget() {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: init, icon: Icon(Icons.refresh)),
            Text('List Empty!...'),
          ],
        ),
      );
    }
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) => _getListItem(list[index]),
    );
  }

  Widget _getListItem(DBFEntry file) {
    return Row(
      spacing: 4,
      children: [
        _getCheckButton(file),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                file.name,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: TextStyle(fontSize: 13),
              ),
              Text('Size: ${file.getSizeLabel}'),
              !file.isCompressed
                  ? SizedBox.fromSize()
                  : Text('Compressed Size: ${file.getCompressedSizeLabel}'),
              !_isExistsInNovel(file)
                  ? SizedBox.fromSize()
                  : Text(
                      'Novel ထဲမှာရှိနေပါတယ်!...',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getCheckButton(DBFEntry file) {
    final isExists = selectedNameList.contains(file.name);
    return IconButton(
      onPressed: () {
        if (isExists) {
          selectedNameList.remove(file.name);
        } else {
          selectedNameList.add(file.name);
        }
        setState(() {});
      },
      icon: Icon(isExists ? Icons.check_box : Icons.check_box_outline_blank),
    );
  }

  bool _isExistsInNovel(DBFEntry file) {
    final novelFile = File(pathJoin(getInstallNovelPath, file.name));
    return novelFile.existsSync();
  }

  void _selectAll() {
    if (selectAll) {
      selectedNameList = list.map((e) => e.name).toList();
    } else {
      selectedNameList.clear();
    }
    setState(() {});
  }

  void _checkExistsAndAutoRemove() {
    selectedNameList = list
        .where((e) => !_isExistsInNovel(e))
        .map((e) => e.name)
        .toList();
    setState(() {});
  }

  void _install() {
    final installList = list
        .where((e) => selectedNameList.contains(e.name))
        .toList();
    showAdaptiveDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        progressManager: NovlInstallProgressManager(
          installList: installList,
          installNovelPath: getInstallNovelPath,
          onDone: () {
            if (!mounted) return;
            _checkExistsAndAutoRemove();
            context.read<NovelProvider>().init(isUsedCache: false);
          },
        ),
      ),
    );
  }
}
