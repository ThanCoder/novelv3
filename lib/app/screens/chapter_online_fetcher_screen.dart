import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/core/app_components.dart';
import 'package:novel_v3/app/fetcher/fetcher_chooser.dart';
import 'package:novel_v3/app/models/chapter_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/services/html_dom_services.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/app/widgets/index.dart';

class ChapterOnlineFetcherScreen extends ConsumerStatefulWidget {
  String novelPath;
  ChapterOnlineFetcherScreen({
    super.key,
    required this.novelPath,
  });

  @override
  ConsumerState<ChapterOnlineFetcherScreen> createState() =>
      _ChapterOnlineFetcherScreenState();
}

class _ChapterOnlineFetcherScreenState
    extends ConsumerState<ChapterOnlineFetcherScreen> {
  final urlController = TextEditingController();
  final queryController = TextEditingController();
  final queryTitleController = TextEditingController();
  final resultController = TextEditingController();
  final chapterController = TextEditingController();

  final focusNodeUrl = FocusNode();
  final focusNodeQuery = FocusNode();
  final focusNodeQueryTitle = FocusNode();
  final focusNodeResult = FocusNode();
  final focusNodeChapter = FocusNode();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    urlController.text = 'https://mmxianxia.com/599718/';
    queryController.text = '.epcontent';
    queryTitleController.text = '.cat-series';
    chapterController.text = '1';
    init();
  }

  @override
  void dispose() {
    urlController.dispose();
    queryController.dispose();
    queryTitleController.dispose();
    resultController.dispose();
    chapterController.dispose();

    focusNodeUrl.dispose();
    focusNodeQuery.dispose();
    focusNodeQueryTitle.dispose();
    focusNodeResult.dispose();
    focusNodeChapter.dispose();
    super.dispose();
  }

  void init() async {
    var chapter = await ChapterServices.instance
        .getLastChapter(novelPath: widget.novelPath);
    if (chapter != null) {
      chapterController.text = '${chapter.number + 1}';
    }
    _showResultOfflineContentText();
  }

  void _fetch() async {
    focusNodeUrl.unfocus();
    focusNodeQuery.unfocus();
    focusNodeQueryTitle.unfocus();
    focusNodeResult.unfocus();
    focusNodeChapter.unfocus();

    if (urlController.text.isEmpty && queryController.text.isEmpty) {
      showDialogMessage(context, 'ပြည့်စုံအောင် ဖြည့်သွင်းပေးပါ');
      return;
    }
    setState(() {
      isLoading = true;
    });
    try {
      final res = await DioServices.instance.getDio.get(urlController.text);
      final ele = HtmlDomServices.getHtmlEle(res.data.toString());
      if (ele == null) return;
      final content = HtmlDomServices.getQuerySelectorHtml(
        ele,
        queryController.text,
      );
      final title = HtmlDomServices.getQuerySelectorText(
        ele,
        queryTitleController.text,
      );
      // print(content);
      if (!mounted) return;
      if (title.isNotEmpty) {
        resultController.text =
            '$title \n\n ${HtmlDomServices.getNewLine(content)}';
      } else {
        resultController.text = HtmlDomServices.getNewLine(content);
      }

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

  void _showResultOfflineContentText() {
    final text = ChapterModel.getContentText(
        '${widget.novelPath}/${chapterController.text}');
    resultController.text = text;
    setState(() {});
  }

  void _addChapter() {
    try {
      final chapter = ChapterModel(
        title: 'Untitled',
        number: int.parse(chapterController.text),
        path: '${widget.novelPath}/${chapterController.text}',
      );
      chapter.setContent(resultController.text);

      //auto crement
      if (chapterController.text.isEmpty) return;
      int num = int.parse(chapterController.text);
      chapterController.text = '${num + 1}';
      _showResultOfflineContentText();
    } catch (e) {
      showDialogMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        ref
            .read(chapterNotifierProvider.notifier)
            .initList(novelPath: widget.novelPath, isReset: true);
      },
      child: MyScaffold(
        contentPadding: 0,
        appBar: AppBar(
          title: const Text('Chapter Fetcher'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //fetcher
                Row(
                  spacing: 5,
                  children: [
                    const Text('Fetcher'),
                    Expanded(
                      child: FetcherChooser(
                        onChoosed: (fetcher) {
                          queryController.text = fetcher.contentQuery.query;
                          urlController.text = fetcher.testUrl;
                          queryTitleController.text = fetcher.titleQuery.query;
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: TTextField(
                        controller: urlController,
                        label: const Text('Website Url'),
                        isSelectedAll: true,
                        focusNode: focusNodeUrl,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        final text = await pasteFromClipboard();
                        if (text.isEmpty) return;
                        urlController.text = text;
                        _fetch();
                      },
                      icon: const Icon(Icons.paste),
                    ),
                    // const SizedBox(width: 10),
                  ],
                ),
                TTextField(
                  controller: queryTitleController,
                  label: const Text('Title Query'),
                  isSelectedAll: true,
                  focusNode: focusNodeQueryTitle,
                ),
                TTextField(
                  controller: queryController,
                  label: const Text('Content Query'),
                  isSelectedAll: true,
                  focusNode: focusNodeQuery,
                ),
                isLoading
                    ? TLoader(
                        size: 30,
                      )
                    : IconButton(
                        onPressed: _fetch,
                        icon: const Icon(Icons.download),
                      ),
                const Divider(),
                // chapter form
                Row(
                  spacing: 5,
                  children: [
                    Expanded(
                      child: TTextField(
                        controller: chapterController,
                        label: const Text('Chapter'),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textInputType: TextInputType.number,
                        isSelectedAll: true,
                        focusNode: focusNodeChapter,
                      ),
                    ),
                    const SizedBox(width: 30),
                    IconButton(
                      color: Colors.red,
                      onPressed: () {
                        if (chapterController.text.isEmpty) return;
                        int num = int.parse(chapterController.text);
                        if (num == 1) return;
                        chapterController.text = '${num - 1}';
                        _showResultOfflineContentText();
                      },
                      icon: const Icon(Icons.remove_circle),
                    ),
                    IconButton(
                      color: Colors.green,
                      onPressed: () {
                        if (chapterController.text.isEmpty) return;
                        int num = int.parse(chapterController.text);
                        chapterController.text = '${num + 1}';
                        _showResultOfflineContentText();
                      },
                      icon: const Icon(Icons.add_circle),
                    ),
                    const SizedBox(width: 30),
                  ],
                ),

                resultController.text.isEmpty
                    ? const SizedBox.shrink()
                    : TTextField(
                        controller: resultController,
                        maxLines: null,
                        focusNode: focusNodeResult,
                        label: const Text('Result'),
                      ),
              ],
            ),
          ),
        ),
        floatingActionButton: isLoading
            ? null
            : FloatingActionButton(
                onPressed: _addChapter,
                child: const Icon(Icons.save),
              ),
      ),
    );
  }
}
