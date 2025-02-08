import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/novel_data_list_view.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/dialogs/import_novel_data_dialog.dart';
import 'package:novel_v3/app/models/novel_data_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/services/android_app_services.dart';
import 'package:novel_v3/app/services/novel_data_services.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';

class NovelDataScannerScreen extends StatefulWidget {
  const NovelDataScannerScreen({super.key});

  @override
  State<NovelDataScannerScreen> createState() => _NovelDataScannerScreenState();
}

class _NovelDataScannerScreenState extends State<NovelDataScannerScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isLoading = false;
  late NovelDataModel currentNovelData;
  String progressText = '';
  int max = 0;
  int progress = 0;

  void init() async {
    if (!await checkStoragePermission()) {
      if (mounted) {
        showConfirmStoragePermissionDialog(context);
      }
      return;
    }
    setState(() {
      isLoading = true;
    });

    novelDataScannerIsolate(
      onSuccess: (novelDataList) {
        //gen cover
        genNovelDataCoverIsolate(
          novelDataList: novelDataList,
          outDir: getCachePath(),
          onSuccess: (_novelDataList) {
            //novel data file က NOVEL APP ထဲမှာ ရှိလားစစ်မယ်
            _novelDataList = _novelDataList.map((n) {
              final novelDir = Directory('${getSourcePath()}/${n.title}');
              n.isAlreadyExists = novelDir.existsSync();

              return n;
            }).toList();
            //SUCCESS
            setState(() {
              isLoading = false;
            });
            novelDataListNotifier.value = _novelDataList;
          },
          onError: (err) {
            setState(() {
              isLoading = false;
            });
            showMessage(context, err);
          },
        );
      },
      onError: (msg) {
        setState(() {
          isLoading = false;
        });
        showMessage(context, msg);
      },
    );
  }

  void installDataConfirm() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText:
            'Data ရှိနေပြီးသားဖြစ်နေပါတယ်။ထည့်သွင်းချင်ပါသလား?။\nသွင်းလိုက်မယ်ဆိုရင် data အဟောင်းတွေကို override လုပ်သွားပါမယ်။',
        cancelText: 'မလုပ်ဘူး',
        submitText: 'လုပ်မယ်',
        onCancel: () {},
        onSubmit: () {
          installData();
        },
      ),
    );
  }

  void installData() {
    try {
      showDialog(
        context: context,
        builder: (context) => ImportNovelDataDialog(
          dialogContext: context,
          dataFilePath: currentNovelData.path,
          onCompleted: () {
            init();
          },
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void deleteData() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
        cancelText: 'မလုပ်ဘူး',
        submitText: 'ဖျက်မယ်',
        onCancel: () {},
        onSubmit: () async {
          try {
            final file = File(currentNovelData.path);
            if (file.existsSync()) {
              file.deleteSync();
            }
            //remove ui
            var dataList = novelDataListNotifier.value;
            dataList = dataList
                .where((data) => data.title != currentNovelData.title)
                .toList();
            novelDataListNotifier.value = dataList;
          } catch (e) {
            debugPrint(e.toString());
          }
        },
      ),
    );
  }

  void showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => BottomSheet(
        onClosing: () {},
        builder: (context) => SizedBox(
          height: 200,
          child: ListView(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(currentNovelData.title),
                ),
              ),
              const Divider(),
              //install
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  if (currentNovelData.isAlreadyExists) {
                    installDataConfirm();
                  } else {
                    installData();
                  }
                },
                leading: Icon(
                  Platform.isAndroid
                      ? Icons.install_mobile
                      : Icons.install_desktop,
                ),
                title: const Text('Install Data'),
              ),
              ListTile(
                iconColor: Colors.red,
                textColor: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  deleteData();
                },
                leading: const Icon(Icons.delete_forever),
                title: const Text('Delete Data'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Novel Data Scanner'),
        actions: [
          Platform.isLinux
              ? IconButton(
                  onPressed: () {
                    init();
                  },
                  icon: const Icon(Icons.refresh),
                )
              : Container(),
        ],
      ),
      body: isLoading
          ? Center(
              child: TLoader(),
            )
          : ValueListenableBuilder(
              valueListenable: novelDataListNotifier,
              builder: (context, value, child) {
                if (value.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Novel Data List မရှိပါ...'),
                        IconButton(
                          onPressed: () {
                            init();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            size: 30,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(milliseconds: 800));
                      init();
                    },
                    child: NovelDataListView(
                      novelDataList: value,
                      onClick: (novelData) {
                        currentNovelData = novelData;
                        showMenu();
                      },
                    ),
                  );
                }
              },
            ),
    );
  }
}
