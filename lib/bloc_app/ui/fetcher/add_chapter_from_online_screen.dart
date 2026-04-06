import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetch_services.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/fetcher_website.dart';
import 'package:novel_v3/bloc_app/ui/fetcher/result_types.dart';
import 'package:novel_v3/core/utils.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class AddChapterFromOnlineScreen extends StatefulWidget {
  final FetcherWebsite? website;
  final String? url;
  final int chapterNumber;
  final void Function(ChapterOnlineContentResult result)? onSaved;
  final bool Function(int chapterNumber)? existsChapterNumber;
  const AddChapterFromOnlineScreen({
    super.key,
    this.onSaved,
    this.website,
    this.url,
    this.chapterNumber = 1,
    this.existsChapterNumber,
  });

  @override
  State<AddChapterFromOnlineScreen> createState() =>
      _AddChapterFromOnlineScreenState();
}

class _AddChapterFromOnlineScreenState
    extends State<AddChapterFromOnlineScreen> {
  @override
  initState() {
    chNumberController.text = widget.chapterNumber.toString();
    urlController.text = widget.url ?? '';
    super.initState();
    currentSite = list.first;

    setState(() {});
    if (widget.website != null) {
      currentSite = list.firstWhere((e) => e.title == widget.website!.title);
      setState(() {});
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
    }
  }

  @override
  void dispose() {
    urlController.dispose();
    chNumberController.dispose();
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  final urlController = TextEditingController();
  final titleController = TextEditingController();
  final chNumberController = TextEditingController();
  final contentController = TextEditingController();
  bool isLoading = false;
  final list = FetchServices.instance.fetcherWebsiteList();
  FetcherWebsite? currentSite;
  String? chapterErrorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Chapter From Online')),
      body: isLoading
          ? Center(child: TLoader.random())
          : TScrollableColumn(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TTextField(
                        label: Text('Chapter Url'),
                        controller: urlController,
                      ),
                    ),
                    IconButton(
                      onPressed: _pasteUrl,
                      icon: Icon(Icons.paste_rounded),
                    ),
                  ],
                ),
                _supportedSite(),
                // content
                TTextField(label: Text('Title'), controller: titleController),
                TTextField(
                  label: Text('Chapter Number'),
                  controller: chNumberController,
                  maxLines: 1,
                  textInputType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  errorText: chapterErrorText,
                  onChanged: (value) => _chapterOnCheck(),
                ),
                TTextField(
                  label: Text('Content'),
                  controller: contentController,
                  maxLines: null,
                ),
              ],
            ),
      floatingActionButton: _floatingActionButton(),
    );
  }

  Widget _supportedSite() {
    return DropdownButton<FetcherWebsite>(
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
    );
  }

  Widget? _floatingActionButton() {
    if (isLoading) {
      return FloatingActionButton(
        onPressed: null,
        child: TLoader.random(size: 30),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 7,
      children: [
        FloatingActionButton(
          heroTag: 'fetch',
          onPressed: _fetch,
          child: Icon(Icons.downloading_sharp),
        ),
        FloatingActionButton(
          heroTag: 'save',
          onPressed: () {
            if (widget.onSaved != null) {
              context.closeNavigator();
            }
            widget.onSaved?.call(
              ChapterOnlineContentResult(
                number: int.parse(chNumberController.text),
                title: titleController.text,
                content: contentController.text,
              ),
            );
          },
          child: Icon(Icons.save_as_rounded),
        ),
      ],
    );
  }

  bool _existsChapter() {
    return (widget.existsChapterNumber?.call(
          int.tryParse(chNumberController.text) ?? 0,
        ) ??
        false);
  }

  void _chapterOnCheck() {
    if (_existsChapter()) {
      chapterErrorText = 'Chapter ရှိနေပါတယ်';
    } else {
      chapterErrorText = null;
    }
    setState(() {});
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

  void _fetch() async {
    _chapterOnCheck();
    try {
      if (currentSite == null) {
        showTMessageDialogError(context, 'Site တစ်ခုကို ရွေးချယ်ပါ');
        return;
      }
      setState(() {
        isLoading = true;
      });

      final res = await FetchServices.instance.fetchChapter(
        urlController.text,
        website: currentSite!,
      );
      titleController.text = res.title;
      contentController.text = res.content.replaceAll(
        '(adsbygoogle = window.adsbygoogle || []).push({});',
        '',
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
}
