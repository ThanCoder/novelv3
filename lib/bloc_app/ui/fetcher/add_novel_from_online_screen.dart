import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
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
          SliverList.builder(
            itemCount: result!.list.length,
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
    return Row(
      children: [
        SizedBox(width: 130, height: 150, child: TImage(source: item.coverUrl)),
        Expanded(child: Text(item.title)),
      ],
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
