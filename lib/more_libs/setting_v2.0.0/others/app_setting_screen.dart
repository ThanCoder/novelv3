import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../setting.dart';

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

  bool isChanged = false;
  bool isCustomPathTextControllerTextSelected = false;
  late AppConfig config;
  final customPathTextController = TextEditingController();
  final forwardProxyController = TextEditingController();
  final customServerPathController = TextEditingController();

  void init() async {
    customPathTextController.text =
        '${Setting.appExternalPath}/.${Setting.instance.appName}';
    config = appConfigNotifier.value;
    forwardProxyController.text = config.forwardProxyUrl;
    if (config.customPath.isNotEmpty) {
      customPathTextController.text = config.customPath;
    }
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
              ThemeComponent(),
              //custom path
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
              //proxy server
              // TListTileWithDesc(
              //   title: 'Custom Proxy Server',
              //   trailing: Switch.adaptive(
              //     value: config.isUseProxyServer,
              //     onChanged: (value) {
              //       setState(() {
              //         config.isUseProxyServer = value;
              //         isChanged = true;
              //       });
              //     },
              //   ),
              // ),
              // config.isUseProxyServer
              //     ? ForwardProxyTTextField(
              //         controller: forwardProxyController,
              //         onChanged: (value) {
              //           config.forwardProxyUrl = value;
              //           isChanged = true;
              //           setState(() {});
              //         },
              //       )
              //     : SizedBox.shrink(),
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
}
