import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/app/share/libs/novel_share_services.dart';
import 'package:novel_v3/app/share/libs/share_dir_file.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/index.dart';
import 'package:t_server/t_server.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/index.dart';

class NovelShareScreen extends StatefulWidget {
  const NovelShareScreen({super.key});

  @override
  State<NovelShareScreen> createState() => _NovelShareScreenState();
}

class _NovelShareScreenState extends State<NovelShareScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  List<String> wifiList = [];
  static List<Novel> novelList = [];

  void init() async {
    _initWifiList();
    TServer.instance.get('/download', (req) {
      final path = req.getQueryParameters['path'] ?? '';
      req.sendFile(path);
    });

    TServer.instance.get('/dir', (req) {
      final path = req.getQueryParameters['path'] ?? '';
      req.sendHtml(NovelShareServices.getDirListHtml(_getAllDirFiles(path)));
    });
    TServer.instance.get('/dir/api', (req) {
      final path = req.getQueryParameters['path'] ?? '';
      req.sendJson(NovelShareServices.getDirJson(_getAllDirFiles(path)));
    });
    TServer.instance.get('/api', (req) {
      req.sendJson(NovelShareServices.getJson(novelList));
    });
    TServer.instance.get('/cover', (req) async {
      final filePath = req.getQueryParameters['path'] ?? '';
      req.sendFile(await _getCoverPath(filePath));
    });
    TServer.instance.get('/', (req) {
      req.sendHtml(NovelShareServices.getHomeHtml(novelList));
    });

    // get novel
    novelList = await NovelServices.getList();
    novelList.sortDate();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      body: CustomScrollView(
        slivers: [
          _getAppBar(),
          _getStatus(),

          SliverToBoxAdapter(
            child: wifiList.isEmpty
                ? null
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        'အောက်ဘက် host address တစ်ခုခုနဲ့ စမ်းသပ်ကြည့်ပါ',
                      ),
                    ),
                  ),
          ),
          _getWifiList(),
        ],
      ),
    );
  }

  Widget _getAppBar() {
    return SliverAppBar(title: Text('Novel Share'));
  }

  Widget _getStatus() {
    final hostUrl =
        'http://${wifiList.isEmpty ? 'localhost' : wifiList.first}:${TServer.instance.getPort}';

    return SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              ThanPkg.platform.launch(hostUrl);
            },
            child: Text(
              'Server Running On: $hostUrl',
              style: TextStyle(color: Colors.green),
            ),
          ),
          Text(
            'Novel မျှဝေပေးနေပါပြီး။အခြား Novel App ကနေလက်ခံပါ။',
            style: TextStyle(color: Colors.green),
          ),
        ],
      ),
    );
  }

  Widget _getWifiList() {
    return SliverList.separated(
      itemCount: wifiList.length,
      itemBuilder: (context, index) {
        final host = wifiList[index];
        return ListTile(title: Text(host));
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }

  List<ShareDirFile> _getAllDirFiles(String path) {
    final dir = Directory(path);
    if (!dir.existsSync()) return [];
    final files = dir.listSync();
    files.sort((a, b) {
      if (a.getDate.millisecondsSinceEpoch > b.getDate.millisecondsSinceEpoch) {
        return -1;
      }
      if (a.getDate.millisecondsSinceEpoch < b.getDate.millisecondsSinceEpoch) {
        return 1;
      }
      return 0;
    });
    return files.map((e) => ShareDirFile.fromFile(e)).toList();
  }

  Future<String> _getCoverPath(String path) async {
    final mime = lookupMimeType(path) ?? '';
    if (mime.startsWith('image')) {
      return path;
    }
    if (mime.endsWith('/pdf')) {
      final dest = PathUtil.getCachePath(
        name: '${path.getName(withExt: false)}.png',
      );
      await ThanPkg.platform.genPdfThumbnail(
        pathList: [SrcDestType(src: path, dest: dest)],
      );
      return dest;
    }
    if (path.endsWith('.json')) {
      return await PathUtil.getAssetRealPathPath('config.png');
    }
    return await PathUtil.getAssetRealPathPath('file.png');
  }

  void _initWifiList() async {
    wifiList = await ThanPkg.platform.getWifiAddressList();
    if (!mounted) return;
    setState(() {});
  }
}
