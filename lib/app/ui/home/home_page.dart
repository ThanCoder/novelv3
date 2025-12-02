import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/core/models/pdf_file.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/core/services/novel_services.dart';
import 'package:novel_v3/app/others/pdf_scanner/pdf_scanner_screen.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/components/novel_list_item.dart';
import 'package:novel_v3/app/ui/content/content_screen.dart';
import 'package:novel_v3/app/ui/forms/edit_novel/edit_novel_screen.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

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

  Future<void> init({bool isUsedCache = true}) async {
    await context.read<NovelProvider>().init(isUsedCache: isUsedCache);
  }

  NovelProvider get getProvider => context.watch<NovelProvider>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () async => init(isUsedCache: false),
        child: CustomScrollView(slivers: [_getAppbar(), _getListWidget()]),
      ),
    );
  }

  Widget _getAppbar() {
    return SliverAppBar(
      title: Text(Setting.instance.appName),
      snap: true,
      floating: true,
      pinned: false,
      actions: [
        !TPlatform.isDesktop
            ? SizedBox.shrink()
            : IconButton(
                onPressed: () => init(isUsedCache: false),
                icon: Icon(Icons.refresh),
              ),
        IconButton(
          onPressed: _showMainMenu,
          icon: Icon(Icons.more_vert_rounded),
        ),
      ],
    );
  }

  Widget _getListWidget() {
    if (getProvider.list.isEmpty) {
      return SliverFillRemaining(child: Center(child: Text('Empty List!')));
    }
    return SliverList.builder(
      itemCount: getProvider.list.length,
      itemBuilder: (context, index) => _getListItem(getProvider.list[index]),
    );
  }

  Widget _getListItem(Novel novel) {
    return NovelListItem(
      novel: novel,
      onClicked: (novel) async {
        await context.read<NovelProvider>().setCurrentNovel(novel);
        if (!mounted) return;
        goRoute(context, builder: (context) => ContentScreen());
      },
      onRightClicked: _onItemMenu,
    );
  }

  void _showMainMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('New'),
          onTap: () {
            closeContext(context);
            _showAddMainMenu();
          },
        ),
      ],
    );
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
    final list = provider.list;

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

        final novel = await NovelServices.instance.createNovelWithTitle(
          text.trim(),
        );
        if (novel == null) {
          if (!mounted) return;
          showTMessageDialogError(
            context,
            'Novel: `${text.trim()}` ဖန်တီးလို့ရမပါ',
          );
          return;
        }
        provider.add(novel);
        if (!mounted) return;
        goRoute(
          context,
          builder: (context) => EditNovelScreen(
            novel: novel,
            onUpdated: (updatedNovel) {
              provider.update(updatedNovel);
            },
          ),
        );
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
  void _createPdfWithNovel(PdfFile pdf) {
    // final provider = context.read<NovelProvider>();
    // final list = provider.getList;
    // rename novel title
    // showTReanmeDialog(
    //   context,
    //   barrierDismissible: false,
    //   autofocus: true,
    //   submitText: 'New',
    //   title: Text('New Novel'),
    //   text: pdf.getTitle.getName(withExt: false),
    //   onCheckIsError: (text) {
    //     final index = list.indexWhere((e) => e.title == (text.trim()));
    //     if (index != -1) {
    //       return 'title ရှိနေပြီးသားဖြစ်နေပါတယ်!...';
    //     }
    //     return null;
    //   },
    //   onSubmit: (text) async {
    //     if (text.isEmpty) return;
    //     try {
    //       final novel = await Novel.createTitle(text.trim());
    //       // copy cover
    //       final pdfCoverFile = File(pdf.getCoverPath);
    //       await pdfCoverFile.copy(novel.getCoverPath);
    //       // move pdf file
    //       await pdf.rename('${novel.path}/${pdf.getTitle}');

    //       provider.add(novel);
    //       if (!mounted) return;
    //       goRoute(context, builder: (context) => EditNovelForm(novel: novel));
    //     } catch (e) {
    //       NovelDirApp.showDebugLog(e.toString());
    //     }
    //   },
    // );
  }

  void _addNewNovelFromUrl() {
    // goRoute(
    //   context,
    //   builder: (context) =>
    //       FetcherWebNovelUrlScreen(url: '', onSaved: _createNovelWithWebResult),
    // );
  }

  // void _createNovelWithWebResult(WebsiteInfoResult result) async {
  // if (result.title == null) return;
  // showDialog(
  //   context: context,
  //   barrierDismissible: false,
  //   builder: (context) => CreateNovelWebsiteInfoResultDialog(
  //     result: result,
  //     onSuccess: () {
  //       init();
  //     },
  //   ),
  // );
  // }
  // item menu
  void _onItemMenu(novel) {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Update'),
          onTap: () {
            closeContext(context);
            _onNovelEdit(novel);
          },
        ),
      ],
    );
  }

  void _onNovelEdit(novel) {
    goRoute(
      context,
      builder: (context) => EditNovelScreen(
        novel: novel,
        onUpdated: (updatedNovel) {
          context.read<NovelProvider>().update(updatedNovel);
        },
      ),
    );
  }
}
