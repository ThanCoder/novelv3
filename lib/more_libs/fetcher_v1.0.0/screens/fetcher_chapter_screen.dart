import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/querys/chapter_query.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/selector_rules.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/soup_extractor.dart';
import '../types/chapter_query_types.dart';
import 'package:t_html_parser/t_html_extensions.dart';
import 'package:than_pkg/than_pkg.dart';
import '../fetcher.dart';
import 'package:t_widgets/t_widgets.dart';

typedef ReceiveCallback =
    void Function(BuildContext context, FetchReceiveData receiveData);

class FetcherChapterScreen extends StatefulWidget {
  ReceiveCallback? onReceiveData;
  FetchSendData fetchSendData;
  VoidCallback? onClosed;
  FetcherChapterScreen({
    super.key,
    required this.fetchSendData,
    this.onReceiveData,
    this.onClosed,
  });

  @override
  State<FetcherChapterScreen> createState() => _FetcherChapterScreenState();
}

class _FetcherChapterScreenState extends State<FetcherChapterScreen> {
  final urlController = TextEditingController();
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final chapterNumberController = TextEditingController();
  // focus
  final urlFocus = FocusNode();
  final titleFocus = FocusNode();
  final contentFocus = FocusNode();
  final chapterNumberFocus = FocusNode();

  late FetchSendData fetchSendData;
  ChapterQueryTypes fetcherType = ChapterQueryTypes.telegra;
  List<ChapterQuery> queryList = [
    ChapterQuery(
      startHostUrl: 'https://telegra.ph',
      titleSelector: '.tl_article_header h1',
      contentSelector: '#_tl_editor',
      type: ChapterQueryTypes.telegra,
    ),
    ChapterQuery(
      startHostUrl: 'https://mmxianxia.com',
      titleSelector: '.epheader .cat-series',
      contentSelector: '.epcontent',
      type: ChapterQueryTypes.mmxianxia,
    ),
    ChapterQuery(
      startHostUrl: 'https://msunmm.com',
      titleSelector: '.epheader .cat-series',
      contentSelector: '.epcontent',
      type: ChapterQueryTypes.msunmm,
    ),
  ];

  @override
  void initState() {
    fetchSendData = widget.fetchSendData;
    super.initState();
    init();
  }

  @override
  void dispose() {
    urlController.dispose();
    titleController.dispose();
    contentController.dispose();
    chapterNumberController.dispose();
    urlFocus.dispose();
    titleFocus.dispose();
    contentFocus.dispose();
    chapterNumberFocus.dispose();
    super.dispose();
  }

  bool isLoading = false;
  bool autoIncreChapter = true;
  bool isIncludeTitle = false;

