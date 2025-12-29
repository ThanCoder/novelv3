import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/extensions/novel_extension.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/services/novel_services.dart';
import 'package:novel_v3/app/others/share/libs/novel_share_services.dart';
import 'package:novel_v3/app/others/share/libs/share_doc.dart';
import 'package:novel_v3/app/others/share/server_services.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:t_server/t_server.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';

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
    ThanPkg.platform.toggleKeepScreen(isKeep: true);

    _initWifiList();
    // home
    ServerServices.getInstance.router.get('/', (req) {
      req.sendHtml(NovelShareServices.getHomeHtml(novelList));
    });
    ServerServices.getInstance.router.get('/view/novel/:id', (req) {
      final id = req.getParams.getString(['id']);
      if (id.isEmpty) {
        req.sendNotFoundHtml(text: '<h1>not found id: `$id`</h1>');
        return;
      }
      final index = novelList.indexWhere((e) => e.id == id);
      if (index == -1) {
        req.sendNotFoundHtml(text: '<h1>not found in novelList id: `$id`</h1>');
        return;
      }
      req.sendHtml(NovelShareServices.viewWebNovel(novelList[index]));
    });

    // api
    ServerServices.getInstance.router.get('/api', (req) {
      req.sendJson(NovelShareServices.getJson(novelList));
    });
    // send doc
    ServerServices.getInstance.router.get('/doc', (req) {
      List<ShareDoc> list = [
        ShareDoc.create(returnType: 'html doc'),
        ShareDoc.create(
          name: 'get cover',
          requestUrl: '/cover/id/:id?name=[name|{default=cover.png}]',
          returnType: 'cover file',
        ),
        ShareDoc.create(
          name: 'api',
          requestUrl: '/api',
          returnType: 'List<Json>',
        ),
        ShareDoc.create(
          name: 'view novel',
          requestUrl: '/api/view/novel/:id',
          returnType: "{'novel': novel,'files': []}",
        ),
        ShareDoc.create(
          name: 'view chapter list',
          requestUrl: '/api/view/chapters/:id',
          returnType: "{'chapters': []}",
        ),
        ShareDoc.create(
          name: 'view chapter content',
          requestUrl: '/api/view/chapter-content/:id/chapter/:chapterNumber',
          returnType: "{chapter_content': String}",
        ),
        ShareDoc.create(
          name: 'download file',
          requestUrl: '/download/id/:id/name/:name',
          returnType: 'server send file',
        ),
      ];
      final json = list.map((e) => e.toMap()).toList();
      req.sendJson(JsonEncoder.withIndent(' ').convert(json));
    });
    // download
    ServerServices.getInstance.router.get('/download/id/:id/name/:name', (req) {
      final id = req.getParams.getString(['id']);
      final name = req.getParams.getString(['name']);
      if (id.isEmpty) {
        req.sendJson(
          jsonEncode({
            'status': 'not found id: `$id`',
            'uri': '/download/id/:id/name/:name',
          }),
        );
        return;
      }
      if (name.isEmpty) {
        req.sendJson(
          jsonEncode({
            'status': 'not found name: `$name`',
            'uri': '/download/id/:id/name/:name',
          }),
        );
        return;
      }
      final index = novelList.indexWhere((e) => e.id == id);
      if (index == -1) {
        req.sendJson(
          jsonEncode({'status': 'not found in novelList id: `$id`'}),
        );
        return;
      }

      req.sendFile(pathJoin(PathUtil.getSourcePath(), pathJoin(id, name)));
    });
    // cover
    ServerServices.getInstance.router.get('/cover/id/:id', (req) {
      final id = req.getParams.getString(['id']);
      final name = req.getQueryParameters.getString(['name'], def: 'cover.png');
      if (id.isEmpty) {
        req.sendJson(jsonEncode({'status': 'not found id: `$id`'}));
        return;
      }
      final index = novelList.indexWhere((e) => e.id == id);
      if (index == -1) {
        req.sendJson(
          jsonEncode({'status': 'not found in novelList id: `$id`'}),
        );
        return;
      }
      String sendPath = PathUtil.getSourcePath(name: pathJoin(id, name));

      if (name.endsWith('.pdf')) {
        sendPath = PathUtil.getCachePath(name: '$name.png');
      }

      req.sendFile(sendPath);
    });
    // view novel
    ServerServices.getInstance.router.get('/api/view/novel/:id', (req) {
      final id = req.getParams.getString(['id']);
      if (id.isEmpty) {
        req.sendJson(jsonEncode({'status': 'not found id: `$id`'}));
        return;
      }
      final index = novelList.indexWhere((e) => e.id == id);
      if (index == -1) {
        req.sendJson(
          jsonEncode({'status': 'not found in novelList id: `$id`'}),
        );
        return;
      }
      req.sendJson(NovelShareServices.viewNovel(novelList[index]));
    });
    // view chapters
    ServerServices.getInstance.router.get('/api/view/chapters/:id', (
      req,
    ) async {
      final id = req.getParams.getString(['id']);
      if (id.isEmpty) {
        req.sendJson(jsonEncode({'status': 'not found id: `$id`'}));
        return;
      }
      final index = novelList.indexWhere((e) => e.id == id);
      if (index == -1) {
        req.sendJson(
          jsonEncode({'status': 'not found in novelList id: `$id`'}),
        );
        return;
      }
      req.sendJson(await NovelShareServices.viewChapters(novelList[index]));
    });
    // view chapter content
    ServerServices.getInstance.router.get(
      '/api/view/chapter-content/:id/chapter/:chapterNumber',
      (req) async {
        final id = req.getParams.getString(['id']);
        final chapterNumber = req.getParams.getInt(['chapterNumber'], def: -1);
        if (id.isEmpty) {
          req.sendJson(jsonEncode({'status': 'not found id: `$id`'}));
          return;
        }
        if (id.isEmpty) {
          req.sendJson(
            jsonEncode({'status': 'not found chapterNumber: `$chapterNumber`'}),
          );
          return;
        }

        final index = novelList.indexWhere((e) => e.id == id);
        if (index == -1) {
          req.sendJson(
            jsonEncode({'status': 'not found in novelList id: `$id`'}),
          );
          return;
        }
        final content = await NovelShareServices.viewChapterContent(
          novelList[index],
          chapterNumber,
        );
        req.sendJson(content);
      },
    );

    // get novel
    novelList = await NovelServices.getAll();
    novelList.sortDate();
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
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
        'http://${wifiList.isEmpty ? 'localhost' : wifiList.first}:${ServerServices.getInstance.server.port}';

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

  void _initWifiList() async {
    wifiList = await ThanPkg.platform.getWifiAddressList();
    if (!mounted) return;
    setState(() {});
  }
}
