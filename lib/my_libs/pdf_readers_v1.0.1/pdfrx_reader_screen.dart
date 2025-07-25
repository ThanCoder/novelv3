import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/setting/app_notifier.dart';
import 'package:novel_v3/my_libs/pdf_readers_v1.0.1/pdf_bookmark_drawer.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:t_widgets/widgets/t_loader.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../app/dialogs/index.dart';
import 'pdf_config_model.dart';
import 'pdf_reader_setting_dialog.dart';

class PdfrxReaderScreen extends StatefulWidget {
  PdfConfigModel pdfConfig;
  String sourcePath;
  String title;
  void Function(PdfConfigModel pdfConfig)? saveConfig;
  String? bookmarkPath;
  PdfrxReaderScreen({
    super.key,
    required this.pdfConfig,
    required this.sourcePath,
    this.saveConfig,
    this.title = 'PDF Reader',
    this.bookmarkPath,
  });

  @override
  State<PdfrxReaderScreen> createState() => _PdfrxReaderScreenState();
}

class _PdfrxReaderScreenState extends State<PdfrxReaderScreen> {
  PdfViewerController pdfController = PdfViewerController();
  final keyboardListenerFocus = FocusNode();
  bool isLoading = true;
  int currentPage = 1;
  int pageCount = 0;
  bool initCalled = false;
  late PdfConfigModel config;
  double oldZoom = 0;
  double oldOffsetX = 0;
  double oldOffsetY = 0;
  int oldPage = 1;
  bool isCanGoBack = true;
  int delayMiliSec = 200;

  @override
  void initState() {
    keyboardListenerFocus.requestFocus();
    config = widget.pdfConfig;
    oldPage = config.page;
    oldZoom = config.zoom;
    oldOffsetX = config.offsetDx;
    oldOffsetY = config.offsetDy;
    super.initState();
    _initConfig();
  }

  @override
  void dispose() {
    keyboardListenerFocus.dispose();
    _close();
    super.dispose();
  }

  //pdf loaded
  void onPdfLoaded() async {
    try {
      //set offset
      // await Future.delayed(const Duration(milliseconds: 1200));

      if (oldZoom != 0 && oldOffsetX != 0 && oldOffsetY != 0) {
        await pdfController.goToPage(pageNumber: oldPage);

        final newOffset = Offset(oldOffsetX, pdfController.centerPosition.dy);
        await pdfController.setZoom(newOffset, oldZoom);
      }
      // config page changed
      else if (oldZoom != 0 && oldOffsetX != 0 && oldOffsetY == 0) {
        await pdfController.goToPage(pageNumber: oldPage);
        // offset ပြန်ရယူ
        final newOffset = Offset(oldOffsetX, pdfController.centerPosition.dy);
        await pdfController.setZoom(newOffset, oldZoom);
        // print('set 2');
      } else {
        // await pdfController.goToPage(pageNumber: oldPage);
        await goPage(oldPage);
      }

      await ThanPkg.platform
          .toggleFullScreen(isFullScreen: config.isFullscreen);

      // pdfController.
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
        pageCount = pdfController.pageCount;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint('onPdfLoaded error: ${e.toString()}');
    }
  }

  void _initConfig() async {
    try {
      if (Platform.isAndroid) {
        await ThanPkg.android.app
            .toggleKeepScreenOn(isKeep: config.isKeepScreen);
        await ThanPkg.android.app.requestOrientation(
          type: ScreenOrientationTypesExtension.getType(
            config.screenOrientation,
          ),
        );
        if (config.screenOrientation == ScreenOrientationTypes.Landscape.name) {
          //full screen
          await ThanPkg.android.app.showFullScreen();
        }
      }
      setState(() {
        isCanGoBack = !config.isOnBackpressConfirm;
      });
    } catch (e) {
      debugPrint('_initConfig: ${e.toString()}');
    }
  }

