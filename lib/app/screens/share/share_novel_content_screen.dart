import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/share_data_list_view.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/download_progress_dialog.dart';
import 'package:novel_v3/app/dialogs/share_data_open_dialog.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/pdf_readers/pdfrx_reader.dart';
import 'package:novel_v3/app/services/novel_isolate_services.dart';
import 'package:novel_v3/app/services/core/recent_db_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';

import '../../widgets/index.dart';

class ShareNovelContentScreen extends StatefulWidget {
  String apiUrl;
  NovelModel novel;
  ShareNovelContentScreen({
    super.key,
    required this.apiUrl,
    required this.novel,
  });

  @override
  State<ShareNovelContentScreen> createState() =>
      _ShareNovelContentScreenState();
}

class _ShareNovelContentScreenState extends State<ShareNovelContentScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  final dio = Dio();
  bool isLoading = false;
  bool isDownloading = false;
  List<ShareDataModel> dataList = [];
  List<ShareDataModel> allDataList = [];
  String filterOptionGroupValue = "all";

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });

      final listUrl = 'http://${widget.apiUrl}/list?dir=${widget.novel.path}';
      final res = await dio.get(listUrl);
      if (res.statusCode == 200) {
        List<dynamic> list = res.data;
        allDataList = list.map((map) => ShareDataModel.fromMap(map)).toList();

        allDataList.sort((a, b) {
          return a.name.compareTo(b.name);
        });

        setState(() {
          dataList = allDataList;
          isLoading = false;
        });
        _checkFiles();
        _filterChange(filterOptionGroupValue);
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkFiles() {
    //check exists
    final novelDir = Directory('${getSourcePath()}/${widget.novel.title}');
    if (novelDir.existsSync()) {
      dataList = dataList.map((data) {
        data.isExists = File('${novelDir.path}/${data.name}').existsSync();
        return data;
      }).toList();
      setState(() {});
    }
  }

  void _filterChange(String value) {
    switch (value) {
      case 'all':
        setState(() {
          dataList = allDataList;
        });
        break;
      case 'pdf':
        setState(() {
          dataList =
              allDataList.where((data) => data.name.endsWith('.pdf')).toList();
        });
        break;
      case 'chapter':
        setState(() {
          dataList = allDataList
              .where((data) => int.tryParse(data.name) != null)
              .toList();
        });
        break;
      case 'config':
        setState(() {
          dataList = allDataList.where((data) {
            return !data.name.endsWith('.pdf') &&
                !data.name.endsWith('.png') &&
                int.tryParse(data.name) == null;
          }).toList();
        });
        break;
      case 'cover':
        setState(() {
          dataList =
              allDataList.where((data) => data.name.endsWith('.png')).toList();
        });
        break;
    }
    _checkFiles();
  }

  void _refreshNovelList() async {
    final novelList = await getNovelListFromPathIsolate();
    novelListNotifier.value = novelList;
  }

  void _download(ShareDataModel shareData) async {
    try {
      //
      final urlPath = 'http://${widget.apiUrl}/download?path=${shareData.path}';
      final savePath =
          '${createDir('${getSourcePath()}/${widget.novel.title}')}/${shareData.name}';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => TLoader(),
      );

      debugPrint('start download');
      await dio.download(
        urlPath,
        savePath,
        onReceiveProgress: (count, total) {
          if (total <= 0) return;
          debugPrint(
              'percentage: ${(count / total * 100).toStringAsFixed(0)}%');
        },
      );
      if (mounted) {
        Navigator.pop(context);
        // showMessage(context, 'Download');
      }
      debugPrint('downloaded');
      //novel data ရှိမရှိ စစ်ဆေးခြင်း
      _checkFiles();
      _refreshNovelList();
    } catch (e) {
      // if (mounted) {
      //   Navigator.pop(context);
      // }

      debugPrint(e.toString());
    }
  }

  void _allDownload() async {
    final saveDirPath = createDir('${getSourcePath()}/${widget.novel.title}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DownloadProgressDialog(
        pathUrlList: allDataList.map((data) => data.path).toList(),
        saveDirPath: saveDirPath,
        onSuccess: () {
          showMessage(ctx, 'Download လုပ်ပြီးပါပြီ');
          //novel data ရှိမရှိ စစ်ဆေးခြင်း
          _checkFiles();
          _refreshNovelList();
        },
        onCancaled: () {
          showMessage(ctx, 'Cancel လိုက်ပါပြီ');
          //novel data ရှိမရှိ စစ်ဆေးခြင်း
          _checkFiles();
          _refreshNovelList();
        },
        onError: (msg) {
          showDialogMessage(context, msg);
        },
      ),
    );
  }

  void _openFileDialog(ShareDataModel shareData) {
    //pdf
    if (shareData.name.endsWith('.pdf')) {
      final host = getRecentDB<String>('server_address');
      final url = 'http://$host:$serverPort/download?path=${shareData.path}';
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfrxReader(
              isOffline: false,
              onlineUrl: url,
              pdfFile: PdfFileModel(
                title: shareData.name,
                path: '',
                size: 0,
                date: 0,
              ),
              pdfConfig: PdfConfigModel(),
            ),
          ));
      return;
    }
    //show dialog
    showDialog(
      context: context,
      builder: (context) => ShareDataOpenDialog(
        context: context,
        shareData: shareData,
        onCancel: () {},
        onSubmit: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // final coverUrl =
    //     '${widget.apiUrl}/download?path=${widget.novel.path}/cover.png';
    bool isShowAllDownloadBtn = filterOptionGroupValue == 'all';
    return MyScaffold(
      appBar: AppBar(
        title: Text(widget.novel.title),
      ),
      body: isLoading
          ? Center(child: TLoader())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Text('All'),
                      Radio(
                        value: 'all',
                        groupValue: filterOptionGroupValue,
                        onChanged: (value) {
                          setState(() {
                            filterOptionGroupValue = value!;
                          });
                          _filterChange(value!);
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text('PDF'),
                      Radio(
                        value: 'pdf',
                        groupValue: filterOptionGroupValue,
                        onChanged: (value) {
                          setState(() {
                            filterOptionGroupValue = value!;
                          });
                          _filterChange(value!);
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text('Chapter'),
                      Radio(
                        value: 'chapter',
                        groupValue: filterOptionGroupValue,
                        onChanged: (value) {
                          setState(() {
                            filterOptionGroupValue = value!;
                          });
                          _filterChange(value!);
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text('Config Files'),
                      Radio(
                        value: 'config',
                        groupValue: filterOptionGroupValue,
                        onChanged: (value) {
                          setState(() {
                            filterOptionGroupValue = value!;
                          });
                          _filterChange(value!);
                        },
                      ),
                      const SizedBox(width: 10),
                      const Text('Cover Files'),
                      Radio(
                        value: 'cover',
                        groupValue: filterOptionGroupValue,
                        onChanged: (value) {
                          setState(() {
                            filterOptionGroupValue = value!;
                          });
                          _filterChange(value!);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(),
                //download all Download
                isShowAllDownloadBtn
                    ? ListTile(
                        onTap: _allDownload,
                        leading: const Icon(Icons.download),
                        title: const Text('All Download'),
                      )
                    : Container(),
                isShowAllDownloadBtn ? const Divider() : Container(),
                //list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 800));
                      init();
                    },
                    child: ShareDataListView(
                      shareDataList: dataList,
                      onDownloadClick: _download,
                      onClick: _openFileDialog,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
