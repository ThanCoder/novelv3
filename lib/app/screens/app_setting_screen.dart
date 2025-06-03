import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/index.dart';
import 'package:novel_v3/my_libs/general_server/proxy_hosting_server/index.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:t_widgets/t_widgets.dart';

class AppSettingScreen extends StatefulWidget {
  const AppSettingScreen({super.key});

  @override
  State<AppSettingScreen> createState() => _AppSettingScreenState();
}

class _AppSettingScreenState extends State<AppSettingScreen> {
  late AppConfigModel config;

  @override
  void initState() {
    config = appConfigNotifier.value;
    super.initState();
    init();
  }

  bool isChanged = false;

  bool isUsedCustomPath = false;
  bool isDarkTheme = false;
  bool isShowNovelContentCover = false;
  TextEditingController customPathTextController = TextEditingController();
  TextEditingController forwardProxyController = TextEditingController();
  TextEditingController browserProxyController = TextEditingController();

  void init() async {
    customPathTextController.text = '${getAppExternalRootPath()}/.$appName';
    forwardProxyController.text = config.forwardProxy;
    browserProxyController.text = config.browserProxy;
    setState(() {
      isUsedCustomPath = config.isUseCustomPath;
      customPathTextController.text = config.customPath.isEmpty
          ? '${getAppExternalRootPath()}/.$appName'
          : config.customPath;
      isDarkTheme = config.isDarkTheme;
      isShowNovelContentCover = config.isShowNovelContentBgImage;
    });
  }

  void _saveConfig() async {
    try {
      if (Platform.isAndroid && isUsedCustomPath) {
        if (!await checkStoragePermission()) {
          if (mounted) {
            showConfirmStoragePermissionDialog(context);
          }
          return;
        }
      }
      //reset
      config.customPath = customPathTextController.text;
      config.forwardProxy = forwardProxyController.text;
      config.browserProxy = browserProxyController.text;
      config.isUseCustomPath = isUsedCustomPath;
      config.isDarkTheme = isDarkTheme;
      config.isShowNovelContentBgImage = isShowNovelContentCover;
      //save
      setConfigFile(config);
      appConfigNotifier.value = config;
      if (isUsedCustomPath) {
        //change
        appRootPathNotifier.value = config.customPath;
      }
      //init config
      await initAppConfigService();
      //init
      // context.read<NovelProvider>().listClear();
      // context.read<ChapterProvider>().listClear();
      if (!mounted) return;
      showMessage(context, 'Config ကိုသိမ်းဆည်းပြီးပါပြီ');
      setState(() {
        isChanged = false;
      });

      Navigator.pop(context);
    } catch (e) {
      // debugPrint('saveConfig: ${e.toString()}');
      if (!mounted) return;
      showDialogMessage(context, e.toString());
    }
  }

  void _onBackpress() async {
    if (!isChanged) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: 'setting ကိုသိမ်းဆည်းထားချင်ပါသလား?',
        cancelText: 'မသိမ်းဘူး',
        submitText: 'သိမ်းမယ်',
        onCancel: () {},
        onSubmit: () {
          _saveConfig();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isChanged,
      onPopInvokedWithResult: (didPop, result) {
        _onBackpress();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Setting'),
        ),
        body: SingleChildScrollView(
          child: Column(
            spacing: 7,
            children: [
              //custom path
              TListTileWithDesc(
                title: "custom path",
                desc: "သင်ကြိုက်နှစ်သက်တဲ့ path ကို ထည့်ပေးပါ",
                trailing: Checkbox(
                  value: isUsedCustomPath,
                  onChanged: (value) {
                    setState(() {
                      isUsedCustomPath = value!;
                      isChanged = true;
                    });
                  },
                ),
              ),
              isUsedCustomPath
                  ? _MyListTile2(
                      widget1: TextField(
                        controller: customPathTextController,
                      ),
                      widget2: IconButton(
                        onPressed: () {
                          _saveConfig();
                        },
                        icon: const Icon(
                          Icons.save,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              //content image cover
              TListTileWithDesc(
                title: 'Novel Content Backgorund Cover',
                trailing: Checkbox(
                  value: isShowNovelContentCover,
                  onChanged: (value) {
                    setState(() {
                      isShowNovelContentCover = value!;
                      isChanged = true;
                    });
                  },
                ),
              ),
              const Divider(),
              //forward proxy server
              ForwardProxyTTextField(
                controller: forwardProxyController,
                onChanged: (value) {
                  setState(() {
                    isChanged = true;
                  });
                },
              ),
              //browser proxy server
              BrowserProxyTTextField(
                controller: browserProxyController,
                onChanged: (value) {
                  setState(() {
                    isChanged = true;
                  });
                },
              ),
            ],
          ),
        ),
        floatingActionButton: isChanged
            ? FloatingActionButton(
                onPressed: () {
                  _saveConfig();
                },
                child: const Icon(Icons.save),
              )
            : null,
      ),
    );
  }
}

class _MyListTile2 extends StatelessWidget {
  Widget widget1;
  Widget widget2;
  String? desc;
  _MyListTile2({
    required this.widget1,
    required this.widget2,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget1,
                  desc != null ? const SizedBox(height: 5) : Container(),
                  desc != null
                      ? Text(
                          desc ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            widget2,
          ],
        ),
      ),
    );
  }
}
