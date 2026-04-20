import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/add_novel_detail_from_online_screen.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_proxy.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/types/fetch_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/result_types.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class AddNovelFromOnlineScreen extends StatefulWidget {
  final FetcherWebsite site;
  final void Function(Novel? createdNovel)? onClosed;
  final bool Function(String title)? isExists;
  const AddNovelFromOnlineScreen({
    super.key,
    required this.site,
    this.onClosed,
    this.isExists,
  });

  @override
  State<AddNovelFromOnlineScreen> createState() =>
      _AddNovelFromOnlineScreenState();
}

class _AddNovelFromOnlineScreenState extends State<AddNovelFromOnlineScreen> {
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = false;
  bool isNextLoading = false;
  FetcherNovelResult? result;

  Future<void> init() async {
    if (isLoading) return;
    try {
      setState(() {
        isLoading = true;
      });
      result = await FetchServices.instance.fetchNovelList(
        context,
        widget.site.url,
        website: widget.site,
      );

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Site: ${widget.site.title}'),
        actions: [
          if (TPlatform.isDesktop)
            IconButton(onPressed: init, icon: Icon(Icons.refresh)),

          IconButton(
            onPressed: () {
              ThanPkg.platform.launch(widget.site.url);
            },
            icon: Icon(Icons.open_in_browser),
          ),
          FetcherProxyIcon(),
        ],
      ),
      body: _getResult(),
    );
  }

  Widget _getResult() {
    return CustomScrollView(
      slivers: [
        if (isLoading)
          SliverFillRemaining(child: Center(child: TLoader.random()))
        else if (result == null)
          SliverFillRemaining(child: Center(child: Text('Result is Null')))
        else
          SliverGrid.builder(
            itemCount: result!.list.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 200,
              mainAxisExtent: 220,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) => _listItem(result!.list[index]),
          ),
        if (isNextLoading)
          SliverToBoxAdapter(child: Center(child: TLoader.random()))
        else if (result != null && result!.nextUrls.isNotEmpty)
          SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: _pagiListWidet(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _listItem(NovelItemResult item) {
    final exists = (widget.isExists?.call(item.title) ?? false);
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      // onTap: () => print(item.coverUrl),
      onTap: () => context.goRoute(
        builder: (context) => AddNovelDetailFromOnlineScreen(
          item: item,
          site: widget.site,
          isExists: widget.isExists,
          onClosed: (createdNovel) async {
            widget.onClosed?.call(createdNovel);
            await Future.delayed(Duration(seconds: 1));
            if (!mounted) return;
            setState(() {});
          },
        ),
      ),
      child: Stack(
        children: [
          // cover
          Positioned.fill(child: TImage(source: item.coverUrl)),
          // title
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          //added mark
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
              ),
              child: exists
                  ? Icon(Icons.check, color: Colors.teal)
                  : Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pagiListWidet() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: result!.nextUrls
          .map(
            (e) => TextButton(
              style: TextButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () {
                _nextPage(e.url);
                // print(e.url);
              },
              child: Text(
                e.title,
                style: TextStyle(fontSize: 17, color: Colors.yellow),
              ),
            ),
          )
          .toList(),
    );
  }

  void _nextPage(String nextUrl) async {
    if (isNextLoading || result == null) return;
    try {
      setState(() {
        isNextLoading = true;
      });

      final res = await FetchServices.instance.fetchNovelList(
        context,
        nextUrl,
        website: widget.site,
      );
      final list = result!.list;
      list.addAll(res.list);
      result = result!.copyWith(list: list, nextUrls: res.nextUrls);

      if (!mounted) return;
      setState(() {
        isNextLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isNextLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }
}
