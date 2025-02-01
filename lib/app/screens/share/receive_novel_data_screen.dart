import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/novel_list_view.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/custom_class/novel_search_delegate.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/screens/share/share_novel_content_screen.dart';
import 'package:novel_v3/app/services/recent_db_services.dart';
import 'package:novel_v3/app/services/wifi_services.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';
import 'package:novel_v3/app/widgets/t_text_field.dart';
import 'package:than_pkg/than_pkg_method_channel.dart';

class ReceiveNovelDataScreen extends StatefulWidget {
  const ReceiveNovelDataScreen({super.key});

  @override
  State<ReceiveNovelDataScreen> createState() => _ReceiveNovelDataScreenState();
}

class _ReceiveNovelDataScreenState extends State<ReceiveNovelDataScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  final dio = Dio();
  TextEditingController hostAddressController = TextEditingController();
  TextEditingController portController = TextEditingController();
  bool isError = false;
  bool isLoading = false;
  bool isChanged = false;
  List<NovelModel> novelList = [];

  Future<String> _getPlatformWifiAddress() async {
    var address = await getWifiAddress();
    //android address
    if (Platform.isAndroid) {
      final res = await ThanPkgMethodChannel.instance.getLocalIpAddress();
      if (res != null) {
        address = res;
      }
    }
    return address;
  }

  void init() async {
    try {
      final url = 'http://${await _getPlatformWifiAddress()}';
      hostAddressController.text = url;
      portController.text = serverPort.toString();

      //recent
      final recentUrl = getRecentDB<String>('server_address');
      if (recentUrl != null && recentUrl.isNotEmpty) {
        hostAddressController.text = recentUrl;
      }
      fetch();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetch() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res =
          await dio.get('${hostAddressController.text}:${portController.text}');

      if (res.statusCode == 200) {
        //success
        final List<dynamic> list = res.data;
        setState(() {
          novelList = list.map((map) {
            final novel = NovelModel.fromMap(map);
            novel.coverUrl =
                '${hostAddressController.text}:${portController.text}/download?path=${novel.coverPath}';
            return novel;
          }).toList();
          //state
          isLoading = false;
          isError = false;
          isChanged = false;
        });
        //set recent
        if (hostAddressController.text.isNotEmpty) {
          setRecentDB('server_address', hostAddressController.text);
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      showDialogMessage(context,
          'error ရှိနေပါတယ်!။\nhost address ကိုစစ်ဆေးပေးပါ!။\n"${hostAddressController.text}" address ကိုလိုအပ်ရင် ပြင်ဆင်ပေးပါ!။');
      setState(() {
        isError = true;
        isLoading = false;
      });
      setRecentDB('server_address', '');
    }
  }

  void _goContentScreen(NovelModel novel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShareNovelContentScreen(
          apiUrl: '${hostAddressController.text}:${portController.text}',
          novel: novel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text("Novel Data လက်ခံခြင်း"),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: NovelSearchDelegate(
                  novelList: novelList,
                  isOnlineCover: true,
                  onClick: _goContentScreen,
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: TLoader())
          : isError
              ? Center(
                  child: Column(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TTextField(
                        controller: portController,
                        label: const Text('PORT'),
                        textInputType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (value) {
                          if (!isChanged) {
                            setState(() {
                              isChanged = true;
                            });
                          }
                        },
                      ),
                      TTextField(
                        controller: hostAddressController,
                        label: const Text('Host Address'),
                        onChanged: (value) {
                          if (!isChanged) {
                            setState(() {
                              isChanged = true;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    // await Future.delayed(const Duration(milliseconds: 500));
                    await fetch();
                  },
                  child: NovelListView(
                    novelList: novelList,
                    isOnlineCover: true,
                    onClick: _goContentScreen,
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isChanged) {
            fetch();
            setState(() {
              isChanged = false;
            });
          } else {
            if (isError) {
              final url = 'http://${await _getPlatformWifiAddress()}';
              hostAddressController.text = url;
              portController.text = serverPort.toString();
            }
            fetch();
          }
        },
        child: Icon(isChanged ? Icons.save : Icons.refresh),
      ),
    );
  }
}
