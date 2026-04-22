import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:novel_v3/other_apps/pdf_reader/dialogs/pdf_reader_setting_dialog.dart';
import 'package:novel_v3/other_apps/pdf_reader/dialogs/pdf_single_reader_setting_dialog.dart';
import 'package:novel_v3/other_apps/pdf_reader/types/pdf_config.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:t_widgets/dialogs/t_confirm_dialog.dart';
import 'package:t_widgets/functions/dialog_func.dart';
import 'package:t_widgets/functions/message_func.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class PdfSingleReaderScreen extends StatefulWidget {
  final String path;
  final PdfConfig pdfConfig;
  final void Function(PdfConfig)? onConfigUpdated;
  const PdfSingleReaderScreen({
    super.key,
    required this.path,
    required this.pdfConfig,
    this.onConfigUpdated,
  });

  @override
  State<PdfSingleReaderScreen> createState() => _PdfSingleReaderScreenState();
}

class _PdfSingleReaderScreenState extends State<PdfSingleReaderScreen> {
  @override
  void initState() {
    pdfConfig = widget.pdfConfig;
    isCanGoBack = !pdfConfig.isOnBackpressConfirm;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    _dom?.dispose();
    widget.onConfigUpdated?.call(
      pdfConfig.copyWith(page: currentPage, zoom: _currentZoom),
    );
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    keyboardFocus.dispose();
    super.dispose();
  }

  bool isLoading = false;
  PdfDocument? _dom;
  final TransformationController _zoomController = TransformationController();
  final _pageController = PageController();
  double _currentZoom = 1.0;
  double _zoomRange = 0.1;
  int currentPage = 1;
  int pageCount = 0;
  late PdfConfig pdfConfig;
  final keyboardFocus = FocusNode();
  bool isCanGoBack = true;

