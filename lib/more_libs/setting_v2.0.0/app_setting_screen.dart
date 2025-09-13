import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import 'setting.dart';
import 'app_config.dart';

class AppSettingScreen extends StatefulWidget {
  const AppSettingScreen({super.key});

  @override
  State<AppSettingScreen> createState() => _AppSettingScreenState();
}

class _AppSettingScreenState extends State<AppSettingScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  final customPathTextController = TextEditingController();
  final forwardProxyController = TextEditingController();
  final customServerPathController = TextEditingController();
  final customContentImageCoverPathController = TextEditingController();
  bool isChanged = false;
  bool isCustomPathTextControllerTextSelected = false;
  late AppConfig config;

  void init() async {
    customPathTextController.text =
        '${Setting.appExternalPath}/.${Setting.instance.appName}';
    config = appConfigNotifier.value;
    forwardProxyController.text = config.forwardProxyUrl;
    if (config.customPath.isNotEmpty) {
      customPathTextController.text = config.customPath;
    }
    customContentImageCoverPathController.text =
        config.customNovelContentImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isChanged,
      onPopInvokedWithResult: (didPop, result) {
        _onBackpress();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Setting')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // theme
              // ThemeComponent(),
              ThemeModesChooser(),
              //custom path
              _getCustomPathWidget(),
              // custom image
              _getCustomNovelCoverWidet(),
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

  Widget _getCustomPathWidget() {
    return Column(
      children: [
        TListTileWithDesc(
          title: "Config Custom Path",
          desc: "သင်ကြိုက်နှစ်သက်တဲ့ path ကို ထည့်ပေးပါ",
          trailing: Checkbox(
            value: config.isUseCustomPath,
            onChanged: (value) {
              setState(() {
                config.isUseCustomPath = value!;
                isChanged = true;
              });
            },
          ),
        ),
        config.isUseCustomPath
            ? TListTileWithDescWidget(
                widget1: TextField(
                  controller: customPathTextController,
                  onTap: () {
                    if (!isCustomPathTextControllerTextSelected) {
                      customPathTextController.selectAll();
                      isCustomPathTextControllerTextSelected = true;
                    }
                  },
                  onTapOutside: (event) {
                    isCustomPathTextControllerTextSelected = false;
                  },
                ),
                widget2: IconButton(
                  onPressed: () {
                    _saveConfig();
                  },
                  icon: const Icon(Icons.save),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Widget _getCustomNovelCoverWidet() {
    return TListTileWithDescWidget(
      spacing: 15,
      widget1: TTextField(
        label: Text('Custom Novel Content Image Cover Path'),
        controller: customContentImageCoverPathController,
        maxLines: 1,
        isSelectedAll: true,
        onChanged: (value) {
          config.customNovelContentImagePath = value;
          setState(() {
            isChanged = true;
          });
        },
      ),
      widget2: Icon(
        color: isExistsCustomContentImageCoverPath ? Colors.green : Colors.red,
        isExistsCustomContentImageCoverPath ? Icons.check : Icons.close,
      ),
    );
  }

  void _saveConfig() async {
    try {
      if (Platform.isAndroid && config.isUseCustomPath) {
        if (!await checkStoragePermission()) {
          if (mounted) {
            showConfirmStoragePermissionDialog(context);
          }
          return;
        }
      }
      final oldPath = config.customPath;

      //set custom path
      config.customPath = customPathTextController.text;
      //save
      await config.save();

      if (!mounted) return;
      setState(() {
        isChanged = false;
      });
      Setting.instance.showMessage(context, 'Config Saved');
      // custome path ပြောင်လဲလား စစ်ဆေးမယ်
      if (oldPath != customPathTextController.text) {
        // app refresh
        Setting.restartApp(context);
      }
    } catch (e) {
      Setting.showDebugLog(e.toString(), tag: 'AppSettingScreen:_saveConfig');
    }
  }

  void _onBackpress() {
    if (!isChanged) {
      return;
    }
    showDialog(
      context: context,
      builder: (context) => TConfirmDialog(
        contentText: 'setting ကိုသိမ်းဆည်းထားချင်ပါသလား?',
        cancelText: 'မသိမ်းဘူး',
        submitText: 'သိမ်းမယ်',
        onCancel: () {
          isChanged = false;
          Navigator.pop(context);
        },
        onSubmit: () {
          _saveConfig();
        },
      ),
    );
  }

  // get
  bool get isExistsCustomContentImageCoverPath {
    final file = File(customContentImageCoverPathController.text);
    return file.existsSync();
  }
}
