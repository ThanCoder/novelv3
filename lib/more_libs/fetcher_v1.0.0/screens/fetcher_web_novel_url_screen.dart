import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/website_info.dart';
import 'package:t_html_parser/t_html_parser.dart' as html;
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../fetcher.dart';
import '../interfaces/fetcher_interface.dart';
import '../services/website_services.dart';

class FetcherWebNovelUrlScreen extends StatefulWidget {
  final String url;
  final void Function(WebsiteInfoResult result)? onSaved;
  const FetcherWebNovelUrlScreen({super.key, required this.url, this.onSaved});

  @override
  State<FetcherWebNovelUrlScreen> createState() =>
      _FetcherWebNovelUrlScreenState();
}

class _FetcherWebNovelUrlScreenState extends State<FetcherWebNovelUrlScreen> {
  final pageUrlController = TextEditingController();
  final titleController = TextEditingController();
  final engTitleController = TextEditingController();
  final authorController = TextEditingController();
  final translatorController = TextEditingController();
  final tagsController = TextEditingController();
  final descriptionController = TextEditingController();
  final coverUrlController = TextEditingController();
  bool isLoading = false;
  List<SupportedWebSiteInterface> siteList = [];
  SupportedWebSiteInterface? currentSite;
  WebsiteInfoResult result = WebsiteInfoResult(url: '');
  html.Element? currentElement;

  bool isIncludeTitle = true;
  bool isIncludeAuthor = true;
  bool isIncludeTranslator = true;
  bool isIncludeCoverUrl = true;
  bool isIncludeTags = true;
  bool isIncludeDesc = true;

  @override
  void initState() {
    pageUrlController.text = widget.url;
    super.initState();
    init();
  }

