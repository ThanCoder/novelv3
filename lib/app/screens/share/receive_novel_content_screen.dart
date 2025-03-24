import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/share_data_list_view.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/dialogs/download_dialog.dart';
import 'package:novel_v3/app/dialogs/download_progress_dialog.dart';
import 'package:novel_v3/app/dialogs/share_data_open_dialog.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/pdf_readers/pdfrx_reader.dart';
import 'package:novel_v3/app/services/novel_isolate_services.dart';
import 'package:novel_v3/app/services/core/recent_db_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';

import '../../widgets/index.dart';

class ReceiveNovelContentScreen extends StatefulWidget {
  String apiUrl;
  NovelModel novel;
  ReceiveNovelContentScreen({
    super.key,
    required this.apiUrl,
    required this.novel,
  });

  @override
  State<ReceiveNovelContentScreen> createState() =>
      _ReceiveNovelContentScreenState();
}

class _ReceiveNovelContentScreenState extends State<ReceiveNovelContentScreen> {
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
        List<dynamic> list = [];
        try {
          list = jsonDecode(res.data);
        } catch (e) {
          if (!mounted) return;
          showDialogMessage(context, 'jsonDecode: ${e.toString()}');
        }

        //all data
        allDataList = list.map((map) => ShareDataModel.fromMap(map)).toList();
        //sort
        allDataList.sort((a, b) {
          return a.name.compareTo(b.name);
        });

        setState(() {
          dataList = allDataList;
          isLoading = false;
        });

        //check exits
        _checkExistsFiles();
        _filterChange(filterOptionGroupValue);
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkExistsFiles() {
    //check exists
    final novelDir =
        Directory('${PathUtil.instance.getSourcePath()}/${widget.novel.title}');
    if (novelDir.existsSync()) {
      final list = dataList.map((data) {
        final file = File('${novelDir.path}/${data.name}');
        data.isExists = file.existsSync();
        // print('${data.name} - ${data.isExists} - ${file.path}');
        return data;
      }).toList();
      setState(() {
        dataList = list;
      });
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
        var list =
            allDataList.where((data) => data.name.endsWith('.pdf')).toList();
        setState(() {
          dataList = list;
        });
        break;
      case 'chapter':
        var list = allDataList
            .where((data) => int.tryParse(data.name) != null)
            .toList();
        setState(() {
          dataList = list;
        });
        break;
      case 'config':
        var list = allDataList.where((data) {
          return !data.name.endsWith('.pdf') &&
              !data.name.endsWith('.png') &&
              int.tryParse(data.name) == null;
        }).toList();
        setState(() {
          dataList = list;
        });
        break;
      case 'cover':
        var list =
            allDataList.where((data) => data.name.endsWith('.png')).toList();
        setState(() {
          dataList = list;
        });
        break;
    }
    _checkExistsFiles();
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
          '${PathUtil.instance.createDir('${PathUtil.instance.getSourcePath()}/${widget.novel.title}')}/${shareData.name}';
      showDialog(
        context: context,
        builder: (ctx) => DownloadDialog(
          title: 'Downloader',
          url: urlPath,
          saveFullPath: savePath,
          message: shareData.name,
          onError: (msg) {
            debugPrint(msg);
            showMessage(ctx, msg);
          },
          onSuccess: () {
            showMessage(ctx, 'Downloaded');
            //novel data ရှိမရှိ စစ်ဆေးခြင်း
            _checkExistsFiles();
            _refreshNovelList();
          },
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _allDownload() async {
    final saveDirPath = PathUtil.instance.createDir(
        '${PathUtil.instance.getSourcePath()}/${widget.novel.title}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => DownloadProgressDialog(
        pathUrlList: allDataList.map((data) => data.path).toList(),
        saveDirPath: saveDirPath,
        onSuccess: () {
          showMessage(ctx, 'Download လုပ်ပြီးပါပြီ');
          //novel data ရှိမရှိ စစ်ဆေးခြင်း
          _checkExistsFiles();
          _refreshNovelList();
        },
        onCancaled: () {
          showMessage(ctx, 'Cancel လိုက်ပါပြီ');
          //novel data ရှိမရှိ စစ်ဆေးခြင်း
          _checkExistsFiles();
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
              title: shareData.name,
              sourcePath: url,
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

  void _showMenu(ShareDataModel shareData) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 250),
        child: ListView(
          children: [
            ListTile(
              iconColor: dangerColor,
              textColor: dangerColor,
              leading: const Icon(Icons.delete_forever),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _delete(shareData);
              },
            )
          ],
        ),
      ),
    );
  }

  void _delete(ShareDataModel shareData) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`${shareData.name}` ဖျက်ချင်တာ သေချာပြီလား?',
        onCancel: () {},
        onSubmit: () async {
          try {
            final url =
                'http://${widget.apiUrl}/delete?path=${widget.novel.path}/${shareData.name}';

            debugPrint('deleting');
            setState(() {
              isLoading = true;
            });
            await dio.delete(url);

            debugPrint('deleted');

            //remove ui
            final res =
                dataList.where((dt) => dt.name != shareData.name).toList();
            setState(() {
              isLoading = false;
              dataList = res;
            });
          } catch (e) {
            debugPrint(e.toString());
            setState(() {
              isLoading = false;
            });
          }
        },
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
                      onLongClick: _showMenu,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
