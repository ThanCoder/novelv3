import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/routes.dart';
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

  void init() {
    titleController.text = widget.novel.title;
    authorController.text = widget.novel.meta.author;
    mcController.text = widget.novel.meta.mc;
    translatorController.text = widget.novel.meta.translator;
    descController.text = widget.novel.meta.desc;
    isAdult = widget.novel.meta.isAdult;
    isCompleted = widget.novel.meta.isCompleted;
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
          spacing: 10,
          children: [
            TTextField(
              label: Text('Title'),
              maxLines: 1,
              controller: titleController,
              autofocus: true,
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

  void _onUpdate() {
    final newNovel = widget.novel.copyWith(
      title: titleController.text,
      meta: widget.novel.meta.copyWith(
        title: titleController.text,
        author: authorController.text,
        translator: translatorController.text,
        mc: mcController.text,
        desc: descController.text,
        isAdult: isAdult,
        isCompleted: isCompleted,
      ),
    );
    closeContext(context);
    widget.onUpdated(newNovel);
  }
}
