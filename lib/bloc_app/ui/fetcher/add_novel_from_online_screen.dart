import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/add_novel_detail_from_online_screen.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_proxy.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/result_types.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class AddNovelFromOnlineScreen extends StatefulWidget {
  final FetcherWebsite site;
  const AddNovelFromOnlineScreen({super.key, required this.site});

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
              mainAxisExtent: 180,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) => _listItem(result!.list[index]),
          ),
        if (isNextLoading)
          SliverToBoxAdapter(child: Center(child: TLoader.random()))
        else if (result != null && result!.nextUrl.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                onPressed: _nextPage,
                icon: Icon(Icons.navigate_next_rounded, size: 40),
              ),
            ),
          ),
      ],
    );
  }

  Widget _listItem(NovelItemResult item) {
    return InkWell(
      onTap: () => goBlocRoute(
        context,
        builder: (context) =>
            AddNovelDetailFromOnlineScreen(item: item, site: widget.site),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: TImage(source: item.coverUrl)),
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
        ],
      ),
    );
  }

  void _nextPage() async {
    if (isNextLoading || result == null) return;
    try {
      setState(() {
        isNextLoading = true;
      });
      final res = await FetchServices.instance.fetchNovelList(
        result!.nextUrl,
        website: widget.site,
      );
      final list = result!.list;
      list.addAll(res.list);
      result = result!.copyWith(list: list, nextUrl: res.nextUrl);

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
