import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/bloc/novel_list_cubit.dart';
import 'package:novel_v3/bloc_app/ui/components/bloc_tag_view.dart';
import 'package:novel_v3/bloc_app/ui/components/rename_bottom_sheet.dart';
import 'package:novel_v3/core/models/novel.dart';
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
    titleController.text = widget.novel.meta.title;
    authorController.text = widget.novel.meta.author;
    translatorController.text = widget.novel.meta.translator;
    mcController.text = widget.novel.meta.mc;
    descController.text = widget.novel.meta.desc;
    otherTitleList = widget.novel.meta.otherTitleList;
    pageUrls = widget.novel.meta.pageUrls;
    isAdult = widget.novel.meta.isAdult;
    isCompleted = widget.novel.meta.isCompleted;
    allTags = context.read<NovelListCubit>().allTags();
    tags = widget.novel.meta.tags;
    super.initState();
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

  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final translatorController = TextEditingController();
  final mcController = TextEditingController();
  final descController = TextEditingController();
  List<String> otherTitleList = [];
  List<String> pageUrls = [];
  List<String> allTags = [];
  List<String> tags = [];
  bool isAdult = false;
  bool isCompleted = false;

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
            value: isAdult,
            onChanged: (value) {
              isAdult = value;
              setState(() {});
            },
          ),
          SwitchListTile.adaptive(
            title: Text('Is Completed'),
            value: isCompleted,
            onChanged: (value) {
              isCompleted = value;
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
    return TCoverChooser(coverPath: widget.novel.getCoverPath);
  }

  Widget _pageUrlForm() {
    return BlocTagView(
      values: pageUrls,
      title: Text('Page Urls'),
      onAdd: () {
        showRenameBottomSheet(
          context,
          title: Text('Add New Url'),
          rename: '',
          onApply: (text) {
            if (text.isEmpty) return;
            pageUrls.add(text);
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
            pageUrls.add(text);
            setState(() {});
          },
          onUpdated: (original, updated) {
            final index = pageUrls.indexWhere((e) => e == original);
            if (index == -1) return;
            pageUrls[index] = updated;
            setState(() {});
          },
        );
      },
      onDelete: (value) {
        pageUrls.remove(value);
        setState(() {});
      },
    );
  }

  Widget _otherTitleWidget() {
    return BlocTagView(
      values: otherTitleList,
      title: Text('Other Titles'),
      onAdd: () {
        showRenameBottomSheet(
          context,
          title: Text('Add Other Title'),
          rename: '',
          onApply: (text) {
            if (text.isEmpty) return;
            otherTitleList.add(text);
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
            otherTitleList.add(text);
            setState(() {});
          },
          onUpdated: (original, updated) {
            final index = otherTitleList.indexWhere((e) => e == original);
            if (index == -1) return;
            otherTitleList[index] = updated;
            setState(() {});
          },
        );
      },
      onDelete: (value) {
        otherTitleList.remove(value);
        setState(() {});
      },
    );
  }

  Widget _getTagsWidget() {
    return // tags
    TTagsWrapView(
      title: Text('Tags'),
      values: tags,
      allTags: allTags,
      onApply: (values) {
        tags = values;
        setState(() {});
      },
    );
  }

  void _onUpdate() {
    final updatedMeta = widget.novel.meta.copyWith(
      title: titleController.text,
      author: authorController.text,
      mc: mcController.text,
      translator: translatorController.text,
      desc: descController.text,
      otherTitleList: otherTitleList,
      pageUrls: pageUrls,
      isAdult: isAdult,
      isCompleted: isCompleted,
      tags: tags,
      date: DateTime.now(),
    );
    final novel = widget.novel.copyWith(
      date: DateTime.now(),
      meta: updatedMeta,
      size: widget.novel.getAllSize(),
    );
    Navigator.pop(context);
    widget.onUpdated(novel);
  }
}
