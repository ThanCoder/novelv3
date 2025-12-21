import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class EditNovelScreen extends StatefulWidget {
  final Novel novel;
  final void Function(Novel updatedNovel) onUpdated;
  const EditNovelScreen({
    super.key,
    required this.novel,
    required this.onUpdated,
  });

  @override
  State<EditNovelScreen> createState() => _EditNovelScreenState();
}

class _EditNovelScreenState extends State<EditNovelScreen> {
  @override
  void initState() {
    novel = widget.novel.copyWith();
    super.initState();
    init();
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    mcController.dispose();
    translatorController.dispose();
    descController.dispose();
    super.dispose();
  }

  late Novel novel;

  void init() {
    titleController.text = novel.meta.title;
    originalTitleController.text = novel.meta.originalTitle;
    englishTitleController.text = novel.meta.englishTitle;
    authorController.text = novel.meta.author;
    mcController.text = novel.meta.mc;
    translatorController.text = novel.meta.translator;
    descController.text = novel.meta.desc;
    isAdult = novel.meta.isAdult;
    isCompleted = novel.meta.isCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Novel')),
      body: CustomScrollView(slivers: [_getForms()]),
      floatingActionButton: FloatingActionButton(
        onPressed: _onUpdate,
        child: Icon(Icons.save_as_rounded),
      ),
    );
  }

  final titleController = TextEditingController();
  final originalTitleController = TextEditingController();
  final englishTitleController = TextEditingController();
  final authorController = TextEditingController();
  final mcController = TextEditingController();
  final translatorController = TextEditingController();
  final descController = TextEditingController();
  bool isCompleted = false;
  bool isAdult = false;

  Widget _getForms() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            // cover
            TCoverChooser(coverPath: novel.getCoverPath),
            Divider(),
            TTextField(
              label: Text('Title'),
              maxLines: 1,
              controller: titleController,
              onSubmitted: (value) => _onUpdate(),
            ),
            TTextField(
              label: Text('Original Title'),
              maxLines: 1,
              controller: originalTitleController,
              onSubmitted: (value) => _onUpdate(),
            ),
            TTextField(
              label: Text('English Title'),
              maxLines: 1,
              controller: englishTitleController,
              onSubmitted: (value) => _onUpdate(),
            ),
            TTextField(
              label: Text('စာရေးဆရာ'),
              maxLines: 1,
              controller: authorController,
            ),
            TTextField(
              label: Text('ဘာသာပြန်'),
              maxLines: 1,
              controller: translatorController,
            ),
            TTextField(
              label: Text('အထိက ဇောတ်ကောင် (MC)'),
              maxLines: 1,
              controller: mcController,
            ),
            _getChecks(),
            _getPageUrlWidget(),
            _getTagsWidget(),
            TTextField(
              label: Text('Description'),
              maxLines: null,
              controller: descController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _getTagsWidget() {
    final allTags = context.watch<NovelProvider>().getAllTags;
    return // tags
    TTagsWrapView(
      title: Text('Tags'),
      values: novel.meta.tags,
      allTags: allTags,
      onApply: (values) {
        novel = novel.copyWith(meta: novel.meta.copyWith(tags: values));
        _clearFocus();
        setState(() {});
      },
    );
  }

  Widget _getPageUrlWidget() {
    return TTagsWrapView(
      title: Text('Page Urls'),
      values: novel.meta.pageUrls,
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
            novel.meta.pageUrls.add(url);
            _clearFocus();
            setState(() {});
          },
        );
      },
      onApply: (values) {
        novel = novel.copyWith(meta: novel.meta.copyWith(pageUrls: values));
        setState(() {});
      },
    );
  }

  Widget _getChecks() {
    return Column(
      children: [
        Card(
          child: SwitchListTile.adaptive(
            title: Text('18 နှစ်အထက် (Is Adult)'),
            value: isAdult,
            onChanged: (value) => setState(() {
              isAdult = value;
            }),
          ),
        ),
        Card(
          child: SwitchListTile.adaptive(
            title: Text('Novel ပြီးဆုံးပြီလား? (Is Completed)'),
            value: isCompleted,
            onChanged: (value) => setState(() {
              isCompleted = value;
            }),
          ),
        ),
      ],
    );
  }

  void _clearFocus() {
    // titleFocus.unfocus();
    // descFocus.unfocus();
    // authorFocus.unfocus();
    // translatorFocus.unfocus();
    // mcFocus.unfocus();
  }

  void _onUpdate() {
    final newNovel = novel.copyWith(
      meta: novel.meta.copyWith(
        title: titleController.text,
        originalTitle: originalTitleController.text,
        englishTitle: englishTitleController.text,
        author: authorController.text,
        translator: translatorController.text,
        mc: mcController.text,
        desc: descController.text,
        isAdult: isAdult,
        isCompleted: isCompleted,
        date: DateTime.now(),
      ),
    );
    closeContext(context);
    widget.onUpdated(newNovel);
  }
}
