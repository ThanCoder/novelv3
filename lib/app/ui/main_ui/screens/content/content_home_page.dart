import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/app/components/add_website_result_dialog.dart';
import 'package:novel_v3/app/others/bookmark/novel_bookmark_action.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_export_confirm_dialog.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_export_dialog.dart';
import 'package:novel_v3/app/others/recents/novel_recent_db.dart';
import 'package:novel_v3/app/routes_helper.dart';
import 'package:novel_v3/app/ui/main_ui/screens/content/buttons/page_button.dart';
import 'package:novel_v3/app/ui/main_ui/screens/content/buttons/readed_button.dart';
import 'package:novel_v3/app/ui/main_ui/screens/content/buttons/readed_recent_button.dart';
import 'package:novel_v3/app/ui/main_ui/screens/content/buttons/recent_pdf_button.dart';
import 'package:novel_v3/app/ui/main_ui/screens/content/content_image_wrapper.dart';
import 'package:novel_v3/app/others/developer/novel_config_export_dialog.dart';
import 'package:novel_v3/app/ui/main_ui/screens/content/page_url_dialog.dart';
import 'package:novel_v3/app/ui/main_ui/screens/forms/edit_chapter_screen.dart';
import 'package:novel_v3/app/ui/main_ui/screens/forms/edit_novel_form.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/fetcher_web_novel_url_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/website_info.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/path_util.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import '../../../../novel_dir_app.dart';

class ContentHomePage extends StatefulWidget {
  const ContentHomePage({super.key});

  @override
  State<ContentHomePage> createState() => _ContentHomePageState();
}

class _ContentHomePageState extends State<ContentHomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  void init() async {
    try {
      final novel = context.read<NovelProvider>().getCurrent!;
      await NovelRecentDB.getInstance().addRecent(novel);
      if (!mounted) return;
      // context.read<NovelProvider>().refreshNotifier();
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString(), tag: 'ContentHomePage:init');
    }
  }

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
                    novel.isAdult
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
    ).animate().scaleXY(duration: Duration(milliseconds: 800));
  }

  Widget _getBottoms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            PageButton().animate().fadeIn(
              delay: Duration(milliseconds: 400),
              duration: Duration(milliseconds: 900),
            ),
            ReadedRecentButton().animate().fadeIn(
              delay: Duration(milliseconds: 400),
              duration: Duration(milliseconds: 900),
            ),
            RecentPdfButton().animate().fadeIn(
              delay: Duration(milliseconds: 400),
              duration: Duration(milliseconds: 900),
            ),
          ],
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
    ).animate().fadeIn(
      delay: Duration(milliseconds: 300),
      duration: Duration(milliseconds: 900),
    );
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
          leading: Icon(Icons.add),
          title: Text('Add Online Info'),
          onTap: () {
            closeContext(context);
            _addOnlineInfo();
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
            _showExportMenu();
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

  void _addOnlineInfo() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    showDialog(
      context: context,
      builder: (context) => PageUrlDialog(
        list: novel.getPageUrls,
        onClicked: (url) {
          goRoute(
            context,
            builder: (context) => FetcherWebNovelUrlScreen(
              url: url,
              onSaved: (result) => _addWebsiteResult(novel, result),
            ),
          );
        },
      ),
    );
  }

  void _addWebsiteResult(Novel novel, WebsiteInfoResult result) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddWebsiteResultDialog(
        novel: novel,
        result: result,
        onLoaded: (novelPath) {
          context.read<NovelProvider>().refreshCurrentNovel(novelPath);
        },
      ),
    );
  }

  // export menu
  void _showExportMenu() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.import_export),
          title: Text('Export N3Data'),
          onTap: () {
            closeContext(context);
            _exportN3Data(novel);
          },
        ),
        ListTile(
          leading: Icon(Icons.import_export),
          title: Text('Export Config'),
          onTap: () {
            closeContext(context);
            _exportConfig(novel);
          },
        ),
      ],
    );
  }

  // export n3data
  void _exportN3Data(Novel novel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => N3DataExportConfirmDialog(
        onExport: (isSetPassword) {
          showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => N3DataExportDialog(
              isSetPassword: isSetPassword,
              novel: novel,
              onSuccess: () {
                showTSnackBar(
                  context,
                  'N3Data ထုတ်ပြီးပါပြီ...',
                  showCloseIcon: true,
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _exportConfig(Novel novel) {
    showAdaptiveDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => NovelConfigExportDialog(
        onApply: (isIncludeCover) async {
          try {
            final file = File(
              '${PathUtil.getOutPath()}/${novel.title}.config.json',
            );
            // config
            await file.writeAsString(await novel.getConfigJson());
            // cover
            if (isIncludeCover) {
              final coverFile = File('${novel.path}/cover.png');
              if (coverFile.existsSync()) {
                await coverFile.copy(
                  '${PathUtil.getOutPath()}/${novel.title}.png',
                );
              }
            }
            if (!context.mounted) return;
            showTSnackBar(context, 'Config Exported');
          } catch (e) {
            NovelDirApp.showDebugLog(
              e.toString(),
              tag: 'NovelDevListScreen:_exportConfig',
            );
            if (!context.mounted) return;
            showTMessageDialogError(context, e.toString());
          }
        },
      ),
    );
  }
}
