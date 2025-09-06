import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/bookmark/novel_bookmark_db.dart';
import 'package:novel_v3/app/clean_manager/clean_manager_screen.dart';
import 'package:novel_v3/app/providers/novel_bookmark_provider.dart';
import 'package:novel_v3/app/recents/novel_recent_data.dart';
import 'package:novel_v3/app/recents/novel_recent_db.dart';
import 'package:novel_v3/app/screens/forms/edit_novel_form.dart';
import 'package:novel_v3/app/developer/novel_dev_list_screen.dart';
import 'package:novel_v3/app/screens/scanners/pdf_scanner_screen.dart';
import 'package:novel_v3/more_libs/json_database_v1.0.0/database_listener.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/routes_helper.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import '../novel_search_screen.dart';
import 'package:provider/provider.dart';
import '../../novel_dir_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    implements DatabaseListener<NovelRecentData> {
  @override
  void initState() {
    super.initState();
    NovelRecentDB.getInstance().addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    NovelRecentDB.getInstance().removeListener(this);
    super.dispose();
  }

  Future<void> init() async {
    await context.read<NovelProvider>().initList();
    if (!mounted) return;
    await context.read<NovelBookmarkProvider>().initList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DropTarget(
        enable: true,
        onDragDone: (details) {
          if (details.files.isEmpty) return;
          final path = details.files.first.path;
          final mime = lookupMimeType(path) ?? '';
          if (mime.isEmpty) return;
          if (mime.endsWith('/pdf')) {
            // pdf
            _createPdfWithNovel(NovelPdf.createPath(path));
          }
        },
        child: _getList(),
      ),
    );
  }

  Widget _getSearchButton() {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NovelSearchScreen()),
        );
      },
      icon: Icon(Icons.search),
    );
  }

  Widget _getList() {
    final provider = context.watch<NovelProvider>();
    final isLoading = provider.isLoading;
    final list = provider.getList;
    final completedList = list.where((e) => e.isCompleted).toList();
    final onGoingList = list.where((e) => !e.isCompleted).toList();
    final adultList = list.where((e) => e.isAdult).toList();
    final randomList = List.of(list);
    randomList.shuffle();

    if (isLoading) {
      return Center(child: TLoaderRandom());
    }
    return RefreshIndicator.adaptive(
      onRefresh: init,
      child: CustomScrollView(
        slivers: [
          _getSliverAppBar(),

          SliverToBoxAdapter(child: _getRecentWidet()),

          SliverToBoxAdapter(
            child: NovelSeeAllView(title: 'ကျပန်း စာစဥ်များ', list: randomList),
          ),
          SliverToBoxAdapter(child: _getBookmarkWidet()),
          SliverToBoxAdapter(
            child: NovelSeeAllView(title: 'Latest စာစဥ်များ', list: list),
          ),
          SliverToBoxAdapter(
            child: NovelSeeAllView(
              title: 'Completed စာစဥ်များ',
              list: completedList,
            ),
          ),
          SliverToBoxAdapter(
            child: NovelSeeAllView(
              title: 'OnGoing စာစဥ်များ',
              list: onGoingList,
            ),
          ),
          SliverToBoxAdapter(
            child: NovelSeeAllView(title: 'Adult စာစဥ်များ', list: adultList),
          ),
        ],
      ),
    );
  }

  Widget _getSliverAppBar() {
    return SliverAppBar(
      title: Text('Novel V3'),
      snap: true,
      floating: true,
      backgroundColor: Setting.getAppConfig.isDarkTheme
          ? Colors.black.withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.9),
      actions: [
        _getSearchButton(),

        IconButton(onPressed: _showSort, icon: Icon(Icons.sort)),
        IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert_rounded)),
      ],
    );
  }

  Widget _getBookmarkWidet() {
    return FutureBuilder(
      future: NovelBookmarkDB.getInstance().getNovelList(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: TLoaderRandom());
        }
        if (asyncSnapshot.hasData) {
          return NovelSeeAllView(
            title: 'မှတ်သားထားသော',
            list: asyncSnapshot.data ?? [],
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _getRecentWidet() {
    return FutureBuilder(
      future: NovelRecentDB.getInstance().getNovelList(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: TLoaderRandom());
        }
        if (asyncSnapshot.hasData) {
          return NovelSeeAllView(
            title: 'မကြာခင်က',
            list: asyncSnapshot.data ?? [],
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  // main menu
  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add'),
          onTap: () {
            closeContext(context);
            _showAddMainMenu();
          },
        ),
        ListTile(
          leading: Icon(Icons.cleaning_services_rounded),
          title: Text('Clean Mangager'),
          onTap: () {
            closeContext(context);
            _goCleanManagerScreen();
          },
        ),
        ListTile(
          leading: Icon(Icons.view_list_rounded),
          title: Text('Dev'),
          onTap: () {
            closeContext(context);
            _goDevScreen();
          },
        ),
      ],
    );
  }

  void _showSort() {
    final provider = context.read<NovelProvider>();

    showTSortDialog(
      context,
      currentId: provider.currentSortId,
      isAsc: provider.isSortAsc,
      sortDialogCallback: (field, isAsc) {
        provider.setSort(field, isAsc);
      },
    );
  }

  void _goDevScreen() {
    goRoute(context, builder: (context) => NovelDevListScreen());
  }

  void _goCleanManagerScreen() {
    goRoute(context, builder: (context) => CleanManagerScreen());
  }

  // add main menu
  void _showAddMainMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Novel'),
          onTap: () {
            closeContext(context);
            _addNewNovel();
          },
        ),
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Novel From PDF'),
          onTap: () {
            closeContext(context);
            _addNewNovelFromPdf();
          },
        ),
      ],
    );
  }

  void _addNewNovel() {
    final provider = context.read<NovelProvider>();
    final list = provider.getList;

    showTReanmeDialog(
      context,
      barrierDismissible: false,
      autofocus: true,
      submitText: 'New',
      title: Text('New Title'),
      onCheckIsError: (text) {
        final index = list.indexWhere((e) => e.title == text);
        if (index != -1) {
          return 'title ရှိနေပြီးသားဖြစ်နေပါတယ်!...';
        }
        return null;
      },
      text: 'Untitled',
      onSubmit: (text) {
        if (text.isEmpty) return;
        final novel = Novel.createTitle(text.trim());
        provider.add(novel);
        goRoute(context, builder: (context) => EditNovelForm(novel: novel));
      },
    );
  }

  // create form pdf
  void _addNewNovelFromPdf() {
    goRoute(
      context,
      builder: (context) => PdfScannerScreen(
        onClicked: (pdfCtx, pdf) async {
          closeContext(pdfCtx);
          _createPdfWithNovel(pdf);
        },
      ),
    );
  }

  // create with rename novel dialog
  void _createPdfWithNovel(NovelPdf pdf) {
    final provider = context.read<NovelProvider>();
    final list = provider.getList;
    // rename novel title
    showTReanmeDialog(
      context,
      barrierDismissible: false,
      autofocus: true,
      submitText: 'New',
      title: Text('New Novel'),
      text: pdf.getTitle.getName(withExt: false),
      onCheckIsError: (text) {
        final index = list.indexWhere((e) => e.title == (text.trim()));
        if (index != -1) {
          return 'title ရှိနေပြီးသားဖြစ်နေပါတယ်!...';
        }
        return null;
      },
      onSubmit: (text) async {
        if (text.isEmpty) return;
        try {
          final novel = Novel.createTitle(text.trim());
          // delay
          await Future.delayed(Duration(milliseconds: 500));
          // copy cover
          final pdfCoverFile = File(pdf.getCoverPath);
          await pdfCoverFile.copy(novel.getCoverPath);
          // move pdf file
          await pdf.rename('${novel.path}/${pdf.getTitle}');

          provider.add(novel);
          if (!mounted) return;
          goRoute(context, builder: (context) => EditNovelForm(novel: novel));
        } catch (e) {
          NovelDirApp.showDebugLog(e.toString());
        }
      },
    );
  }

  //novel recent db listener
  @override
  void onChanged(NovelRecentData? value) {
    setState(() {});
  }
}
