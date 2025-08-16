import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_html_parser/t_html_extensions.dart';
import 'package:than_pkg/than_pkg.dart';
import 'fetcher.dart';
import 'package:t_widgets/t_widgets.dart';

typedef ReceiveCallback =
    void Function(BuildContext context, FetchReceiveData receiveData);

class FetcherChapterScreen extends StatefulWidget {
  FetchSendData fetchSendData;
  ReceiveCallback? onReceiveData;
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
  late FetchSendData fetchSendData;
  FetcherTypes fetcherType = FetcherTypes.telegra;
  List<FetchChapterQuery> queryList = [
    FetchChapterQuery(
      title: '.tl_article_header h1',
      content: '.tl_article',
      type: FetcherTypes.telegra,
    ),
    FetchChapterQuery(
      title: '.epheader .cat-series',
      content: '.epcontent',
      type: FetcherTypes.mmxianxia,
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
    super.dispose();
  }

  bool isLoading = false;
  bool autoIncreChapter = true;

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
            TTextField(
              label: Text('Title'),
              controller: titleController,
              maxLines: 1,
              isSelectedAll: true,
            ),
            TTextField(
              label: Text('Content'),
              controller: contentController,
              maxLines: null,
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
          ),
        ),
        SizedBox(width: 10),
        IconButton(
          onPressed: () async {
            try {
              urlController.text = await ThanPkg.appUtil.pasteText();
              _onFetcherTypeAutoChanger(urlController.text);
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
    return DropdownButton<FetcherTypes>(
      borderRadius: BorderRadius.circular(4),
      padding: EdgeInsets.all(4),
      value: fetcherType,
      items: FetcherTypes.values
          .map(
            (e) => DropdownMenuItem<FetcherTypes>(
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
          ),
        ),
        Spacer(),
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

  void _onFetcherTypeAutoChanger(String text) {
    if (text.isEmpty) return;
    if (text.startsWith('https://telegra.ph') &&
        fetcherType != FetcherTypes.telegra) {
      setState(() {
        fetcherType = FetcherTypes.telegra;
      });
    }
    if (text.startsWith('https://mmxianxia.com') &&
        fetcherType != FetcherTypes.mmxianxia) {
      setState(() {
        fetcherType = FetcherTypes.mmxianxia;
      });
    }
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

  void _onFetchType(String content) {
    try {
      final htmlEle = content.toHtmlElement;
      if (htmlEle == null) {
        Fetcher.instance.showErrorMessage(context, 'HTML Ele is null');
        return;
      }
      final title = htmlEle.getQuerySelectorText(selector: _getQueryTitle);
      titleController.text = title;

      var body = htmlEle.getQuerySelectorHtml(
        selector: _getQueryContent,
        attr: '',
      );
      // <br>, <p>, <div> စတဲ့ tag တွေကို newline နဲ့ အစားထိုး
      String text = body
          .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
          .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n')
          .replaceAll(RegExp(r'</div>', caseSensitive: false), '\n');

      // အဲ့တုန့် tag တွေ ဖယ် (အခြား HTML tag)
      text = text.replaceAll(RegExp(r'<[^>]*>'), '');

      contentController.text = text;
    } catch (e) {
      Fetcher.showDebugLog(
        e.toString(),
        tag: 'FetcherChapterScreen:_onFetchType',
      );
      if (!mounted) return;
      Fetcher.instance.showErrorMessage(context, e.toString());
    }
  }

  String get _getQueryTitle {
    final index = queryList.indexWhere((e) => e.type == fetcherType);
    if (index == -1) return '';
    return queryList[index].title;
  }

  String get _getQueryContent {
    final index = queryList.indexWhere((e) => e.type == fetcherType);
    if (index == -1) return '';
    return queryList[index].content;
  }
}
