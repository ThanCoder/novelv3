import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/ui/novel_dir_app.dart';
import 'package:novel_v3/app/ui/routes_helper.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class EditNovelForm extends StatefulWidget {
  Novel novel;
  EditNovelForm({super.key, required this.novel});

  @override
  State<EditNovelForm> createState() => _EditNovelFormState();
}

class _EditNovelFormState extends State<EditNovelForm> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final authorController = TextEditingController();
  final translatorController = TextEditingController();
  final mcController = TextEditingController();
  // focus
  final titleFocus = FocusNode();
  final descFocus = FocusNode();
  final authorFocus = FocusNode();
  final translatorFocus = FocusNode();
  final mcFocus = FocusNode();
  bool isLoading = false;
  List<Novel> existsList = [];
  String? titleError;
  Timer? titleCheckTimer;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    authorController.dispose();
    translatorController.dispose();
    mcController.dispose();
    titleFocus.dispose();
    descFocus.dispose();
    authorFocus.dispose();
    translatorFocus.dispose();
    mcFocus.dispose();
    titleCheckTimer?.cancel();
    super.dispose();
  }

  bool isAdult = false;
  bool isCompleted = false;
  List<String> tags = [];
  List<String> pageUrls = [];
  // init
  void init() {
    titleController.text = widget.novel.title;
    descController.text = widget.novel.meta.desc;
    authorController.text = widget.novel.meta.author;
    translatorController.text = widget.novel.meta.translator ?? 'Unknown';
    mcController.text = widget.novel.meta.mc;
    isAdult = widget.novel.meta.isAdult;
    isCompleted = widget.novel.meta.isCompleted;
    tags = widget.novel.meta.tags;
    pageUrls = widget.novel.meta.pageUrls;
    // init exists list
    existsList = context
        .read<NovelProvider>()
        .getList
        .where((e) => e.title != widget.novel.title)
        .toList();
    // remove current novel
  }

  @override
  Widget build(BuildContext context) {
    return TScaffold(
      appBar: AppBar(title: Text('Edit: ${widget.novel.title}')),
      body: TScrollableColumn(
        children: [
          // cover
          TCoverChooser(coverPath: widget.novel.getCoverPath),
          // fields
          _getForms(),
        ],
      ),
      floatingActionButton: isLoading
          ? TLoaderRandom()
          : titleError != null
          ? null
          : FloatingActionButton(
              onPressed: _onUpdate,
              child: Icon(Icons.save_as_rounded),
            ),
    );
  }

  Widget _getForms() {
    final allTags = context.watch<NovelProvider>().getAllTags;
    return Column(
      spacing: 10,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TTextField(
          label: Text('Title'),
          maxLines: 1,
          controller: titleController,
          isSelectedAll: true,
          errorText: titleError,
          focusNode: titleFocus,
          onChanged: (value) {
            if (value.isEmpty) return;
            if (titleCheckTimer?.isActive ?? false) {
              titleCheckTimer?.cancel();
            }
            // delay
            titleCheckTimer = Timer(Duration(milliseconds: 1200), () {
              if (_checkExistsNovelTitle(value)) {
                // ရှိနေရင်
                setState(() {
                  titleError = 'ရှိနေပြီးသား ဖြစ်နေပါတယ်!...';
                });
              } else {
                setState(() {
                  titleError = null;
                });
              }
            });
          },
        ),
        TTextField(
          label: Text('Author'),
          maxLines: 1,
          controller: authorController,
          focusNode: authorFocus,
          isSelectedAll: true,
        ),
        TTextField(
          label: Text('Translator'),
          maxLines: 1,
          controller: translatorController,
          focusNode: translatorFocus,
          isSelectedAll: true,
        ),
        TTextField(
          label: Text('MC'),
          maxLines: 1,
          controller: mcController,
          focusNode: mcFocus,
          isSelectedAll: true,
        ),
        SwitchListTile.adaptive(
          title: Text('is Completed'),
          value: isCompleted,
          onChanged: (value) {
            isCompleted = value;
            setState(() {});
          },
        ),
        SwitchListTile.adaptive(
          title: Text('is Adult'),
          value: isAdult,
          onChanged: (value) {
            isAdult = value;
            setState(() {});
          },
        ),
        // page urls
        _getPageUrlWidget(),

        // tags
        TTagsWrapView(
          title: Text('Tags'),
          values: tags,
          allTags: allTags,
          onApply: (values) {
            tags = values;
            _clearFocus();
            setState(() {});
          },
        ),
        TTextField(
          label: Text('Description'),
          maxLines: null,
          controller: descController,
          focusNode: descFocus,
        ),
      ],
    );
  }

  Widget _getPageUrlWidget() {
    return TTagsWrapView(
      title: Text('Page Urls'),
      values: pageUrls,
      onAddButtonClicked: () {
        showTReanmeDialog(
          context,
          title: Text('Page Urls'),
          autofocus: true,
          barrierDismissible: false,
          submitText: 'Add Url',
          text: '',
          onCheckIsError: (text) {
            if (!text.startsWith('http')) {
              return 'http....***!';
            }
            return null;
          },
          onCancel: () {
            _clearFocus();
          },
          onSubmit: (url) {
            pageUrls.add(url);
            _clearFocus();
            setState(() {});
          },
        );
      },
      onApply: (values) {
        pageUrls = values;
        setState(() {});
      },
    );
  }

  bool _checkExistsNovelTitle(String text) {
    final index = existsList.indexWhere((e) => e.title == text);
    return index != -1;
  }

  void _clearFocus() {
    titleFocus.unfocus();
    descFocus.unfocus();
    authorFocus.unfocus();
    translatorFocus.unfocus();
    mcFocus.unfocus();
  }

  void _onUpdate() async {
    try {
      setState(() {
        isLoading = true;
      });
      await Future.delayed(Duration(milliseconds: 900));

      String savedPath = '${PathUtil.getSourcePath()}/${widget.novel.title}';
      final newTitle = titleController.text.trim();
      if (newTitle.isEmpty) return;

      if (savedPath != newTitle) {
        // change new title
        final oldPath = widget.novel.path;
        savedPath = '${PathUtil.getSourcePath()}/$newTitle';
        await PathUtil.renameDir(
          oldDir: Directory(oldPath),
          newDir: Directory(savedPath),
        );
      }
      final novel = widget.novel.copyWith(title: newTitle, path: savedPath);
      final newMeta = novel.meta.copyWith(
        title: newTitle,
        author: authorController.text.trim(),
        mc: mcController.text.trim(),
        desc: descController.text.trim(),
        isAdult: isAdult,
        isCompleted: isCompleted,
        pageUrls: pageUrls,
        tags: tags,
      );
      novel.setMeta(newMeta);

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      await context.read<NovelProvider>().update(novel, widget.novel.title);
      if (!mounted) return;

      closeContext(context);
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString());
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }

    // closeContext(context);
  }
}
