import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/add_chapter_from_online_screen.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/types/fetch_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/result_types.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class AddChapterListFromOnlineScreen extends StatefulWidget {
  static bool startChapterNumberSmallToBig = false;
  static bool sortChapterSmToBig = true;

  final String url;
  final Future<void> Function(ChapterOnlineContentResult result)? onSaved;
  final bool Function(int chapterNumber)? existsChapterNumber;
  const AddChapterListFromOnlineScreen({
    super.key,
    required this.url,
    this.existsChapterNumber,
    this.onSaved,
  });

  @override
  State<AddChapterListFromOnlineScreen> createState() =>
      _AddChapterListFromOnlineScreenState();
}

class _AddChapterListFromOnlineScreenState
    extends State<AddChapterListFromOnlineScreen> {
  @override
  initState() {
    urlController.text = widget.url;
    super.initState();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  List<FetcherWebsite> list = [];
  FetcherWebsite? currentSite;
  final urlController = TextEditingController();

  List<MultiChapterResult> resultList = [];

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      list = await FetchServices.instance.getWebsiteList();

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      _autoChooseWebsiteType();
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Chapter List From Online'),
          actions: [
            IconButton(
              onPressed: _autosortChapterNumber,
              icon: Icon(Icons.sort_by_alpha),
            ),
          ],
        ),
        body: isLoading
            ? Center(child: TLoader.random())
            : RefreshIndicator.noSpinner(
                onRefresh: _fetch,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TTextField(
                                label: Text('Web Url'),
                                controller: urlController,
                                maxLines: 1,
                                enabled: true,
                              ),
                            ),
                            IconButton(
                              onPressed: _pasteUrl,
                              icon: Icon(Icons.paste_rounded),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: _supportedSite),

                    _list(),
                  ],
                ),
              ),
        floatingActionButton: isLoading
            ? null
            : FloatingActionButton(
                onPressed: _fetch,
                child: Icon(Icons.download),
              ),
      ),
    );
  }

  Widget get _supportedSite {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 5,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fetcher Website'),
            DropdownButton<FetcherWebsite>(
              borderRadius: BorderRadius.circular(4),
              value: currentSite,
              items: list
                  .map(
                    (e) => DropdownMenuItem<FetcherWebsite>(
                      value: e,
                      child: Text(e.title),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  currentSite = value;
                });
              },
            ),
            SwitchListTile.adaptive(
              title: Text('Chapter Number Small -> Big'),
              value:
                  AddChapterListFromOnlineScreen.startChapterNumberSmallToBig,
              onChanged: (value) => setState(() {
                AddChapterListFromOnlineScreen.startChapterNumberSmallToBig =
                    value;
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list() {
    if (isLoading) {
      return SliverFillRemaining(child: Center(child: TLoaderRandom()));
    }
    return SliverList.builder(
      itemCount: resultList.length,
      itemBuilder: (context, index) => _listItem(resultList[index]),
    );
  }

  Widget _listItem(MultiChapterResult ch) {
    final exists = (widget.existsChapterNumber?.call(ch.chNumber) ?? false);
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () => _fetchChapterContent(ch),
      onDoubleTap: () => showTMessageDialog(context, ch.toString()),
      onSecondaryTap: () => showTMessageDialog(context, ch.toString()),
      child: Card(
        color: exists ? Colors.amber : null,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Text(
                ch.chNumber.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  ch.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(fontSize: 13),
                ),
              ),
              SizedBox(width: 10),

              Icon(exists ? Icons.download_done : Icons.download),
            ],
          ),
        ),
      ),
    );
  }

  void _autosortChapterNumber() {
    setState(() {
      AddChapterListFromOnlineScreen.sortChapterSmToBig =
          !AddChapterListFromOnlineScreen.sortChapterSmToBig;
    });
    resultList.sort((a, b) {
      if (AddChapterListFromOnlineScreen.sortChapterSmToBig) {
        return a.chNumber.compareTo(b.chNumber);
      } else {
        return b.chNumber.compareTo(a.chNumber);
      }
    });
  }

  void _pasteUrl() async {
    try {
      final text = await ThanPkg.appUtil.pasteText();
      if (text.isEmpty) return;
      if (!mounted) return;
      if (!text.startsWith('http')) {
        showTMessageDialogError(context, 'Url မဟုတ်ပါ\n\n`$text`');
        return;
      }
      urlController.text = text;

      _autoChooseWebsiteType();
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  void _autoChooseWebsiteType() {
    final index = list.indexWhere((e) {
      final hostname = Uri.parse(e.url).host;
      final currentHostname = Uri.parse(urlController.text).host;
      return hostname == currentHostname;
    });
    if (index == -1) return;
    currentSite = list[index];
    if (urlController.text.startsWith(currentSite!.hostUrl)) {
      final newUrl =
          '${urlController.text.getCleanBackSlash}${currentSite!.chapterListPageQuery!.autoAddUrlParam}';
      urlController.text = newUrl;
    }
    setState(() {});
    // _fetch();
  }

  Future<void> _fetch() async {
    try {
      setState(() {
        isLoading = true;
      });
      resultList = await FetchServices.instance.fetchMultiChapter(
        context,
        urlController.text,
        website: currentSite!,
        startChapterNumberSmallToBig:
            AddChapterListFromOnlineScreen.startChapterNumberSmallToBig,
      );

      resultList.sort((a, b) {
        if (AddChapterListFromOnlineScreen.sortChapterSmToBig) {
          return a.chNumber.compareTo(b.chNumber);
        } else {
          return b.chNumber.compareTo(a.chNumber);
        }
      });
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

  void _fetchChapterContent(MultiChapterResult ch) {
    // print(ch.url.split("'"));
    // return;
    if (ch.url.isEmpty) return;
    goBlocRoute(
      context,
      builder: (context) => AddChapterFromOnlineScreen(
        hostUrl: widget.url,
        website: currentSite,
        url: ch.url,
        chapterNumber: ch.chNumber,
        existsChapterNumber: widget.existsChapterNumber,
        onSaved: (result) async {
          final index = resultList.indexWhere((e) => e.chNumber == ch.chNumber);
          if (index != -1) {
            resultList[index] = ch.copyWith(chNumber: result.number);
          }
          await widget.onSaved?.call(result);
          // await Future.delayed(Duration(sele: 1));
          if (!mounted) return;
          setState(() {});
          // _onSort();
        },
      ),
    );
  }
}
