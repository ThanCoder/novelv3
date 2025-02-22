import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/novel_list_view.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/customs/novel_search_delegate.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/screens/share/share_novel_content_screen.dart';
import 'package:novel_v3/app/services/core/recent_db_services.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../widgets/index.dart';

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

  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  TextEditingController hostAddressController = TextEditingController();
  TextEditingController portController = TextEditingController();
  bool isError = false;
  bool isLoading = false;
  bool isChanged = false;
  List<NovelModel> novelList = [];
  List<String> wifiList = [];

  Future<String> _getPlatformWifiAddress() async {
    final address = await ThanPkg.platform.getWifiAddressList();
    if (address.isEmpty) return '192.168.';
    return address.first;
  }

  void init() async {
    try {
      final url = await _getPlatformWifiAddress();
      hostAddressController.text = url;
      portController.text = serverPort.toString();

      //list
      final list = await ThanPkg.platform.getWifiAddressList();
      setState(() {
        wifiList = list;
      });

      //recent
      final hostAddress = getRecentDB<String>('server_address');
      if (hostAddress != null && hostAddress.isNotEmpty) {
        hostAddressController.text = hostAddress;
        wififHostAddressNotifier.value = hostAddress;
      }
      fetch();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> fetch() async {
    try {
      setState(() {
        isChanged = false;
        isLoading = true;
      });
      final res = await dio
          .get('http://${hostAddressController.text}:${portController.text}');

      if (res.statusCode == 200) {
        //success
        final List<dynamic> list = res.data;
        setState(() {
          novelList = list.map((map) {
            final novel = NovelModel.fromMap(map);
            novel.coverUrl =
                'http://${hostAddressController.text}:${portController.text}/download?path=${novel.coverPath}';
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
          wififHostAddressNotifier.value = hostAddressController.text;
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

  Widget _getWifiListWidget() {
    if (wifiList.isEmpty) {
      return Container();
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: wifiList.length,
      itemBuilder: (context, index) => Center(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              hostAddressController.text = wifiList[index].toString();
            },
            child: Text(
              wifiList[index],
              style: TextStyle(
                color: Colors.teal[900],
              ),
            ),
          ),
        ),
      ),
      separatorBuilder: (context, index) => const Divider(),
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
                      wifiList.isNotEmpty
                          ? const Text('Active Wifi List')
                          : Container(),
                      wifiList.isNotEmpty ? const Divider() : Container(),
                      //wifi list
                      _getWifiListWidget(),
                      const Divider(),
                      //host
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
                      //address
                      TTextField(
                        controller: hostAddressController,
                        textInputType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^[0-9.]+$'),
                          ),
                        ],
                        label: const Text('Host Address'),
                        onChanged: (value) {
                          if (!isChanged) {
                            setState(() {
                              isChanged = true;
                            });
                          }
                        },
                        onSubmitted: (value) {
                          fetch();
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
          } else {
            if (isError) {
              final url = await _getPlatformWifiAddress();
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
