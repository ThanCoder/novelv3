import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/add_auto_multi_chapter_form_dialog.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/add_auto_multi_chapter_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/fetcher_response.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../fetcher.dart';
import '../interfaces/fetcher_interface.dart';
import '../services/website_services.dart';
import '../types/web_chapter.dart';
import 'fetch_web_chapter_screen.dart';

class FetcherChapterListScreen extends StatefulWidget {
  final String? pageUrl;
  final VoidCallback? onClosed;
  final bool Function(int chapterNumber)? onExistsChapter;
  final Future<void> Function(FetcherResponse response)? onSaved;
  const FetcherChapterListScreen({
    super.key,
    required this.onExistsChapter,
    required this.onSaved,
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
          actions: [
            _getSort(),
            webChapterList.isEmpty
                ? SizedBox.shrink()
                : IconButton(
                    onPressed: _showMenu,
                    icon: Icon(Icons.more_vert_rounded),
                  ),
          ],
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
      onLongPress: () => _showItemMenu(chapter),
    );
  }

  Widget _checkDownloadIcon(int chapterNumber) {
    if (widget.onExistsChapter?.call(chapterNumber) ?? false) {
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

  void _addChapter(FetcherResponse response) async {
    try {
      await widget.onSaved?.call(response);
      // final file = File('${widget.sourceDirPath}/$chapterNumber');
      // await file.writeAsString(content);
      if (!mounted) return;
      setState(() {});
      // showTSnackBar(context, 'Added: $chapterNumber');
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  void _showAddAutoMultiChapterForm() {
    if (webChapterList.isEmpty) return;
    int start = webChapterList.first.index;
    int end = webChapterList.last.index;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddAutoMultiChapterFormDialog(
        start: start,
        end: end,
        onSubmit: _addAudoMultiChapter,
      ),
    );
  }

  void _addAudoMultiChapter(int start, int end) {
    List<WebChapter> chapterList = webChapterList.sublist(start - 1, end);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAutoMultiChapterScreen(
          chapterList: chapterList,
          webChapterListFetcher: currentSite!.webChapterList!,
          onExistsChapter: widget.onExistsChapter,
          onSaved: widget.onSaved,
        ),
      ),
    );
  }

  //menu
  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Auto Multiple Chapter'),
          onTap: () {
            Navigator.pop(context);
            _showAddAutoMultiChapterForm();
          },
        ),
      ],
    );
  }

  // item menu
  void _showItemMenu(WebChapter chapter) {
    showTMenuBottomSheet(
      context,

      title: Text('Menu: Chapter ${chapter.index}'),
      children: [
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Chapter Current Chapter Number'),
          onTap: () {
            Navigator.pop(context);
            _changeCurrentChapterNumber(chapter);
          },
        ),
      ],
    );
  }

  void _changeCurrentChapterNumber(WebChapter chapter) {
    showTReanmeDialog(
      context,
      barrierDismissible: false,
      title: Text('Current Chapter Number'),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputType: TextInputType.number,
      text: chapter.index.toString(),
      submitText: 'Change',
      onSubmit: (text) {
        try {
          if (text.isEmpty || int.tryParse(text) == null) return;
          final currentPos = webChapterList.indexWhere(
            (e) => e.index == chapter.index,
          );
          if (currentPos == -1) return;
          int changedIndex = int.parse(text);

          final res = reindexChapters(webChapterList, currentPos, changedIndex);
          webChapterList = res.toList();
          setState(() {});
        } catch (e) {
          showTMessageDialogError(context, e.toString());
        }
      },
    );
  }

  List<WebChapter> reindexChapters(
    List<WebChapter> list,
    int currentPos,
    int changedIndex,
  ) {
    return list.asMap().entries.map((entry) {
      int i = entry.key;
      var e = entry.value;

      if (i < currentPos) {
        // အရှေ့ဘက် => changedIndex - (currentPos - i)
        return e.copyWith(index: changedIndex - (currentPos - i));
      } else if (i == currentPos) {
        // အလယ် => changedIndex
        return e.copyWith(index: changedIndex);
      } else {
        // နောက်ဘက် => changedIndex + (i - currentPos)
        return e.copyWith(index: changedIndex + (i - currentPos));
      }
    }).toList();
  }
}
