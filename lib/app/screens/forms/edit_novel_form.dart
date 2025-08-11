import 'package:flutter/material.dart';
import 'package:novel_v3/app/novel_dir_app.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class EditNovelForm extends StatefulWidget {
  Novel novel;
  void Function(Novel updatedNovel) onUpdated;
  EditNovelForm({
    super.key,
    required this.novel,
    required this.onUpdated,
  });

  @override
  State<EditNovelForm> createState() => _EditNovelFormState();
}

class _EditNovelFormState extends State<EditNovelForm> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final authorController = TextEditingController();
  final translatorController = TextEditingController();
  final mcController = TextEditingController();
  late Novel novel;
  bool isLoading = false;

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
    super.dispose();
  }

  void init() {
    titleController.text = novel.title;
    descController.text = novel.getContent;
    authorController.text = novel.getAuthor;
    translatorController.text = novel.getTranslator;
    mcController.text = novel.getMC;
  }

  @override
  Widget build(BuildContext context) {
    final allTags = context.watch<NovelProvider>().getAllTags;

    return TScaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.novel.title}'),
      ),
      body: TScrollableColumn(
        children: [
          TTextField(
            label: Text('Title'),
            maxLines: 1,
            controller: titleController,
            isSelectedAll: true,
          ),
          TTextField(
            label: Text('Author'),
            maxLines: 1,
            controller: authorController,
            isSelectedAll: true,
          ),
          TTextField(
            label: Text('Translator'),
            maxLines: 1,
            controller: translatorController,
            isSelectedAll: true,
          ),
          TTextField(
            label: Text('MC'),
            maxLines: 1,
            controller: mcController,
            isSelectedAll: true,
          ),
          // tags
          TTagsWrapView(
            title: Text('Tags'),
            values: novel.getTags,
            allTags: allTags,
            onApply: (values) {
              novel.setTags(values);
              setState(() {});
            },
          ),

          TTextField(
            label: Text('Description'),
            maxLines: null,
            controller: descController,
          ),
        ],
      ),
      floatingActionButton: isLoading
          ? TLoaderRandom()
          : FloatingActionButton(
              onPressed: _onUpdate,
              child: Icon(Icons.save_as_rounded),
            ),
    );
  }

  void _onUpdate() async {
    try {
      setState(() {
        isLoading = true;
      });

      final oldTitle = novel.title;
      final newTitle = titleController.text.trim();
      if (newTitle.isEmpty) return;
      // novel.title = newTitle;
      await novel.setTitle(newTitle);
      // delay
      await Future.delayed(Duration(seconds: 1));

      novel.setAuthor(authorController.text.trim());
      novel.setTranslator(translatorController.text.trim());
      novel.setMC(mcController.text.trim());
      novel.setContent(descController.text.trim());
      novel.setAuthor(authorController.text.trim());

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
      NovelDirApp.instance.showMessage(context, e.toString());
    }

    // closeContext(context);
  }
}
