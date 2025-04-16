import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/chapter_count_view.dart';
import 'package:novel_v3/app/components/chapter_list_item.dart';
import 'package:novel_v3/app/components/core/index.dart';
import 'package:novel_v3/app/dialogs/core/confirm_dialog.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/provider/chapter_provider.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/chapter_edit_form.dart';
import 'package:novel_v3/app/widgets/index.dart';
import 'package:provider/provider.dart';

class ContentChapterPage extends StatefulWidget {
  const ContentChapterPage({super.key});

  @override
  State<ContentChapterPage> createState() => _ContentChapterPageState();
}

class _ContentChapterPageState extends State<ContentChapterPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isSorted = true;

  Future<void> init({bool isReset = false}) async {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    context
        .read<ChapterProvider>()
        .initList(novelPath: novel.path, isReset: isReset);
  }

  void _deleteConfirm(ChapterModel chapter) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`Chapter: ${chapter.number}` ကိုဖျက်ချင်တာ သေချာပြီလား?`',
        submitText: 'Delete',
        onCancel: () {},
        onSubmit: () async {
          try {
            //ui
            context.read<ChapterProvider>().delete(chapter);
          } catch (e) {
            if (!mounted) return;
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _goEditForm(ChapterModel chapter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChapterEditForm(
          novelPath: chapter.getNovelPath,
          chapter: chapter,
        ),
      ),
    );
  }

  void _showMenu(ChapterModel chapter) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_document),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(context);
                  _goEditForm(chapter);
                },
              ),

              //delete
              ListTile(
                iconColor: Colors.red,
                leading: const Icon(Icons.delete_forever_rounded),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteConfirm(chapter);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChapterProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    return MyScaffold(
      appBar: AppBar(
        title: list.isNotEmpty
            ? ChapterCountView(novelPath: list.first.getNovelPath)
            : const Text('Chapter'),
        actions: [
          PlatformExtension.isDesktop()
              ? IconButton(
                  onPressed: () => init(isReset: true),
                  icon: const Icon(Icons.refresh),
                )
              : const SizedBox.shrink(),
          IconButton(
            onPressed: () {
              provider.reversedList();
              isSorted = !isSorted;
              setState(() {});
            },
            icon: const Icon(
              Icons.sort_by_alpha_sharp,
            ),
          ),
        ],
      ),
      body: isLoading
          ? TLoader()
          : RefreshIndicator(
              onRefresh: () async {
                await init(isReset: true);
              },
              child: ListView.separated(
                itemBuilder: (context, index) => ChapterListItem(
                  chapter: list[index],
                  onClicked: (chapter) {
                    goTextReader(context, chapter);
                  },
                  onLongClicked: _showMenu,
                ),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: list.length,
              ),
            ),
    );
  }
}
