import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:provider/provider.dart';

import '../widgets/index.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isChanged = false;
  late AppConfigModel config;
  bool isUsedCustomPath = false;
  bool isDarkTheme = false;
  bool isShowNovelContentCover = false;
  TextEditingController customPathTextController = TextEditingController();

  void init() async {
    customPathTextController.text = '${getAppExternalRootPath()}/.$appName';
    config = appConfigNotifier.value;
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

      if (!mounted) return;
      showMessage(context, 'Config ကိုသိမ်းဆည်းပြီးပါပြီ');
      setState(() {
        isChanged = false;
      });
      context.read<NovelProvider>().initList(isReset: true);
      Navigator.pop(context);
    } catch (e) {
      debugPrint('saveConfig: ${e.toString()}');
    }
  }

  Future<bool> _onBackpress() async {
    if (!isChanged) {
      return true;
    }

    return await showDialog(
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
    return WillPopScope(
      onWillPop: () async {
        return await _onBackpress();
      },
      child: MyScaffold(
        appBar: AppBar(
          title: const Text('Setting'),
        ),
        body: ListView(
          children: [
            //custom path
            ListTileWithDesc(
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
                : Container(),
            //content image cover
            ListTileWithDesc(
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
            //
          ],
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
