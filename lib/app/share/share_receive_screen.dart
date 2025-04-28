import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/services/core/dio_services.dart';
import 'package:novel_v3/app/share/novel_online_grid_item.dart';
import 'package:novel_v3/app/share/share_novel_content_screen.dart';
import 'package:novel_v3/app/share/share_search_delegate.dart';

import '../widgets/core/index.dart';

class ShareReceiveScreen extends StatefulWidget {
  String url;
  ShareReceiveScreen({super.key, required this.url});

  @override
  State<ShareReceiveScreen> createState() => _ShareReceiveScreenState();
}

class _ShareReceiveScreenState extends State<ShareReceiveScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  List<NovelModel> list = [];
  bool isLoading = true;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final res = await DioServices.instance.getDio.get(widget.url);
      // List<dynamic> resList = jsonDecode(res.data.toString());
      List<dynamic> resList = res.data;

      list = resList.map((map) => NovelModel.fromMap(map)).toList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showDialogMessage(context, e.toString());
    }
  }

  void _search() {
    showSearch(
      context: context,
      delegate: ShareSearchDelegate(url: widget.url, list: list),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Receive Screen'),
        actions: [
          IconButton(
            onPressed: _search,
            icon: const Icon(Icons.search),
          ),
          PlatformExtension.isDesktop()
              ? IconButton(
                  onPressed: () {
                    init();
                  },
                  icon: const Icon(Icons.refresh),
                )
              : const SizedBox(),
        ],
      ),
      body: isLoading
          ? TLoader()
          : RefreshIndicator(
              onRefresh: init,
              child: GridView.builder(
                itemCount: list.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisExtent: 200,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                ),
                itemBuilder: (context, index) {
                  final novel = list[index];
                  return NovelOnlineGridItem(
                    url: widget.url,
                    novel: novel,
                    onClicked: (novel) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ShareNovelContentScreen(
                              url: widget.url, novel: novel),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}
