import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_bookmark_action.dart';
import 'package:novel_v3/app/n3_data/n3_data_export_dialog.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/screens/content/buttons/readed_button.dart';
import 'package:novel_v3/app/screens/content/buttons/readed_recent_button.dart';
import 'package:novel_v3/app/screens/content/content_image_wrapper.dart';
import 'package:novel_v3/app/screens/forms/edit_chapter_screen.dart';
import 'package:novel_v3/app/screens/forms/edit_novel_form.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import '../../novel_dir_app.dart';

class ContentHomePage extends StatefulWidget {
  const ContentHomePage({super.key});

  @override
  State<ContentHomePage> createState() => _ContentHomePageState();
}

class _ContentHomePageState extends State<ContentHomePage> {
  @override
  Widget build(BuildContext context) {
    return ContentImageWrapper(
      appBarAction: [
        NovelBookmarkAction(),
        IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert_rounded)),
      ],
      sliverBuilder: (context, novel) => [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _getHeader(),
          ),
        ),

        // tags
        SliverToBoxAdapter(child: _getBottoms()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TTagsWrapView(
              title: novel.getTags.isEmpty ? null : Text('Tags'),
              type: TTagsTypes.text,
              values: novel.getTags,
              onClicked: _searchTags,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _getDesc()),
      ],
    );
  }

  Widget _getHeader() {
    final novel = context.watch<NovelProvider>().getCurrent!;
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          runSpacing: 5,
          children: [
            TImage(source: novel.getCoverPath, width: 180, height: 200),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                GestureDetector(
                  onLongPress: () {
                    ThanPkg.appUtil.copyText(novel.title);
                    showTSnackBar(context, 'Copied');
                  },
                  child: Text('T: ${novel.title}'),
                ),
                Text('Author: ${novel.getAuthor}'),
                Text('Translator: ${novel.getTranslator}'),
                Text('MC: ${novel.getMC}'),
                Text('ရက်စွဲ: ${novel.date.toParseTime()}'),
                // status
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    StatusText(
                      bgColor: novel.isCompleted
                          ? StatusText.completedColor
                          : StatusText.onGoingColor,
                      text: novel.isCompleted ? 'Completed' : 'OnGoing',
                    ),
                    !novel.isAdult
                        ? StatusText(
                            text: 'Adult',
                            bgColor: StatusText.adultColor,
                          )
                        : SizedBox.shrink(),
                  ],
                ),
                // readed
                ReadedButton(),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _getBottoms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [_getPageButton(), ReadedRecentButton()],
        ),
        Divider(),
      ],
    );
  }

  Widget _getDesc() {
    final novel = context.watch<NovelProvider>().getCurrent!;
    if (novel.getContent.isEmpty) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SelectableText(novel.getContent, style: TextStyle(fontSize: 16)),
    );
  }

  // page button
  Widget _getPageButton() {
    final novel = context.watch<NovelProvider>().getCurrent!;
    final list = novel.getPageUrls;
    if (list.isNotEmpty) {
      return TextButton(
        child: const Text('Page Url'),
        onPressed: () {
          showTListDialog<String>(
            context,
            list: list,
            listItemBuilder: (context, item) => ListTile(
              title: Text(item, style: TextStyle(fontSize: 13), maxLines: 2),
              onTap: () {
                Navigator.pop(context);
                try {
                  ThanPkg.platform.launch(item);
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
            ),
          );
        },
      );
    }
    return SizedBox.shrink();
  }

  void _searchTags(String text) {
    final list = context.read<NovelProvider>().getList;
    final res = list.where((e) => e.getTagContent.contains(text)).toList();
    goNovelSeeAllScreen(context, text, res);
  }

  // main menu
  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Chapter'),
          onTap: () {
            closeContext(context);
            _goEditChapter();
          },
        ),
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit Novel'),
          onTap: () {
            closeContext(context);
            _goEditNovel();
          },
        ),
        ListTile(
          leading: Icon(Icons.import_export),
          title: Text('Export'),
          onTap: () {
            closeContext(context);
            _showEditMenu();
          },
        ),
        ListTile(
          iconColor: Colors.red,
          leading: Icon(Icons.delete_forever_rounded),
          title: Text('Delete'),
          onTap: () {
            closeContext(context);
            _deleteConfirm();
          },
        ),
      ],
    );
  }

  void _goEditChapter() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    goRoute(
      context,
      builder: (context) => EditChapterScreen(novelPath: novel.path),
    );
  }

  void _goEditNovel() {
    final provider = context.read<NovelProvider>();
    final novel = provider.getCurrent;
    if (novel == null) return;
    goRoute(context, builder: (context) => EditNovelForm(novel: novel));
  }

  void _deleteConfirm() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    showTConfirmDialog(
      context,
      submitText: 'Delete Forever',
      contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
      onSubmit: () async {
        await context.read<NovelProvider>().delete(novel);
        if (!mounted) return;
        closeContext(context);
      },
    );
  }

  // export menu
  void _showEditMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.import_export),
          title: Text('Export N3Data'),
          onTap: () {
            closeContext(context);
            _exportN3Data();
          },
        ),
      ],
    );
  }

  // export n3data
  void _exportN3Data() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => N3DataExportDialog(novel: novel),
    );
  }
}
