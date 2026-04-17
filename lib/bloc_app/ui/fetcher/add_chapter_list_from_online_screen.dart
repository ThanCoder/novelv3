import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/add_chapter_from_online_screen.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
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
    currentSite = list.first;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetch();
    });
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  bool isLoading = false;
  final list = FetchServices.instance.fetcherWebsiteList();
  FetcherWebsite? currentSite;
  final urlController = TextEditingController();

  List<MultiChapterResult> resultList = [];

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
                      child: Row(
                        children: [
                          Expanded(
                            child: TTextField(
                              label: Text('Web Url'),
                              controller: urlController,
                            ),
                          ),
                          IconButton(
                            onPressed: _pasteUrl,
                            icon: Icon(Icons.paste_rounded),
                          ),
                        ],
                      ),
                    ),
                    SliverToBoxAdapter(child: _supportedSite()),

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

  Widget _supportedSite() {
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
    resultList.sort((a, b) {
      if (AddChapterListFromOnlineScreen.sortChapterSmToBig) {
        return a.chNumber.compareTo(b.chNumber);
      } else {
        return b.chNumber.compareTo(a.chNumber);
      }
    });
    setState(() {
      AddChapterListFromOnlineScreen.sortChapterSmToBig =
          !AddChapterListFromOnlineScreen.sortChapterSmToBig;
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
    setState(() {});
  }

  Future<void> _fetch() async {
    try {
      setState(() {
        isLoading = true;
      });
      resultList = await FetchServices.instance.fetchMultiChapter(
        widget.url,
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
    goBlocRoute(
      context,
      builder: (context) => AddChapterFromOnlineScreen(
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
