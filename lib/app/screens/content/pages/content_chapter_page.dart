import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/action_buttons/novel_content_chapter_action_button.dart';
import 'package:novel_v3/app/components/chapter_list_item.dart';
import 'package:novel_v3/app/components/core/index.dart';
import 'package:novel_v3/app/dialogs/core/confirm_dialog.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/screens/forms/chapter_edit_form.dart';
import 'package:novel_v3/app/screens/content/background_scaffold.dart';
import 'package:novel_v3/my_libs/t_history_v1.0.0/index.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ContentChapterPage extends ConsumerStatefulWidget {
  const ContentChapterPage({super.key});

  @override
  ConsumerState<ContentChapterPage> createState() => _ContentChapterPageState();
}

class _ContentChapterPageState extends ConsumerState<ContentChapterPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isSorted = true;

  Future<void> init({bool isReset = false}) async {
    final novel = ref.read(novelNotifierProvider.notifier).getCurrent;

    if (novel == null) return;
    ref
        .read(chapterNotifierProvider.notifier)
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
            ref.read(chapterNotifierProvider.notifier).delete(chapter);
            //set history
            THistoryServices.instance.add(THistoryRecord.create(
              title: chapter.number.toString(),
              method: TMethods.delete,
              desc: 'Chapter Deleted',
            ));
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
    final provider = ref.watch(chapterNotifierProvider);
    final isLoading = provider.isLoading;
    final list = provider.list;
    return BackgroundScaffold(
      stackChildren: [
        isLoading
            ? Center(child: TLoaderRandom())
            : RefreshIndicator(
                onRefresh: () async {
                  await init(isReset: true);
                },
                child: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      backgroundColor: const Color.fromARGB(0, 97, 97, 97),
                      title: list.isNotEmpty
                          ? Text('Count: ${list.length}')
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
                            ref
                                .read(chapterNotifierProvider.notifier)
                                .reversedList();
                            isSorted = !isSorted;
                            setState(() {});

                          },
                          icon: const Icon(
                            Icons.sort_by_alpha_sharp,
                          ),
                        ),
                        NovelContentChapterActionButton(
                          onBackpress: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                    SliverList.separated(
                      itemBuilder: (context, index) => ChapterListItem(
                        chapter: list[index],
                        onClicked: (chapter) {
                          goTextReader(context, ref, chapter);
                        },
                        onLongClicked: _showMenu,
                      ),
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: list.length,
                    )
                  ],
                ),
              ),
      ],
    );
  }
}
