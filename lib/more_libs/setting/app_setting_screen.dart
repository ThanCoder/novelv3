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

  bool isChanged = false;
  bool isCustomPathTextControllerTextSelected = false;
  late AppConfig config;
  final customPathTextController = TextEditingController();
  final forwardProxyController = TextEditingController();
  final proxyController = TextEditingController();
  final customServerPathController = TextEditingController();

  void init() async {
    customPathTextController.text =
        '${Setting.appExternalPath}/.${Setting.instance.packageName}';
    config = Setting.getAppConfig;
    forwardProxyController.text = config.forwardProxyUrl;
    proxyController.text = config.proxyUrl;
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
              Setting.getThemeModeChooser,
              //custom path
              _getCustomPath(),
              _getProxy(),
              //proxy server
              _getForwardProxy(),
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

  Widget _getCustomPath() {
    return Card(
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text("Config Custom Path"),
            subtitle: Text("သင်ကြိုက်နှစ်သက်တဲ့ path ကို ထည့်ပေးပါ"),
            value: config.isUseCustomPath,
            onChanged: (value) {
              setState(() {
                config.isUseCustomPath = value;
                isChanged = true;
              });
            },
          ),
          !config.isUseCustomPath
              ? SizedBox.shrink()
              : TListTileWithDescWidget(
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
                ),
        ],
      ),
    );
  }

  Widget _getForwardProxy() {
    return Card(
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text('Forward Proxy Server'),
            value: config.isUseForwardProxy,
            onChanged: (value) {
              setState(() {
                config.isUseForwardProxy = value;
                if (value) {
                  config.isUseProxy = false;
                }
                isChanged = true;
              });
            },
          ),
          !config.isUseForwardProxy
              ? SizedBox.shrink()
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TTextField(
                      controller: forwardProxyController,
                      label: Text('Forward Proxy'),
                      onChanged: (value) {
                        if (!isChanged) {
                          isChanged = true;
                        }
                        setState(() {
                          config.forwardProxyUrl = value;
                        });
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _getProxy() {
    return Card(
      child: Column(
        children: [
          SwitchListTile.adaptive(
            title: Text('Proxy Server'),
            value: config.isUseProxy,
            onChanged: (value) {
              isChanged = true;
              config.isUseProxy = value;
              if (value) {
                config.isUseForwardProxy = false;
              }
              setState(() {});
            },
          ),
          !config.isUseProxy
              ? SizedBox.shrink()
              : Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TTextField(
                      controller: proxyController,
                      label: Text('Proxy Server'),
                      onChanged: (value) {
                        if (!isChanged) {
                          isChanged = true;
                        }
                        setState(() {
                          config.proxyUrl = value;
                        });
                      },
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _saveConfig() async {
    try {
      if (Platform.isAndroid && config.isUseCustomPath) {
        if (!await ThanPkg.platform.isStoragePermissionGranted()) {
          if (mounted) {
            await ThanPkg.platform.requestStoragePermission();
          }
          return;
        }
      }

      //set custom path
      config.customPath = customPathTextController.text;
      //save
      await config.save();

      if (!mounted) return;
      setState(() {
        isChanged = false;
      });
      Setting.instance.onSettingSaved?.call(context, 'Config Saved');
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
