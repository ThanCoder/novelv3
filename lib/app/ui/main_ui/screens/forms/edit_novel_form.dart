import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/app/routes_helper.dart';
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
  late Novel novel;
  bool isLoading = false;
  List<Novel> existsList = [];
  String? titleError;
  Timer? titleCheckTimer;

  @override
  void initState() {
    novel = widget.novel;
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

  void init() {
    titleController.text = novel.title;
    descController.text = novel.getContent;
    authorController.text = novel.getAuthor;
    translatorController.text = novel.getTranslator;
    mcController.text = novel.getMC;
    // init exists list
    existsList = context
        .read<NovelProvider>()
        .getList
        .where((e) => e.title != novel.title)
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
          TCoverChooser(coverPath: novel.getCoverPath),
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
          value: novel.isCompleted,
          onChanged: (value) {
            novel.setCompleted(value);
            setState(() {});
          },
        ),
        SwitchListTile.adaptive(
          title: Text('is Adult'),
          value: novel.isAdult,
          onChanged: (value) {
            novel.setAdult(value);
            setState(() {});
          },
        ),
        // page urls
        _getPageUrlWidget(),
        // tags
        TTagsWrapView(
          title: Text('Tags'),
          values: novel.getTags,
          allTags: allTags,
          onApply: (values) {
            novel.setTags(values);
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
      values: novel.getPageUrls,
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
            final res = novel.getPageUrls;
            res.add(url);
            novel.setPageUrls(res);
            _clearFocus();
            setState(() {});
          },
        );
      },
      onApply: (values) {
        novel.setPageUrls(values);
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

      final oldTitle = widget.novel.title;
      final newTitle = titleController.text.trim();
      if (newTitle.isEmpty) return;
      // delay

      novel.setAuthor(authorController.text.trim());
      novel.setTranslator(translatorController.text.trim());
      novel.setMC(mcController.text.trim());
      novel.setContent(descController.text.trim());
      novel.setAuthor(authorController.text.trim());
      // rename
      if (oldTitle != newTitle) {
        // change new title
        final oldPath = widget.novel.path;
        final newPath = '${PathUtil.getSourcePath()}/$newTitle';
        await PathUtil.renameDir(
          oldDir: Directory(oldPath),
          newDir: Directory(newPath),
        );
        novel = novel.copyWith(title: newTitle, path: newPath);
      }

      if (!mounted) return;
      await context.read<NovelProvider>().update(novel, oldTitle);
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