  void init() async {
    try {
      // setconfig
      _initConfig();

      setState(() {
        isLoading = true;
      });
      _dom = await PdfDocument.openFile(
        widget.path,
        useProgressiveLoading: pdfConfig.useProgressiveLoading,
      );
      if (_dom != null) {
        pageCount = _dom!.pages.length;
      }
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      Future.delayed(Duration(milliseconds: 1100)).then((_) {
        if (!mounted) return;
        _goToPage(pdfConfig.page);
        _updateZoom(pdfConfig.zoom == 0 ? 1.0 : pdfConfig.zoom);
        keyboardFocus.requestFocus();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  void _initConfig() {
    _zoomRange = PdfSingleReaderSettingDialog.getPdfRange;
    if (pdfConfig.isFullscreen) {
      ThanPkg.platform.toggleFullScreen(isFullScreen: pdfConfig.isFullscreen);
    }
    if (Platform.isAndroid) {
      ThanPkg.android.app.requestOrientation(type: pdfConfig.screenOrientation);
    }
    isCanGoBack = !pdfConfig.isOnBackpressConfirm;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: pdfConfig.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: PopScope(
        canPop: isCanGoBack,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          _onBackpress();
        },
        child: Scaffold(
          appBar: pdfConfig.isFullscreen
              ? null
              : AppBar(title: Text('PDF Viewer')),
          body: _views,
        ),
      ),
    );
  }

  Widget get _views {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            if (!pdfConfig.isFullscreen)
              SliverAppBar(
                automaticallyImplyLeading: false,
                floating: true,
                snap: true,
                pinned: true,
                flexibleSpace: _header,
              ),
            if (isLoading)
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            else
              SliverFillRemaining(child: _dom == null ? null : _pdfSinglePage),
          ],
        ),
        // nav
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                color: Colors.red,
                onPressed: () {
                  _pageController.previousPage(
                    duration: Duration(microseconds: 500),
                    curve: Curves.bounceInOut,
                  );
                },
                icon: Container(
                  decoration: BoxDecoration(
                    color: pdfConfig.isDarkMode ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.navigate_before, size: 30),
                ),
              ),
              Spacer(),
              IconButton(
                color: Colors.red,
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(microseconds: 500),
                    curve: Curves.bounceInOut,
                  );
                },
                icon: Container(
                  decoration: BoxDecoration(
                    color: pdfConfig.isDarkMode ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.navigate_next, size: 30),
                ),
              ),
            ],
          ),
        ),

        if (pdfConfig.isFullscreen)
          Positioned(
            child: Row(
              children: [
                IconButton(
                  onPressed: _toggleFullscreen,
                  icon: Icon(Icons.fullscreen_exit),
                ),
                // current page
                TextButton(
                  onPressed: () {
                    showTReanmeDialog(
                      context,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      textInputType: TextInputType.number,
                      text: currentPage.toString(),
                      submitText: 'GoToPage',
                      onSubmit: (text) {
                        _goToPage(int.parse(text));

                        // Future.delayed(Duration(milliseconds: 1300)).then((_) {
                        //   _goToPage(int.parse(text));
                        // });
                      },
                    );
                  },
                  child: Text(
                    '$currentPage/$pageCount',
                    // style: TextStyle(color: Colors.blue),
                  ),
                ),
                // zoom out
                IconButton(
                  onPressed: () {
                    _updateZoom(_currentZoom - _zoomRange);
                  },
                  icon: Icon(Icons.zoom_out),
                ),
                // zoom in
                IconButton(
                  onPressed: () {
                    _updateZoom(_currentZoom + _zoomRange);
                  },
                  icon: Icon(Icons.zoom_in),
                ),
                // setting
                IconButton(onPressed: _showSetting, icon: Icon(Icons.settings)),
              ],
            ),
          ),
      ],
    );
  }

  Widget get _header => Container(
    padding: EdgeInsets.all(5),
    // decoration: BoxDecoration(color: Colors.white),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 4,
        children: [
          // current page
          TextButton(
            onPressed: () {
              showTReanmeDialog(
                context,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputType: TextInputType.number,
                text: currentPage.toString(),
                submitText: 'GoToPage',
                onSubmit: (text) {
                  _goToPage(int.parse(text));

                  // Future.delayed(Duration(milliseconds: 1300)).then((_) {
                  //   _goToPage(int.parse(text));
                  // });
                },
              );
            },
            child: Text(
              '$currentPage/$pageCount',
              // style: TextStyle(color: Colors.blue),
            ),
          ),
          // zoom out
          IconButton(
            onPressed: () {
              _updateZoom(_currentZoom - _zoomRange);
            },
            icon: Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: () {
              _updateZoom(_currentZoom + _zoomRange);
            },
            icon: Icon(Icons.zoom_in),
          ),
          IconButton(
            onPressed: () {
              pdfConfig = pdfConfig.copyWith(isDarkMode: !pdfConfig.isDarkMode);
              setState(() {});
            },
            icon: Icon(
              pdfConfig.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          IconButton(
            onPressed: () {
              _toggleFullscreen();
            },
            icon: Icon(
              pdfConfig.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            ),
          ),
          IconButton(onPressed: _showSetting, icon: Icon(Icons.settings)),
        ],
      ),
    ),
  );

  Widget get _pdfSinglePage {
    return KeyboardListener(
      focusNode: keyboardFocus,
      onKeyEvent: (value) {
        if (value is KeyDownEvent) {
          // print(value.logicalKey);
          // arrow right
          if (value.logicalKey.keyId == 0x100000303) {
            _goToPage(currentPage + 1);
          }
          //arrow left
          if (value.logicalKey.keyId == 0x100000302) {
            _goToPage(currentPage - 1);
          }
          // Key F
          if (value.logicalKey.keyId == 0x00000066) {
            _toggleFullscreen();
          }
        }
      },
      child: PageView.builder(
        itemCount: pageCount,
        controller: _pageController,
        onPageChanged: (value) => setState(() {
          currentPage = value + 1;
        }),
        itemBuilder: (context, index) => _pdfItem(_dom!.pages[index], index),
      ),
    );
  }

  Widget _pdfItem(PdfPage page, int index) {
    currentPage = index + 1;
    return _darkModePdfView(
      child: Container(
        color: Colors.white,
        child: InteractiveViewer(
          transformationController: _zoomController,
          scaleEnabled: false,
          panEnabled: false,
          child: Center(
            child: SizedBox(
              width: page.width,
              height: page.height,
              child: PdfPageView(
                document: page.document,
                pageNumber: index + 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _darkModePdfView({required Widget child}) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        pdfConfig.isDarkMode ? Colors.white : Colors.transparent,
        pdfConfig.isDarkMode ? BlendMode.difference : BlendMode.dst,
      ),
      child: child,
    );
    // if (pdfConfig.isDarkMode) {
    //   return ColorFiltered(
    //     colorFilter: ColorFilter.mode(Colors.white, BlendMode.difference),
    //     child: child,
    //   );
    // }
    // return child;
  }

  void _goToPage(int page) async {
    try {
      if (page == -1 || page == 0) return;
      if ((page - 1) > _dom!.pages.length) return;
      // _pageController.animateToPage(
      //   page - 1,
      //   duration: Duration(milliseconds: 700),
      //   curve: Curves.bounceInOut,
      // );
      _pageController.jumpToPage(page - 1);
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }

  void _toggleFullscreen() async {
    pdfConfig = pdfConfig.copyWith(isFullscreen: !pdfConfig.isFullscreen);
    setState(() {});
    ThanPkg.platform.toggleFullScreen(isFullScreen: pdfConfig.isFullscreen);
    await Future.delayed(Duration(milliseconds: 800));
    _updateZoom(_currentZoom);
  }

  void _updateZoom(double zoom) {
    setState(() {
      _currentZoom = zoom;
      // Matrix4 ကို သုံးပြီး scale ချဲ့တာပါ
      final double viewWidth = MediaQuery.of(context).size.width;
      final double viewHeight = MediaQuery.of(context).size.height;

      _zoomController.value = Matrix4.identity()
        ..translateByVector3(Vector3(viewWidth / 2, viewHeight / 2, 1.0))
        ..scaleByVector3(Vector3(_currentZoom, _currentZoom, 1.0))
        ..translateByVector3(Vector3(-viewWidth / 2, -viewHeight / 2, 1.0));
      // _zoomController.value = Matrix4.identity()
      //   ..scaleByVector3(Vector3(_currentZoom, _currentZoom, 1.0));
    });
  }

  void _showSetting() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.zoom_in_map),
          title: Text('Reader Zoom Range'),
          onTap: () {
            context.closeNavigator();
            showDialog(
              context: context,
              builder: (context) => PdfSingleReaderSettingDialog(
                onClosed: (result) {
                  _zoomRange = result.zoomRange;
                  setState(() {});
                },
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text('Reader Config'),
          onTap: () {
            context.closeNavigator();
            showDialog(
              context: context,
              builder: (context) => PdfReaderSettingDialog(
                config: pdfConfig,
                onApply: (config) {
                  pdfConfig = config;
                  _initConfig();
                },
              ),
            );
          },
        ),
      ],
    );
  }

  void _onBackpress() async {
    if (!pdfConfig.isOnBackpressConfirm) return;

    showDialog(
      context: context,
      builder: (dialogContext) => TConfirmDialog(
        contentText: 'အပြင်ထွက်ချင်ပါသလား?',
        submitText: 'ထွက်မယ်',
        cancelText: 'မထွက်ဘူး',
        onSubmit: () {
          isCanGoBack = true;
          setState(() {});
          context.closeNavigator();
        },
      ),
    );
  }
}
