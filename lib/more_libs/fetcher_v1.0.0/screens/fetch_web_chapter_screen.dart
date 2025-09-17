import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../fetcher.dart';
import '../interfaces/fetcher_interface.dart';
import '../types/web_chapter.dart';

class FetchWebChapterScreen extends StatefulWidget {
  final WebChapter webChapter;
  final WebChapterListFetcherInterface webChapterListFetcher;
  final void Function(int chapterNumber, String content)? onSaved;
  const FetchWebChapterScreen({
    super.key,
    required this.webChapter,
    required this.webChapterListFetcher,
    this.onSaved,
  });

  @override
  State<FetchWebChapterScreen> createState() => _FetchWebChapterScreenState();
}

class _FetchWebChapterScreenState extends State<FetchWebChapterScreen> {
  final pageUrlController = TextEditingController();
  final chapterNumberController = TextEditingController();
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  @override
  void initState() {
    pageUrlController.text = widget.webChapter.url;
    titleController.text = widget.webChapter.title;
    chapterNumberController.text = widget.webChapter.index.toString();
    _onFetch();
    super.initState();
  }

  bool isLoading = false;
  bool isIncludeTitle = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fetch Web Chapter')),
      body: isLoading
          ? Center(child: TLoader.random())
          : TScrollableColumn(children: [_getHeader(), _getContentWidget()]),
      floatingActionButton: _getFloatingAction(),
    );
  }

  Widget _getHeader() {
    return Column(
      spacing: 10,
      children: [
        _getPageUrlWidget(),

        TNumberField(
          label: Text('Chapter Number'),
          maxLines: 1,
          controller: chapterNumberController,
        ),
        TTextField(
          label: Text('Title'),
          maxLines: 1,
          isSelectedAll: true,
          controller: titleController,
        ),
      ],
    );
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
            _onFetch();
          },
          icon: Icon(Icons.paste),
        ),
      ],
    );
  }

  Widget _getContentWidget() {
    return Column(
      spacing: 10,
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
        TTextField(
          label: Text('Content'),
          maxLines: null,
          controller: contentController,
        ),
      ],
    );
  }

  Widget? _getFloatingAction() {
    if (isLoading) return null;
    return Column(
      spacing: 5,
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: 'fetch',
          onPressed: _onFetch,
          child: Icon(Icons.cloud_download),
        ),
        FloatingActionButton(
          heroTag: 'save',
          onPressed: _onSave,
          child: Icon(Icons.save_as_outlined),
        ),
      ],
    );
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

      final res = widget.webChapterListFetcher.getContent(html);
      if (isIncludeTitle) {
        contentController.text = '${titleController.text}\n\n$res';
      } else {
        contentController.text = res;
      }

      setState(() {});
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  void _onSave() {
    try {
      if (int.tryParse(chapterNumberController.text) == null) {
        throw Exception('chapter number only support `number value!`');
      }

      widget.onSaved?.call(
        int.parse(chapterNumberController.text),
        contentController.text,
      );
      Navigator.pop(context);
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }
}
