import 'dart:io';
import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../fetcher.dart';
import '../interfaces/fetcher_interface.dart';
import '../services/website_services.dart';
import '../types/web_chapter.dart';
import 'fetch_web_chapter_screen.dart';

class FetcherChapterListScreen extends StatefulWidget {
  final String sourceDirPath;
  final String? pageUrl;
  final VoidCallback? onClosed;
  const FetcherChapterListScreen({
    super.key,
    required this.sourceDirPath,
    this.pageUrl,
    this.onClosed,
  });

  @override
  State<FetcherChapterListScreen> createState() =>
      _FetcherChapterListScreenState();
}

class _FetcherChapterListScreenState extends State<FetcherChapterListScreen> {
  @override
  void initState() {
    if (widget.pageUrl != null) {
      pageUrlController.text = widget.pageUrl!;
    }
    super.initState();
    init();
  }

  List<SupportedWebSiteInterface> siteList = [];
  SupportedWebSiteInterface? currentSite;
  final pageUrlController = TextEditingController();
  bool isLoading = false;
  List<WebChapter> webChapterList = [];
  int sortId = 1;
  bool isAsc = true;
  List<TSort> sortList = [
    TSort(id: 1, title: 'Number', ascTitle: 'Smallest', descTitle: 'Biggest'),
  ];

  void init() async {
    siteList = await WebsiteServices.getList();
    if (!mounted) return;
    _onAutoChangeSupportedWebsite();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        widget.onClosed?.call();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Fetcher Chapter List'),
          actions: [_getSort()],
        ),
        body: _getView(),
        floatingActionButton: isLoading
            ? null
            : FloatingActionButton(
                onPressed: _onFetch,
                child: Icon(Icons.cloud_download),
              ),
      ),
    );
  }

  Widget _getView() {
    if (isLoading) {
      return Center(child: TLoader.random());
    }
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _getHeader(),
          ),
        ),
        // list
        _getChapterList(),
      ],
    );
  }

  Widget _getHeader() {
    return Column(
      spacing: 15,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_getPageUrlWidget(), _getSiteChooser()],
    );
  }

  Widget _getChapterList() {
    return SliverList.separated(
      itemCount: webChapterList.length,
      itemBuilder: (context, index) => _getListItem(webChapterList[index]),
      separatorBuilder: (context, index) => Divider(),
    );
  }

  Widget _getListItem(WebChapter chapter) {
    return ListTile(
      leading: Text('number: ${chapter.index}'),
      title: Text(
        chapter.title,
        style: TextStyle(fontSize: 13),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: _checkDownloadIcon(chapter.index),
      onTap: () => _goFetchWebChapter(chapter),
    );
  }

  Widget _checkDownloadIcon(int chapterNumber) {
    final file = File('${widget.sourceDirPath}/$chapterNumber');
    if (file.existsSync()) {
      return Icon(Icons.cloud_done, color: Colors.green);
    }
    return Icon(Icons.cloud_download, color: Colors.red);
  }

  Widget _getPageUrlWidget() {
    return Row(
      children: [
        Expanded(
          child: TTextField(
            label: Text('Page Url'),
            controller: pageUrlController,
            maxLines: 1,
            isSelectedAll: true,
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          onPressed: () async {
            final res = await ThanPkg.appUtil.pasteText();
            pageUrlController.text = res;
            _onAutoChangeSupportedWebsite();
          },
          icon: Icon(Icons.paste),
        ),
      ],
    );
  }

  Widget _getSiteChooser() {
    return DropdownButton<SupportedWebSiteInterface>(
      borderRadius: BorderRadius.circular(4),
      padding: EdgeInsets.all(4),
      hint: Text('Support Sites များ'),
      value: currentSite,
      items: siteList
          .map(
            (e) => DropdownMenuItem<SupportedWebSiteInterface>(
              value: e,
              child: Text(e.title.toCaptalize()),
            ),
          )
          .toList(),
      onChanged: (value) {
        currentSite = value;
        setState(() {});
      },
    );
  }

  Widget _getSort() {
    return IconButton(
      onPressed: () {
        showTSortDialog(
          context,
          sortList: sortList,
          currentId: sortId,
          isAsc: isAsc,
          submitText: Text('Sort'),
          sortDialogCallback: (id, isAsc) {
            sortId = id;
            this.isAsc = isAsc;
            _onSort();
          },
        );
      },
      icon: Icon(Icons.sort),
    );
  }

  void _onSort() {
    if (sortId == 1) {
      if (isAsc) {
        webChapterList.sort((a, b) => a.index.compareTo(b.index));
      } else {
        webChapterList.sort((a, b) => b.index.compareTo(a.index));
      }
    }
    setState(() {});
  }

  void _onAutoChangeSupportedWebsite() {
    final url = pageUrlController.text;
    final index = siteList.indexWhere((e) => url.startsWith(e.url));
    if (index == -1) {
      currentSite = null;
      setState(() {});
      return;
    }
    currentSite = siteList[index];
    setState(() {});
    _onFetch();
  }

  void _onFetch() async {
    try {
      if (pageUrlController.text.isEmpty ||
          !pageUrlController.text.startsWith('http')) {
        return;
      }
      setState(() {
        isLoading = true;
      });
      final html = await Fetcher.instance.onGetHtmlContent(
        pageUrlController.text,
      );
      if (!mounted) return;
      isLoading = false;

      if (currentSite == null) {
        setState(() {});
        showTMessageDialogError(context, 'Supported Site ရွေးချယ်ပေးပါ!');
        return;
      }
      if (currentSite!.webChapterList != null) {
        webChapterList = currentSite!.webChapterList?.getList(html) ?? [];
      }
      _onSort();

      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  void _goFetchWebChapter(WebChapter chapter) {
    if (currentSite == null) {
      showTMessageDialogError(context, 'Supported Site ရွေးချယ်ပေးပါ!');
      return;
    }
    if (currentSite!.webChapterList == null) {
      showTMessageDialogError(
        context,
        'Supported Site မှာ `webChapterList` မရှိပါ!',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FetchWebChapterScreen(
          webChapter: chapter,
          webChapterListFetcher: currentSite!.webChapterList!,
          onSaved: _addChapter,
        ),
      ),
    );
  }

  void _addChapter(int chapterNumber, String content) async {
    try {
      final file = File('${widget.sourceDirPath}/$chapterNumber');
      await file.writeAsString(content);
      if (!mounted) return;
      setState(() {});
      // showTSnackBar(context, 'Added: $chapterNumber');
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }
}