  //go page
  Future<void> goPage(int pageNum) async {
    try {
      double oldZoom = pdfController.currentZoom;

      await pdfController.goToPage(pageNumber: pageNum);
      Offset oldOffset = pdfController.centerPosition;
      // delay
      await Future.delayed(Duration(milliseconds: delayMiliSec));
      await pdfController.setZoom(oldOffset, oldZoom);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showGoToDialog() {
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        text: currentPage.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputType: TextInputType.number,
        renameLabelText: Text('Go To Page Range(1-$pageCount)'),
        onCheckIsError: (text) {
          int num = int.tryParse(text) ?? 0;
          if (num > pageCount) {
            return 'page number ကျော်လွန်နေပါတယ်';
          }
          return null;
        },
        submitText: 'Go',
        onCancel: () {},
        onSubmit: (text) {
          if (text.isEmpty || text == '0') return;
          try {
            goPage(int.parse(text));
          } catch (e) {
            debugPrint(e.toString());
          }
        },
      ),
    );
  }

  void _setFullScreen(bool isFull) async {
    if (isLoading) return;
    if (config.isFullscreen == isFull) return;
    config.isFullscreen = isFull;
    double oldZoom = pdfController.currentZoom;
    Offset oldOffset = pdfController.centerPosition;

    setState(() {});
    await ThanPkg.platform.toggleFullScreen(isFullScreen: isFull);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: delayMiliSec));
      await pdfController.setZoom(oldOffset, oldZoom);
    });
  }

  void _showSetting() {
    showDialog(
      context: context,
      builder: (context) => PdfReaderSettingDialog(
        config: config,
        onApply: (changedConfig) {
          config = changedConfig;
          _saveConfig();
          _initConfig();
        },
      ),
    );
  }

  PdfViewerParams getParams() => PdfViewerParams(
        margin: 0,
        scrollByMouseWheel: config.scrollByMouseWheel,
        scaleEnabled: config.isPanLocked == false,
        panAxis: config.isPanLocked ? PanAxis.vertical : PanAxis.free,
        enableTextSelection: config.isTextSelection,
        pageDropShadow: null,
        useAlternativeFitScaleAsMinScale: false,
        scrollByArrowKey: config.scrollByArrowKey,
        enableKeyboardNavigation: true,
        onKey: (params, key, isRealKeyPress) {
          if (key.keyLabel == 'F') {
            _setFullScreen(!config.isFullscreen);
            return false;
          }
          return null;
        },
        //error
        errorBannerBuilder: (context, error, stackTrace, documentRef) {
          return const Center(child: Text('pdf error'));
        },
        //loading
        loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
          return Center(
            child: TLoader(
              isDarkMode: config.isDarkMode,
            ),
          );
        },
        //page changed
        onPageChanged: (pageNumber) {
          try {
            final offset = pdfController.centerPosition;
            config.zoom = pdfController.currentZoom;
            config.offsetDx = offset.dx;
            config.offsetDy = offset.dy;
            // print('z:${config.zoom}-x:${config.offsetDx}-y:${config.offsetDy}');
            setState(() {
              currentPage = pageNumber ?? 1;
              pageCount = pdfController.pageCount;
            });
          } catch (e) {
            debugPrint('onPageChanged: ${e.toString()}');
          }
        },
        //pdf ready
        onViewerReady: (document, controller) => onPdfLoaded(),

        viewerOverlayBuilder: config.isShowScrollThumb
            ? (context, size, handleLinkTap) => [
                  // Add vertical scroll thumb on viewer's right side
                  PdfViewerScrollThumb(
                    controller: pdfController,
                    orientation: ScrollbarOrientation.right,
                    thumbSize: const Size(50, 25),
                    thumbBuilder:
                        (context, thumbSize, pageNumber, controller) =>
                            Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      // Show page number on the thumb
                      child: Center(
                        child: Text(
                          pageNumber.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]
            : null,
      );

  Widget _getHeaderWidgets() {
    if (config.isFullscreen) {
      return const SizedBox.shrink();
    }
    return Container(
      color: appConfigNotifier.value.isDarkTheme ? Colors.black : Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //page number
            TextButton(
              onPressed: () {
                _showGoToDialog();
              },
              child: Text('$currentPage/$pageCount'),
            ),
            //theme mode
            IconButton(
              onPressed: () {
                setState(() {
                  config.isDarkMode = !config.isDarkMode;
                });
              },
              icon:
                  Icon(config.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
            //pan axis lock
            IconButton(
              onPressed: () {
                setState(() {
                  config.isPanLocked = !config.isPanLocked;
                });
              },
              icon: Icon(
                config.isPanLocked ? Icons.lock : Icons.lock_open,
              ),
            ),
            //zoom
            IconButton(
              onPressed: () {
                pdfController.zoomDown();
              },
              icon: const Icon(Icons.zoom_out),
            ),
            IconButton(
              onPressed: () {
                pdfController.zoomUp();
              },
              icon: const Icon(Icons.zoom_in),
            ),
            //full screen
            IconButton(
              onPressed: () {
                if (isLoading) return;
                if (!config.isFullscreen) {
                  CherryToast.info(
                    inheritThemeColors: true,
                    title: const Text('Double Tap Is Exist FullScreen!'),
                  ).show(context);
                }
                _setFullScreen(!config.isFullscreen);
              },
              icon: Icon(config.isFullscreen
                  ? Icons.fullscreen_exit
                  : Icons.fullscreen),
            ),
            //setting
            IconButton(
              onPressed: _showSetting,
              icon: const Icon(Icons.more_vert),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentPdfReader() {
    if (widget.sourcePath.isEmpty) {
      return const Center(child: Text('Path Not Found!'));
    }
    if (widget.sourcePath.startsWith('http')) {
      //is online
      return PdfViewer.uri(
        Uri.parse(widget.sourcePath),
        controller: pdfController,
        params: getParams(),
      );
    } else {
      return PdfViewer.file(
        widget.sourcePath,
        controller: pdfController,
        params: getParams(),
      );
    }
  }

  Widget _getColorFilteredPdfReader() {
    return Column(
      children: [
        SizedBox(height: config.isFullscreen ? 0 : 40),
        Expanded(
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.white,
              config.isDarkMode ? BlendMode.difference : BlendMode.dst,
            ),
            child: _getCurrentPdfReader(),
          ),
        ),
      ],
    );
  }

  void _onBackpress() async {
    _saveConfig();
    if (!isCanGoBack) {
      showDialog(
        context: context,
        builder: (context) => ConfirmDialog(
          contentText: 'အပြင်ထွက်ချင်ပါသလား?',
          submitText: 'ထွက်မယ်',
          cancelText: 'မထွက်ဘူး',
          onCancel: () {},
          onSubmit: () {
            isCanGoBack = true;
            setState(() {});
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  //save config
  void _saveConfig() {
    try {
      //loading လုပ်နေရင် မသိမ်းဆည်းဘူး
      if (isLoading) return;
      config.page = currentPage;
      if (widget.saveConfig != null) {
        widget.saveConfig!(config);
      }
    } catch (e) {
      debugPrint('saveConfig: ${e.toString()}');
    }
  }

  void _close() async {
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
    if (Platform.isAndroid) {
      ThanPkg.android.app
          .requestOrientation(type: ScreenOrientationTypes.Portrait);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isCanGoBack,
      onPopInvokedWithResult: (didPop, result) {
        _onBackpress();
      },
      child: Scaffold(
        appBar: config.isFullscreen
            ? null
            : AppBar(
                title: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
        endDrawer: widget.bookmarkPath == null
            ? null
            : PdfBookmarkDrawer(
                bookmarkPath: widget.bookmarkPath!,
                currentPage: currentPage,
                onClicked: (pageIndex) {
                  goPage(pageIndex);
                },
              ),
        body: GestureDetector(
          onDoubleTap: () => _setFullScreen(!config.isFullscreen),
          onSecondaryTap: _showSetting,
          onLongPress: config.isTextSelection ? null : () => _showSetting(),
          child: Stack(
            children: [
              _getColorFilteredPdfReader(),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _getHeaderWidgets(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
