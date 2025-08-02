import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/dialogs/index.dart';
import 'package:t_widgets/functions/index.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';

import '../general_server/index.dart';
import 'android_app_services.dart';
import 'app_config_model.dart';
import 'app_notifier.dart';
import 'app_path_services.dart';
import 'constants.dart';
import 'setting.dart';
import 'theme_component.dart';

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
  late AppConfigModel config;
  final customPathTextController = TextEditingController();
  final forwardProxyController = TextEditingController();

  void init() async {
    customPathTextController.text = '${getAppExternalRootPath()}/.$appName';
    config = appConfigNotifier.value;
    forwardProxyController.text = config.forwardProxyUrl;
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
      //set custom path
      config.customPath = customPathTextController.text;

      //save
      config.save();
      if (config.isUseCustomPath) {
        //change
        appRootPathNotifier.value = config.customPath;
      }
      //init config
      await Setting.initAppConfigService();
      //init

      if (!mounted) return;
      // showMessage(context, 'Config ကိုသိမ်းဆည်းပြီးပါပြီ');
      setState(() {
        isChanged = false;
      });
      showTSnackBar(context, 'Config Saved');
      // Navigator.pop(context);
    } catch (e) {
      debugPrint('saveConfig: ${e.toString()}');
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isChanged,
      onPopInvokedWithResult: (didPop, result) {
        _onBackpress();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Setting')),
        body: ListView(
          children: [
            // theme
            ThemeComponent(),
            //custom path
            TListTileWithDesc(
              title: "custom path",
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
            TListTileWithDesc(
              title: 'Custom Proxy Server',
              trailing: Switch.adaptive(
                value: config.isUseProxyServer,
                onChanged: (value) {
                  setState(() {
                    config.isUseProxyServer = value;
                    isChanged = true;
                  });
                },
              ),
            ),
            config.isUseProxyServer
                ? ForwardProxyTTextField(
                    controller: forwardProxyController,
                    onChanged: (value) {
                      config.forwardProxyUrl = value;
                      isChanged = true;
                      setState(() {
                        
                      });
                    },
                  )
                : SizedBox.shrink(),
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
