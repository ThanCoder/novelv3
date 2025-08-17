import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/providers/novel_bookmark_provider.dart';
import 'package:novel_v3/app/screens/forms/edit_novel_form.dart';
import 'package:novel_v3/app/screens/developer/novel_dev_list_screen.dart';
import 'package:novel_v3/app/screens/scanners/pdf_scanner_screen.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/routes_helper.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:novel_v3/more_libs/t_sort/funcs.dart';
import 'package:t_widgets/extensions/index.dart';
import 'package:t_widgets/t_widgets.dart';
import '../novel_search_screen.dart';
import 'package:provider/provider.dart';
import '../../novel_dir_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    await context.read<NovelProvider>().initList();
    if (!mounted) return;
    await context.read<NovelBookmarkProvider>().initList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getList(),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //   },
      //   child: Text('export'),
      // ),
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
      title: Text('Novel V3 Pre'),
      snap: true,
      floating: true,
      backgroundColor: Setting.getAppConfig.isDarkTheme
          ? Colors.black.withValues(alpha: 0.9)
          : Colors.white.withValues(alpha: 0.9),
      actions: [
        _getSearchButton(),
        IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert_rounded)),
      ],
    );
  }

  Widget _getBookmarkWidet() {
    final provider = context.watch<NovelBookmarkProvider>();
    if (provider.isLoading) {
      return Center(child: TLoaderRandom());
    }
    return NovelSeeAllView(title: 'BookMark', list: provider.getList);
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
          leading: Icon(Icons.sort),
          title: Text('Sort'),
          onTap: () {
            closeContext(context);
            _showSort();
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
      fieldName: provider.sortFieldName,
      isAscDefault: provider.isSortAsc,
      sortDialogCallback: (field, isAsc) {
        provider.setSort(field, isAsc);
      },
    );
  }

  void _goDevScreen() {
    goRoute(context, builder: (context) => NovelDevListScreen());
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

  void _addNewNovelFromPdf() {
    final provider = context.read<NovelProvider>();

    goRoute(
      context,
      builder: (context) => PdfScannerScreen(
        onClicked: (pdfCtx, pdf) async {
          try {
            // check already title
            final index = provider.getList.indexWhere(
              (e) => e.title == pdf.getTitle,
            );
            if (index != -1) {
              showTSnackBarError(
                pdfCtx,
                'Novel Title ရှိနေပြီးသားဖြစ်နေပါတယ်!...',
              );
              return;
            }
            closeContext(pdfCtx);

            final novel = Novel.createTitle(
              pdf.getTitle.getName(withExt: false),
            );
            // delay
            await Future.delayed(Duration(milliseconds: 300));
            // copy cover
            final pdfCoverFile = File(pdf.getCoverPath);
            await pdfCoverFile.copy(novel.getCoverPath);
            // move pdf file
            await pdf.rename('${novel.path}/${pdf.getTitle}');

            provider.add(novel);
            if (!context.mounted) return;
            goRoute(context, builder: (context) => EditNovelForm(novel: novel));
          } catch (e) {
            NovelDirApp.showDebugLog(e.toString());
          }
        },
      ),
    );
  }
}
