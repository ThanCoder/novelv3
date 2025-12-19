import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/chapter.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/providers/chapter_provider.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/components/page_url_dialog.dart';
import 'package:novel_v3/app/ui/forms/edit_chapter_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/fetch_send_data.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/fetcher_chapter_list_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/fetcher_chapter_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/fetcher_response.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ChapterMenuActions extends StatefulWidget {
  const ChapterMenuActions({super.key});

  @override
  State<ChapterMenuActions> createState() => _ChapterMenuActionsState();
}

class _ChapterMenuActionsState extends State<ChapterMenuActions> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  late Novel novel;
  late ChapterProvider provider;

  void init() {
    novel = context.read<NovelProvider>().currentNovel!;
    provider = context.read<ChapterProvider>();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showMenu,
      icon: Icon(Icons.more_vert_rounded),
    );
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
        Divider(),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Chapter With Online'),
          onTap: () {
            closeContext(context);
            _goFetcher();
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Multi Chapter With Online'),
          onTap: () {
            closeContext(context);
            _goMultiChapterFetcher();
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.delete_forever, color: Colors.red),
          title: Text('Delete All Chapter'),
          onTap: () {
            closeContext(context);
            _deleteAllChapterConfirm();
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.delete_forever, color: Colors.red),
          title: Text('Delete Chapter DB File'),
          onTap: () {
            closeContext(context);
            _deleteAllChapterDBFileConfirm();
          },
        ),
      ],
    );
  }

  void _goEditChapter({Chapter? chapter}) {
    goRoute(
      context,
      builder: (context) => EditChapterScreen(
        novelPath: novel.path,
        chapter: chapter,
        onClosed: () {
          init();
        },
      ),
    );
  }

  void _goFetcher() {
    final latestChapter = context.read<ChapterProvider>().getLatestChapter;
    goRoute(
      context,
      builder: (context) => FetcherChapterScreen(
        fetchSendData: FetchSendData(url: '', chapterNumber: latestChapter + 1),
        onReceiveData: (context, receiveData) async {
          try {
            if (!context.mounted) return;
            context.read<ChapterProvider>().add(
              Chapter.create(
                title: receiveData.title,
                number: receiveData.chapterNumber,
                content: receiveData.contentText,
              ),
            );
            showTSnackBar(
              context,
              'Added Chapter:${receiveData.chapterNumber}',
            );
          } catch (e) {
            showTMessageDialogError(context, e.toString());
          }
        },
        onClosed: init,
      ),
    );
  }

  void _goMultiChapterFetcher() {
    showDialog(
      context: context,
      builder: (context) => PageUrlDialog(
        list: novel.meta.pageUrls,
        onClicked: (url) {
          goRoute(
            context,
            builder: (context) => FetcherChapterListScreen(
              pageUrl: url,
              onExistsChapter: provider.isExistsNumber,
              onSaved: _addChapter,
              onClosed: () => init(),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addChapter(FetcherResponse response) async {
    await provider.add(
      Chapter.create(
        number: response.chapterNumber,
        title: response.title,
        content: response.content,
      ),
    );
  }

  void _deleteAllChapterConfirm() {
    showTConfirmDialog(
      context,
      contentText: 'Chapter အားလုံးကို ဖျက်ချင်တာ သေချာပြီလား?',
      submitText: 'Delete Forever',
      onSubmit: () {
        provider.deleteAll();
      },
    );
  }

  void _deleteAllChapterDBFileConfirm() {
    showTConfirmDialog(
      context,
      contentText: 'Chapter Database ကို ဖျက်ချင်တာသေချာပြီလား?',
      submitText: 'Delete Chapter DB',
      onSubmit: () {
        provider.deleteDBFile(novel.path);
      },
    );
  }
}
