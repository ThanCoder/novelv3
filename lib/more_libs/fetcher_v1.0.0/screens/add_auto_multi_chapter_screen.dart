import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/fetch_web_chapter_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/fetcher_response.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../fetcher.dart';
import '../interfaces/fetcher_interface.dart';
import '../types/web_chapter.dart';

class AddAutoMultiChapterScreen extends StatefulWidget {
  final List<WebChapter> chapterList;
  final WebChapterListFetcherInterface webChapterListFetcher;
  final bool Function(int chapterNumber)? onExistsChapter;
  final Future<void> Function(FetcherResponse response)? onSaved;
  const AddAutoMultiChapterScreen({
    super.key,
    required this.chapterList,
    required this.webChapterListFetcher,
    this.onExistsChapter,
    this.onSaved,
  });

  @override
  State<AddAutoMultiChapterScreen> createState() =>
      _AddAutoMultiChapterScreenState();
}

class _AddAutoMultiChapterScreenState extends State<AddAutoMultiChapterScreen> {
  bool isLoading = false;
  bool isDownloadingStop = false;
  bool isIncludeTitle = true;
  List<int> isDownloadedChapter = [];
  WebChapter? downloadingChapter;

  @override
  void initState() {
    ThanPkg.platform.toggleKeepScreen(isKeep: true);
    super.initState();
    init();
  }

  @override
  void dispose() {
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
    super.dispose();
  }

  Future<void> init() async {
    try {
      for (var ch in widget.chapterList) {
        // final file = File(pathJoin(widget.saveDir.path, '${ch.index}'));
        if (widget.onExistsChapter?.call(ch.index) ?? false) {
          isDownloadedChapter.add(ch.index);
        }
      }
      setState(() {});
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !isLoading,
      onPopInvokedWithResult: (didPop, result) {
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) => _onBackConfirm(),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Audo Multi Chapter'),
          actions: [
            IconButton(
              onPressed: () {
                isDownloadedChapter.clear();
                setState(() {});
              },
              icon: Icon(Icons.clear_all),
            ),
            // IconButton(onPressed: init, icon: Icon(Icons.start)),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              snap: true,
              floating: true,
              pinned: false,
              automaticallyImplyLeading: false,
              collapsedHeight: 100,
              flexibleSpace: _getHeader(),
            ),

            _getList(),
          ],
        ),
        floatingActionButton: _getFloatingAction(),
      ),
    );
  }

  Widget _getHeader() {
    return Column(
      children: [
        SwitchListTile.adaptive(
          title: Text('Content ထဲကို Title ပါထည့်မယ်'),
          value: isIncludeTitle,
          onChanged: (value) {
            setState(() {
              isIncludeTitle = value;
            });
          },
        ),
        downloadingChapter != null && !isDownloadingStop
            ? Text('Chapter: `${downloadingChapter!.index}` Downloading....')
            : SizedBox.shrink(),
        Divider(),
        isLoading ? LinearProgressIndicator() : SizedBox.shrink(),
      ],
    );
  }

  Widget _getList() {
    return SliverList.separated(
      itemCount: widget.chapterList.length,
      itemBuilder: (context, index) => _getListItem(widget.chapterList[index]),
      separatorBuilder: (context, index) => Divider(),
    );
  }

  Widget _getListItem(WebChapter chapter) {
    return ListTile(
      leading: Text(chapter.index.toString()),
      title: Text(chapter.title),
      trailing: isDownloadedChapter.contains(chapter.index)
          ? Icon(Icons.check, color: Colors.green)
          : Icon(Icons.check_box_outline_blank, color: Colors.red),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FetchWebChapterScreen(
              webChapter: chapter,
              webChapterListFetcher: widget.webChapterListFetcher,
            ),
          ),
        );
      },
    );
  }

  Widget? _getFloatingAction() {
    if (isLoading) {
      return FloatingActionButton(
        heroTag: 'stop',
        onPressed: _stop,
        child: Icon(Icons.stop_circle),
      );
    }
    return FloatingActionButton(
      heroTag: 'fetch',
      onPressed: _startDownloadChapter,
      child: Icon(Icons.cloud_download),
    );
  }

  void _onBackConfirm() {
    if (!isLoading) return;
    showTConfirmDialog(
      context,
      contentText: 'Download ကိုရပ်တန့်ချင်တာ သေချာပြီလား?.',
      submitText: 'Yes',
      cancelText: 'No',
      onSubmit: _stop,
    );
  }

  Future<String?> _fetchWebChapterContent(WebChapter ch) async {
    try {
      final html = await Fetcher.instance.onGetHtmlContent(ch.url);

      final res = widget.webChapterListFetcher.getContent(html);
      if (isIncludeTitle) {
        return '${ch.title}\n\n$res';
      } else {
        return res;
      }
    } catch (e) {
      return null;
    }
  }

  void _startDownloadChapter() async {
    try {
      isDownloadingStop = false;
      isLoading = true;
      setState(() {});

      // isDownloadedChapter.clear();

      for (var ch in widget.chapterList) {
        if (isDownloadingStop) break;
        if (isDownloadedChapter.contains(ch.index)) {
          continue;
        }
        downloadingChapter = ch;
        setState(() {});
        final content = await _fetchWebChapterContent(ch);
        if (content == null) continue;

        // downloaded
        isDownloadedChapter.add(ch.index);
        //set content
        // final file = File(pathJoin(widget.saveDir.path, '${ch.index}'));
        // await file.writeAsString(content);
        await widget.onSaved?.call(
          FetcherResponse(
            url: ch.url,
            title: ch.title,
            chapterNumber: ch.index,
            content: content,
          ),
        );

        if (!mounted) return;
        setState(() {});
      }

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

  void _stop() {
    downloadingChapter = null;
    isLoading = false;
    isDownloadingStop = true;
    setState(() {});
  }
}
