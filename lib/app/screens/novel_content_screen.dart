import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/export_novel_data_dialog.dart';
import 'package:novel_v3/app/models/novel_bookmark_model.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/pages/chapter_list_page.dart';
import 'package:novel_v3/app/pages/novel_book_mark_list_page.dart';
import 'package:novel_v3/app/pages/novel_content_page.dart';
import 'package:novel_v3/app/pages/pdf_list_page.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/screens/chapter_add_from_screen.dart';
import 'package:novel_v3/app/screens/novel_from_screen.dart';
import 'package:novel_v3/app/screens/pdf_add_form_screen.dart';
import 'package:novel_v3/app/services/novel_bookmark_services.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:provider/provider.dart';

class NovelContentScreen extends StatefulWidget {
  NovelModel novel;
  NovelContentScreen({super.key, required this.novel});

  @override
  State<NovelContentScreen> createState() => _NovelContentScreenState();
}

class _NovelContentScreenState extends State<NovelContentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NovelProvider>()
          .setCurrentNovel(novelSourcePath: widget.novel.path);
      init();
    });
  }

  bool isExistsBookmark = false;

  void init() {
    try {
      final title = widget.novel.title;
      final path = widget.novel.path;
      isExistsBookmark = isExistsNovelBookmarkList(
          bookmark: NovelBookmarkModel(title: title, path: path));
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void goBack() {
    Navigator.pop(context);
  }

  void showBottomMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 240,
        child: ListView(
          children: [
            //edit novel
            ListTile(
              onTap: () {
                Navigator.pop(context);

                final novel = context.read<NovelProvider>().getNovel;

                if (novel != null) {
                  //go edit form
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NovelFromScreen(novel: novel),
                    ),
                  );
                }
              },
              leading: const Icon(Icons.add),
              title: const Text('Edit Novel'),
            ),
            //add chapter
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChapterAddFromScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.add),
              title: const Text('Add Chapter'),
            ),
            //add pdf
            ListTile(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfAddFormScreen(),
                  ),
                );
              },
              leading: const Icon(Icons.add),
              title: const Text('Add PDF Files'),
            ),
            //export novel data
            ListTile(
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      ExportNovelDataDialog(dialogContext: context),
                );
              },
              leading: const Icon(Icons.import_export),
              title: const Text('Novel Data ထုတ်မယ်'),
            ),
            //delete novel
            ListTile(
              onTap: () {
                Navigator.pop(context);
                deleteNovelConfim();
              },
              leading: const Icon(Icons.delete_forever),
              title: const Text(
                'Delete Novel',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteNovelConfim() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('အတည်ပြုခြင်း'),
        content: const Text('ဖျက်ချင်တာ သေချာပြီလား?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              deleteNovel(
                novel: widget.novel,
                onSuccess: () {
                  Navigator.pop(context);
                  goBack();
                },
                onError: (msg) {
                  showMessage(context, msg);
                },
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _toggleBookMark() {
    final title = currentNovelNotifier.value!.title;
    final path = currentNovelNotifier.value!.path;
    toggleNovelBookmarkList(
      bookmark: NovelBookmarkModel(title: title, path: path),
    );
    //remove ui
    if (isExistsBookmark) {
      final resList = novelBookMarkListNotifier.value
          .where((nv) => nv.title != title)
          .toList();
      novelBookMarkListNotifier.value = resList;
    }
    setState(() {
      isExistsBookmark = !isExistsBookmark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Novel Content'),
        actions: [
          IconButton(
            onPressed: _toggleBookMark,
            icon: Icon(
                color: isExistsBookmark ? dangerColor : activeColor,
                isExistsBookmark ? Icons.bookmark_remove : Icons.bookmark_add),
          ),
          IconButton(
            onPressed: () {
              showBottomMenu();
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: const _BodyTab(),
    );
  }
}

class _BodyTab extends StatelessWidget {
  const _BodyTab();

  @override
  Widget build(BuildContext context) {
    final novel = context.watch<NovelProvider>().getNovel;
    final coverFile = File(novel == null ? '' : novel.coverPath);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeInOut, // Curve for smoothness
          decoration: appConfigNotifier.value.isShowNovelContentBgImage
              ? BoxDecoration(
                  gradient: isDarkThemeNotifier.value
                      ? const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 3, 14, 17),
                            Color.fromARGB(193, 2, 2, 15),
                            Color.fromARGB(193, 12, 12, 12),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        )
                      : null,
                  image: DecorationImage(
                    image: coverFile.existsSync()
                        ? FileImage(coverFile)
                        : const AssetImage(defaultIconAssetsPath),
                    fit: BoxFit.cover,
                    opacity: 0.2,
                    scale: 0.8,
                  ),
                )
              : null,
          child: const TabBarView(
            children: [
              NovelContentPage(),
              ChapterListPage(),
              PdfListPage(),
              NovelBookMarkListPage(),
            ],
          ),
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(
              text: 'Home',
              icon: Icon(Icons.home),
            ),
            Tab(
              text: 'Chapter',
              icon: Icon(Icons.list),
            ),
            Tab(
              text: 'PDF List',
              icon: Icon(Icons.picture_as_pdf),
            ),
            Tab(
              text: 'Book Mark List',
              icon: Icon(Icons.bookmark_added),
            ),
          ],
        ),
      ),
    );
  }
}
