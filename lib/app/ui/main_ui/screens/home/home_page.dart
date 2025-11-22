import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/interfaces/database.dart';
import 'package:novel_v3/app/others/clean_manager/clean_manager_screen.dart';
import 'package:novel_v3/app/others/n3_data/n3_data.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_install_confirm_dialog.dart';
import 'package:novel_v3/app/others/n3_data/n3_data_install_dialog.dart';
import 'package:novel_v3/app/others/recents/novel_recent_db.dart';
import 'package:novel_v3/app/providers/novel_bookmark_provider.dart';
import 'package:novel_v3/app/ui/main_ui/screens/forms/edit_novel_form.dart';
import 'package:novel_v3/app/others/developer/novel_dev_list_screen.dart';
import 'package:novel_v3/app/ui/main_ui/screens/home/create_novel_website_info_result_dialog.dart';
import 'package:novel_v3/app/ui/main_ui/screens/home/home_list_style_menu.dart';
import 'package:novel_v3/app/ui/main_ui/screens/home/style_pages/home_grid_style.dart';
import 'package:novel_v3/app/ui/main_ui/screens/home/style_pages/home_list_style.dart';
import 'package:novel_v3/app/ui/main_ui/screens/home/style_pages/home_style.dart';
import 'package:novel_v3/app/ui/main_ui/screens/scanners/pdf_scanner_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/screens/fetcher_web_novel_url_screen.dart';
import 'package:novel_v3/more_libs/fetcher_v1.0.0/types/website_info.dart';
import 'package:novel_v3/more_libs/novel_v3_uploader_v1.3.0/routes_helper.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/others/novel_home_list_styles.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import '../novel_search_screen.dart';
import 'package:provider/provider.dart';
import '../../../novel_dir_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with DatabaseListener {
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

  @override
  void onDatabaseChanged(DatabaseListenerEvent event, {String? id}) {
    if (!mounted || id == null) return;
    // init(isUsedCache: false);
    // print('del');
  }

  Future<void> init({bool isUsedCache = true}) async {
    await context.read<NovelProvider>().initList(isCached: isUsedCache);
    if (!mounted) return;
    await context.read<NovelBookmarkProvider>().initList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _getAppbar(),
      body: DropTarget(
        enable: true,
        onDragDone: (details) {
          if (details.files.isEmpty) return;
          final path = details.files.first.path;
          if (N3Data.isN3Data(path)) {
            // n3data
            _createN3Data(path);
            return;
          }
          // mime
          final mime = lookupMimeType(path) ?? '';
          if (mime.isEmpty) return;
          if (mime.endsWith('/pdf')) {
            // pdf
            _createPdfWithNovel(NovelPdf.createPath(path));
            return;
          }
        },
        child: _getViews(),
      ),
    );
  }

  AppBar _getAppbar() {
    return AppBar(
      title: Text('Novel V3'),
      // backgroundColor: config.isDarkMode
      //     ? Colors.black.withValues(alpha: 0.9)
      //     : Colors.white.withValues(alpha: 0.9),
      actions: [
        _getSearchButton(),
        !TPlatform.isDesktop
            ? SizedBox.shrink()
            : IconButton(
                onPressed: () => init(isUsedCache: false),
                icon: Icon(Icons.refresh_sharp),
              ),

        IconButton(onPressed: _showSort, icon: Icon(Icons.sort)),
        IconButton(onPressed: _showMenu, icon: Icon(Icons.more_vert_rounded)),
      ],
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

  Widget _getViews() {
    if (context.watch<NovelProvider>().isLoading) {
      return Center(child: TLoaderRandom());
    }

    return ValueListenableBuilder(
      valueListenable: Setting.getAppConfigNotifier,
      builder: (context, value, child) {
        return _getListStyle();
      },
    );
  }

  Widget _getListStyle() {
    final style = Setting.getAppConfig.homeListStyle;
    if (style == NovelHomeListStyles.list) {
      return HomeListStyle();
    }
    if (style == NovelHomeListStyles.grid) {
      return HomeGridStyle();
    }
    return HomeStyle();
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
          leading: Icon(Icons.style),
          title: Text('Home Style'),
          onTap: () {
            closeContext(context);
            _showListStyle();
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

  // style
  void _showListStyle() {
    showTModalBottomSheet(context, child: HomeListStyleMenu());
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
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Novel From Url'),
          onTap: () {
            closeContext(context);
            _addNewNovelFromUrl();
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
      onSubmit: (text) async {
        if (text.isEmpty) return;
        final novel = await Novel.createTitle(text.trim());
        provider.add(novel);
        if (!mounted) return;
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
        // try {
        //   final novel = Novel.createTitle(text.trim());
        //   // delay
        //   await Future.delayed(Duration(milliseconds: 500));
        //   // copy cover
        //   final pdfCoverFile = File(pdf.getCoverPath);
        //   await pdfCoverFile.copy(novel.getCoverPath);
        //   // move pdf file
        //   await pdf.rename('${novel.path}/${pdf.getTitle}');

        //   provider.add(novel);
        //   if (!mounted) return;
        //   goRoute(context, builder: (context) => EditNovelForm(novel: novel));
        // } catch (e) {
        //   NovelDirApp.showDebugLog(e.toString());
        // }
      },
    );
  }

  void _addNewNovelFromUrl() {
    goRoute(
      context,
      builder: (context) =>
          FetcherWebNovelUrlScreen(url: '', onSaved: _createNovelWithWebResult),
    );
  }

  void _createNovelWithWebResult(WebsiteInfoResult result) async {
    if (result.title == null) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateNovelWebsiteInfoResultDialog(
        result: result,
        onSuccess: () {
          init();
        },
      ),
    );
  }

  void _createN3Data(String path) {
    final n3data = N3Data.createPath(path);
    showDialog(
      context: context,
      builder: (context) => N3DataInstallConfirmDialog(
        descText: Text('Name: ${n3data.getTitle}'),
        n3data: n3data,
        onInstall: (isInstallConfigFiles, isInstallFileOverride) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => N3DataInstallDialog(
              n3data: n3data,
              isInstallConfigFiles: isInstallConfigFiles,
              isInstallFileOverride: isInstallFileOverride,
              onSuccess: () {
                init();
              },
            ),
          );
        },
      ),
    );
  }
}