  void init() {
    urlController.text = fetchSendData.url;
    chapterNumberController.text = fetchSendData.chapterNumber.toString();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => widget.onClosed?.call(),
        );
      },
      child: TScaffold(
        appBar: AppBar(title: Text('Fetcher')),
        body: TScrollableColumn(
          children: [
            _getTitleWidget(),
            _getNumberWidget(),
            Text('Fetcher Types'),
            _getTypeChooser(),
            Divider(),
            Text('Result'),
            Row(
              children: [
                Expanded(
                  child: TTextField(
                    label: Text('Title'),
                    controller: titleController,
                    maxLines: 1,
                    isSelectedAll: true,
                    focusNode: titleFocus,
                  ),
                ),
                Switch.adaptive(
                  value: isIncludeTitle,
                  onChanged: (value) {
                    setState(() {
                      isIncludeTitle = value;
                    });
                  },
                ),
              ],
            ),
            TTextField(
              label: Text('Content'),
              controller: contentController,
              maxLines: null,
              focusNode: contentFocus,
            ),
          ],
        ),
        floatingActionButton: isLoading
            ? Center(child: TLoaderRandom())
            : Column(
                spacing: 10,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 'fetch',
                    onPressed: _onFetch,
                    child: Icon(Icons.cloud_download_outlined),
                  ),
                  FloatingActionButton(
                    heroTag: 'save',
                    onPressed: _onSave,
                    child: Icon(Icons.save_as_rounded),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _getTitleWidget() {
    return Row(
      children: [
        Expanded(
          child: TTextField(
            label: Text('Host Url'),
            controller: urlController,
            maxLines: 1,
            isSelectedAll: true,
            onChanged: _onFetcherTypeAutoChanger,
            focusNode: urlFocus,
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          onPressed: () async {
            try {
              urlController.text = await ThanPkg.appUtil.pasteText();
              _onFetcherTypeAutoChanger(urlController.text);
              _onFetch();
            } catch (e) {
              Fetcher.showDebugLog(e.toString());
            }
          },
          icon: Icon(Icons.paste_rounded),
        ),
      ],
    );
  }

  Widget _getTypeChooser() {
    return DropdownButton<ChapterQueryTypes>(
      borderRadius: BorderRadius.circular(4),
      padding: EdgeInsets.all(4),
      value: fetcherType,
      items: ChapterQueryTypes.values
          .map(
            (e) => DropdownMenuItem<ChapterQueryTypes>(
              value: e,
              child: Text(e.name.toCaptalize()),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          fetcherType = value!;
        });
      },
    );
  }

  Widget _getNumberWidget() {
    return Row(
      spacing: 5,
      children: [
        Expanded(
          child: TTextField(
            label: Text('Chapter Number'),
            controller: chapterNumberController,
            maxLines: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputType: TextInputType.number,
            focusNode: chapterNumberFocus,
          ),
        ),
        // auto incre
        Text(autoIncreChapter ? 'Increment' : 'Decrement'),
        Switch.adaptive(
          value: autoIncreChapter,
          onChanged: (value) {
            setState(() {
              autoIncreChapter = value;
            });
          },
        ),
      ],
    );
  }

  void _onSave() {
    if (titleController.text.isEmpty ||
        contentController.text.isEmpty ||
        chapterNumberController.text.isEmpty) {
      Fetcher.instance.showErrorMessage(
        context,
        'Title && Content && Chapter ထဲမှာ `text && number` ရှိရပါမယ်!',
      );
      return;
    }
    // Navigator.pop(context);
    int number = int.parse(chapterNumberController.text);

    widget.onReceiveData?.call(
      context,
      FetchReceiveData(
        title: titleController.text,
        contentText: contentController.text,
        chapterNumber: number,
      ),
    );
    if (autoIncreChapter) {
      number++;
    } else if (!autoIncreChapter && number > 0) {
      number--;
    }
    titleController.text = '';
    contentController.text = '';
    chapterNumberController.text = number.toString();
    // clear focus
    _clearFocus();
  }

  void _onFetch() async {
    try {
      if (urlController.text.isEmpty) return;
      setState(() {
        isLoading = true;
      });

      final content = await Fetcher.instance.onGetHtmlContent(
        urlController.text,
      );
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (content.isEmpty) {
        throw Exception('HTML Text Content မရှိပါ');
      }
      _onFetchType(content);
    } catch (e) {
      Fetcher.showDebugLog(e.toString(), tag: 'FetcherChapterScreen:_onFetch');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      Fetcher.instance.showErrorMessage(context, e.toString());
    }
  }

  void _onFetcherTypeAutoChanger(String text) {
    if (text.isEmpty) return;
    for (var query in queryList) {
      if (text.startsWith(query.startHostUrl) && fetcherType != query.type) {
        setState(() {
          fetcherType = query.type;
        });
        break;
      }
    }
  }

  void _onFetchType(String content) {
    try {
      final htmlEle = content.toHtmlElement;
      if (htmlEle == null) {
        Fetcher.instance.showErrorMessage(context, 'HTML Ele is null');
        return;
      }
      final extractor = SoupExtractor(
        rules: {
          'title': SelectorRules(_getQueryTitle),
          'content': SelectorRules(_getQueryContent),
        },
      );
      final map = extractor.extract(content);

      titleController.text = map['title'] ?? '';
      if (isIncludeTitle) {
        contentController.text =
            '${titleController.text}\n${map['content'] ?? ''}';
      } else {
        contentController.text = (map['content'] ?? '').trim();
      }
    } catch (e) {
      Fetcher.showDebugLog(
        e.toString(),
        tag: 'FetcherChapterScreen:_onFetchType',
      );
      if (!mounted) return;
      Fetcher.instance.showErrorMessage(context, e.toString());
    }
  }

  void _clearFocus() {
    urlFocus.unfocus();
    titleFocus.unfocus();
    contentFocus.unfocus();
    chapterNumberFocus.unfocus();
  }

  String get _getQueryTitle {
    final index = queryList.indexWhere((e) => e.type == fetcherType);
    if (index == -1) return '';
    return queryList[index].titleSelector;
  }

  String get _getQueryContent {
    final index = queryList.indexWhere((e) => e.type == fetcherType);
    if (index == -1) return '';
    return queryList[index].contentSelector;
  }
}
