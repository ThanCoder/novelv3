import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/models/app_config_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/services/android_app_services.dart';
import 'package:novel_v3/app/services/app_config_services.dart';
import 'package:novel_v3/app/services/app_path_services.dart';
import 'package:novel_v3/app/services/novel_isolate_services.dart';
import 'package:novel_v3/app/utils/config_util.dart';
import 'package:novel_v3/app/widgets/list_tile_with_desc.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';

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
  late AppConfigModel configFile;
  bool isUsedCustomPath = false;
  bool isDarkTheme = false;
  bool isShowNovelContentCover = false;
  TextEditingController customPathTextController = TextEditingController();

  void init() async {
    customPathTextController.text = '${getAppExternalRootPath()}/.$appName';
    configFile = appConfigNotifier.value;
    setState(() {
      isUsedCustomPath = configFile.isUseCustomPath;
      customPathTextController.text = configFile.customPath.isEmpty
          ? '${getAppExternalRootPath()}/.$appName'
          : configFile.customPath;
      isDarkTheme = configFile.isDarkTheme;
      isShowNovelContentCover = configFile.isShowNovelContentBgImage;
    });
  }

  void _saveConfig() async {
    try {
      if (Platform.isAndroid) {
        if (!await checkStoragePermission()) {
          if (mounted) {
            showConfirmStoragePermissionDialog(context);
          }
          return;
        }
      }
      //reset
      configFile.customPath = customPathTextController.text;
      configFile.isUseCustomPath = isUsedCustomPath;
      configFile.isDarkTheme = isDarkTheme;
      configFile.isShowNovelContentBgImage = isShowNovelContentCover;
      //save
      setConfigFile(configFile);
      appConfigNotifier.value = configFile;
      if (isUsedCustomPath) {
        //change
        appRootPathNotifier.value = configFile.customPath;
      }
      //init config
      await initConfig();
      //init
      final novelList = await getNovelListFromPathIsolate();
      novelListNotifier.value = novelList;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Config ကိုသိမ်းဆည်းပြီးပါပြီ')));
      setState(() {
        isChanged = false;
      });
    } catch (e) {
      debugPrint('saveConfig: ${e.toString()}');
    }
  }

  Future<bool> _onBackpress() async {
    return await showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        dialogContext: context,
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
        if (isChanged) {
          return await _onBackpress();
        }
        return true;
      },
      child: MyScaffold(
        appBar: AppBar(title: const Text('Setting')),
        body: ListView(
          children: [
            //theme mode
            ListTileWithDesc(
              title: 'Dark Mode',
              widget: Checkbox(
                value: isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    isDarkTheme = value!;
                    _saveConfig();
                  });
                  isDarkThemeNotifier.value = value!;
                },
              ),
            ),
            //custom path
            ListTileWithDesc(
              title: "custom path",
              desc: "သင်ကြိုက်နှစ်သက်တဲ့ path ကို ထည့်ပေးပါ",
              widget: Checkbox(
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
              widget: Checkbox(
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
