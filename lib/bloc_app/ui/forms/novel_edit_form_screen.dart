import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/ui/components/bloc_tag_view.dart';
import 'package:novel_v3/bloc_app/ui/components/cover_chooser.dart';
import 'package:novel_v3/bloc_app/ui/components/rename_bottom_sheet.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelEditFormScreen extends StatefulWidget {
  final Novel novel;
  final void Function(Novel updatedNovel) onUpdated;
  const NovelEditFormScreen({
    super.key,
    required this.novel,
    required this.onUpdated,
  });

  @override
  State<NovelEditFormScreen> createState() => _NovelEditFormScreenState();
}

class _NovelEditFormScreenState extends State<NovelEditFormScreen> {
  @override
  void initState() {
    meta = widget.novel.meta;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    titleController.dispose();
    authorController.dispose();
    translatorController.dispose();
    mcController.dispose();
    descController.dispose();
    super.dispose();
  }

  late NovelMeta meta;
  List<String> allTags = [];

  void init() {
    titleController.text = meta.title;
    authorController.text = meta.author;
    translatorController.text = meta.translator;
    mcController.text = meta.mc;
    descController.text = meta.desc;
    allTags = context.read<NovelListCubit>().allTags();
    setState(() {});
  }

  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final translatorController = TextEditingController();
  final mcController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Novel')),
      body: TScrollableColumn(
        children: [
          _novelCoverWidget(),
          TTextField(
            label: Text('Title'),
            maxLines: 1,
            controller: titleController,
          ),
          TTextField(
            label: Text('Author'),
            maxLines: 1,
            controller: authorController,
          ),
          TTextField(
            label: Text('Translator'),
            maxLines: 1,
            controller: translatorController,
          ),
          TTextField(label: Text('MC'), maxLines: 1, controller: mcController),
          SwitchListTile.adaptive(
            title: Text('Is Adult'),
            value: meta.isAdult,
            onChanged: (value) {
              meta = meta.copyWith(isAdult: value);
              setState(() {});
            },
          ),
          SwitchListTile.adaptive(
            title: Text('Is Completed'),
            value: meta.isCompleted,
            onChanged: (value) {
              meta = meta.copyWith(isCompleted: value);
              setState(() {});
            },
          ),
          _pageUrlForm(),
          _otherTitleWidget(),
          _getTagsWidget(),
          TTextField(
            label: Text('Description'),
            maxLines: null,
            controller: descController,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onUpdate,
        child: Icon(Icons.save_as),
      ),
    );
  }

  Widget _novelCoverWidget() {
    return CoverChooser(coverPath: widget.novel.getCoverPath);
  }

  Widget _pageUrlForm() {
    return BlocTagView(
      values: meta.pageUrls,
      title: Text('Page Urls'),
      onAdd: () {
        showRenameBottomSheet(
          context,
          title: Text('Add New Url'),
          rename: '',
          onApply: (text) {
            if (text.isEmpty) return;
            final list = meta.pageUrls.toList();
            list.add(text);
            meta = meta.copyWith(pageUrls: list);
            setState(() {});
          },
        );
      },
      onClick: (value) {
        showRenameBottomSheet(
          context,
          title: Text('Update Url'),
          rename: value,
          onApply: (text) {
            if (text.isEmpty) return;
            final list = meta.pageUrls.toList();
            list.add(text);
            meta = meta.copyWith(pageUrls: list);
            setState(() {});
          },
          onUpdated: (original, updated) {
            final list = meta.pageUrls.toList();
            final index = list.indexWhere((e) => e == original);
            if (index == -1) return;
            list[index] = updated;
            meta = meta.copyWith(pageUrls: list);
            setState(() {});
          },
        );
      },
      onDelete: (value) {
        final list = meta.pageUrls.toList()..remove(value);
        meta = meta.copyWith(pageUrls: list);
        setState(() {});
      },
    );
  }

  Widget _otherTitleWidget() {
    return BlocTagView(
      values: meta.otherTitleList,
      title: Text('Other Titles'),
      onAdd: () {
        showRenameBottomSheet(
          context,
          title: Text('Add Other Title'),
          rename: '',
          onApply: (text) {
            if (text.isEmpty) return;
            final list = meta.otherTitleList.toList()..add(text);
            meta = meta.copyWith(otherTitleList: list);

            setState(() {});
          },
        );
      },
      onClick: (value) {
        showRenameBottomSheet(
          context,
          title: Text('Update Title'),
          rename: value,
          onApply: (text) {
            if (text.isEmpty) return;
            final list = meta.otherTitleList.toList()..add(text);
            meta = meta.copyWith(otherTitleList: list);
            setState(() {});
          },
          onUpdated: (original, updated) {
            final list = meta.otherTitleList.toList();
            final index = list.indexWhere((e) => e == original);
            if (index == -1) return;
            list[index] = updated;
            meta = meta.copyWith(otherTitleList: list);
            setState(() {});
          },
        );
      },
      onDelete: (value) {
        final list = meta.otherTitleList.toList()..remove(value);
        meta = meta.copyWith(otherTitleList: list);
        setState(() {});
      },
    );
  }

  Widget _getTagsWidget() {
    return TTagsWrapView(
      title: Text('Tags'),
      values: meta.tags,
      allTags: allTags,
      onApply: (values) {
        meta = meta.copyWith(tags: values);
        setState(() {});
      },
    );
  }

  void _onUpdate() async {
    final updatedMeta = meta.copyWith(
      title: titleController.text,
      author: authorController.text,
      mc: mcController.text,
      translator: translatorController.text,
      desc: descController.text,
      date: DateTime.now(),
    );
    final novel = widget.novel.copyWith(
      date: DateTime.now(),
      meta: updatedMeta,
      size: await widget.novel.getAllSize(),
    );
    if (!mounted) return;
    Navigator.pop(context);
    widget.onUpdated(novel);
  }
}