  void init() async {
    siteList = await WebsiteServices.getList();
    if (!mounted) return;
    setState(() {});
    _onAutoChangeSupportedWebsite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Fetch WebNovel From Url')),
      body: _getView(),
      floatingActionButton: _getFloatingAction(),
    );
  }

  Widget _getView() {
    return TScrollableColumn(
      children: [
        _getPageUrlWidget(),
        _getSiteChooser(),
        Divider(),
        _getFormInfo(),
        Divider(),
        _getForms(),
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
            _onAutoChangeSupportedWebsite();
          },
          icon: Icon(Icons.paste),
        ),
      ],
    );
  }

  Widget _getFormInfo() {
    return Column(
      children: [
        Text('အကြောင်းအရာ'),
        Row(children: [Icon(Icons.check_box), Text('ထည့်သွင်းမယ်')]),
        Row(
          children: [
            Icon(Icons.check_box_outline_blank_outlined),
            Text('မထည့်သွင်းဘူး'),
          ],
        ),
      ],
    );
  }

  Widget _getForms() {
    if (isLoading) {
      return Center(child: TLoader.random());
    }
    if (currentSite == null || currentSite?.info == null) {
      return Center(
        child: Center(
          child: Text(
            'အထောက်ပံ့နိုင်ပါ!...',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        currentSite!.info.titleQuery == null
            ? SizedBox.shrink()
            : Row(
                children: [
                  Checkbox.adaptive(
                    value: isIncludeTitle,
                    onChanged: (value) {
                      setState(() {
                        isIncludeTitle = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TTextField(
                      label: Text('Title'),
                      maxLines: 1,
                      controller: titleController,
                    ),
                  ),
                ],
              ),

        currentSite!.info.authorQuery == null
            ? SizedBox.shrink()
            : Row(
                children: [
                  Checkbox.adaptive(
                    value: isIncludeAuthor,
                    onChanged: (value) {
                      setState(() {
                        isIncludeAuthor = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TTextField(
                      label: Text('Author'),
                      maxLines: 1,
                      controller: authorController,
                    ),
                  ),
                ],
              ),
        currentSite!.info.translatorQuery == null
            ? SizedBox.shrink()
            : Row(
                children: [
                  Checkbox.adaptive(
                    value: isIncludeTranslator,
                    onChanged: (value) {
                      setState(() {
                        isIncludeTranslator = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TTextField(
                      label: Text('Translator'),
                      maxLines: 1,
                      controller: translatorController,
                    ),
                  ),
                ],
              ),
        currentSite!.info.coverUrlQuery == null
            ? SizedBox.shrink()
            : Row(
                children: [
                  Checkbox.adaptive(
                    value: isIncludeCoverUrl,
                    onChanged: (value) {
                      setState(() {
                        isIncludeCoverUrl = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TTextField(
                      label: Text('Cover Url'),
                      maxLines: 1,
                      controller: coverUrlController,
                    ),
                  ),
                ],
              ),
        currentSite!.info.tagsQuery == null
            ? SizedBox.shrink()
            : Row(
                children: [
                  Checkbox.adaptive(
                    value: isIncludeTags,
                    onChanged: (value) {
                      setState(() {
                        isIncludeTags = value!;
                      });
                    },
                  ),
                  Expanded(
                    child: TTextField(
                      label: Text('Tags'),
                      maxLines: 1,
                      controller: tagsController,
                    ),
                  ),
                ],
              ),
        currentSite!.info.descriptionQuery == null
            ? SizedBox.shrink()
            : Checkbox.adaptive(
                value: isIncludeDesc,
                onChanged: (value) {
                  setState(() {
                    isIncludeDesc = value!;
                  });
                },
              ),
        currentSite!.info.descriptionQuery == null
            ? SizedBox.shrink()
            : TTextField(
                label: Text('Description'),
                maxLines: null,
                controller: descriptionController,
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
      if (currentSite == null || currentSite?.info == null) {
        return;
      }
      final info = currentSite!.info;
      currentElement = html.toHtmlElement!;

      final title = info.titleQuery?.getResult(currentElement!);
      final engTitle = info.engTitleQuery?.getResult(currentElement!);
      final author = info.authorQuery?.getResult(currentElement!);
      final translator = info.translatorQuery?.getResult(currentElement!);
      final coverUrl = info.coverUrlQuery?.getResult(currentElement!);
      final description = info.descriptionQuery?.getResult(currentElement!);
      final tags = info.tagsQuery?.getResult(currentElement!);
      // set
      titleController.text = title ?? '';
      engTitleController.text = engTitle ?? '';
      authorController.text = author ?? '';
      translatorController.text = translator ?? '';
      coverUrlController.text = coverUrl ?? '';
      descriptionController.text = description ?? '';
      tagsController.text = tags ?? '';

      if (!mounted) return;
      isLoading = false;

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
      if (currentElement == null) {
        showTMessageDialogError(context, '`currentElement` is null');
      }
      final info = currentSite!.info;
      final title = info.titleQuery?.getResult(currentElement!);
      final engTitle = info.engTitleQuery?.getResult(currentElement!);
      final author = info.authorQuery?.getResult(currentElement!);
      final translator = info.translatorQuery?.getResult(currentElement!);
      final coverUrl = info.coverUrlQuery?.getResult(currentElement!);
      final description = info.descriptionQuery?.getResult(currentElement!);
      final tagsString = info.tagsQuery?.getResult(currentElement!);
      List<String> tags = [];
      if (tagsString != null) {
        tags = tagsString.split(',').toList();
      }

      result = result.copyWith(
        url: pageUrlController.text,
        title: !isIncludeTitle ? null : title,
        engTitle: engTitle,
        author: !isIncludeAuthor ? null : author,
        coverUrl: !isIncludeCoverUrl ? null : coverUrl,
        translator: !isIncludeTranslator ? null : translator,
        description: !isIncludeDesc ? null : description,
        tags: !isIncludeTags ? null : tags,
      );
      Navigator.pop(context);
      widget.onSaved?.call(result);
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }
}
