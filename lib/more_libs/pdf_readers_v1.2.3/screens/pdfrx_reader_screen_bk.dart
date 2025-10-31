import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';
import 'package:than_pkg/than_pkg.dart';

import '../pdf_reader.dart';

class PdfrxReaderScreenBk extends StatefulWidget {
  PdfConfig pdfConfig;
  String sourcePath;
  String title;
  void Function(PdfConfig pdfConfig)? onConfigUpdated;
  String? bookmarkPath;
  PdfrxReaderScreenBk({
    super.key,
    required this.sourcePath,
    required this.pdfConfig,
    this.onConfigUpdated,
    this.title = 'PDF Reader',
    this.bookmarkPath,
  });

  @override
  State<PdfrxReaderScreenBk> createState() => _PdfrxReaderScreenBkState();
}

class _PdfrxReaderScreenBkState extends State<PdfrxReaderScreenBk> {
  PdfViewerController pdfController = PdfViewerController();
  PdfViewerController? loadedPdfController;
  final keyboardListenerFocus = FocusNode();
  bool isLoading = true;
  int currentPage = 1;
  int oldPageNumber = 0;
  int pageCount = 0;
  bool initCalled = false;
  int delayMiliSec = 200;
  bool isCanGoBack = true;
  late PdfConfig config;
  late final PdfViewer pdfViewer;

  @override
  void initState() {
    // set config
    config = widget.pdfConfig;
    oldPageNumber = config.page;
    pdfViewer = _getPdfViewer();
    super.initState();
    keyboardListenerFocus.requestFocus();

    _initConfig();
  }

  @override
  void dispose() {
    keyboardListenerFocus.dispose();
    _close();
    super.dispose();
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
                title: Text(widget.title, style: const TextStyle(fontSize: 11)),
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
        body: Stack(
          children: [
            _getColorFilteredPdfReader(),
            Positioned(top: 0, left: 0, right: 0, child: _getHeaderWidgets()),
          ],
        ),
      ),
    );
  }

  PdfViewer _getPdfViewer() {
    if (widget.sourcePath.startsWith('http')) {
      //is online
      return PdfViewer.uri(
        Uri.parse(widget.sourcePath),
        controller: pdfController,
        params: getParams(),
        // initialPageNumber: currentPage,
      );
    } else {
      return PdfViewer.file(
        widget.sourcePath,
        controller: pdfController,
        params: getParams(),
        // initialPageNumber: currentPage,
      );
    }
  }

  Widget _getCurrentPdfReader() {
    if (widget.sourcePath.isEmpty) {
      return const Center(child: Text('Path Not Found!'));
    }
    return pdfViewer;
    // return _getPdfViewer();
  }

  PdfViewerParams getParams() => PdfViewerParams(
    margin: 0,
    scrollByMouseWheel: config.scrollByMouseWheel,
    scaleEnabled: true, // config.isPanLocked == false,
    panAxis: PanAxis
        .vertical, //config.isPanLocked ? PanAxis.vertical : PanAxis.free,
    textSelectionParams: PdfTextSelectionParams(
      enabled: config.isTextSelection,
    ),
    pageDropShadow: null,
    useAlternativeFitScaleAsMinScale: false,
    scrollByArrowKey: config.scrollByArrowKey,
    enableKeyboardNavigation: true,
    onGeneralTap: (context, controller, details) {
      if (details.type == PdfViewerGeneralTapType.doubleTap) {
        _setFullScreen(!config.isFullscreen);
      }
      if (details.type == PdfViewerGeneralTapType.longPress) {
        _showSetting();
      }
      if (details.type == PdfViewerGeneralTapType.secondaryTap) {
        _showSetting();
      }
      return true;
    },
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
      return Center(child: TLoader.random(isDarkMode: config.isDarkMode));
    },
    //pdf ready
    onViewerReady: (document, controller) {
      if (!initCalled) {
        loadedPdfController = controller;
        _onPdfLoaded();
        initCalled = true;
      }
    },
    onViewSizeChanged: (viewSize, oldViewSize, controller) {
      final offset = pdfController.centerPosition;
      config = config.copyWith(
        zoom: pdfController.currentZoom,
        offsetDx: offset.dx,
      );
    },
    //page changed
    onPageChanged: onPdfPageChanged,
    viewerOverlayBuilder: config.isShowScrollThumb
        ? (context, size, handleLinkTap) => [
            // Add vertical scroll thumb on viewer's right side
            PdfViewerScrollThumb(
              controller: pdfController,
              orientation: ScrollbarOrientation.right,
              thumbSize: const Size(50, 25),
              thumbBuilder: (context, thumbSize, pageNumber, controller) =>
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
    pageOverlaysBuilder: (context, pageRect, page) {
      return [
        Align(
          alignment: Alignment.bottomCenter,
          child: Text(
            page.pageNumber.toString(),
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ];
    },
  );

  Widget _getHeaderWidgets() {
    if (config.isFullscreen) {
      return const SizedBox.shrink();
    }
    return Container(
      color: PdfReader.instance.getDarkTheme() ? Colors.black : Colors.white,
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
                config = config.copyWith(isDarkMode: !config.isDarkMode);
                setState(() {});
              },
              icon: Icon(
                config.isDarkMode ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
            //pan axis lock
            // IconButton(
            //   onPressed: () {
            //     config = config.copyWith(isPanLocked: !config.isPanLocked);
            //     setState(() {});
            //   },
            //   icon: Icon(config.isPanLocked ? Icons.lock : Icons.lock_open),
            // ),
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
                  PdfReader.instance.showAutoMessage(
                    context,
                    'Double Tap Is Exist FullScreen!',
                  );
                }
                _setFullScreen(!config.isFullscreen);
              },
              icon: Icon(
                config.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              ),
            ),

            //setting
            IconButton(
              onPressed: _showSetting,
              icon: const Icon(Icons.more_vert),
            ),
            currentPage == oldPageNumber
                ? SizedBox.shrink()
                : IconButton(
                    onPressed: _checkConfigPageIndex,
                    icon: Icon(Icons.confirmation_num_sharp),
                  ),
          ],
        ),
      ),
    );
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

  //pdf loaded
  void _onPdfLoaded() async {
    try {
      await Future.delayed(Duration(milliseconds: 1200));

      setState(() {
        isLoading = false;
      });

      pageCount = pdfController.pageCount;
      final oldConfig = widget.pdfConfig.copyWith();

      if (oldConfig.zoom != 0 && oldConfig.offsetDx != 0) {
        await pdfController.goToPage(pageNumber: oldConfig.page);

        final newOffset = Offset(
          pdfController.centerPosition.dx, //oldConfig.offsetDx,
          pdfController.centerPosition.dy,
        );
        await pdfController.setZoom(newOffset, oldConfig.zoom);
        // test
        await Future.delayed(Duration(milliseconds: 1200));
        if (currentPage != oldConfig.page) {
          _onPdfLoaded();
        }
      } else {
        await goPage(oldConfig.page);
        // test
        await Future.delayed(Duration(milliseconds: 1200));
        if (currentPage != oldConfig.page) {
          _onPdfLoaded();
        }
      }

      // pdfController.
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      isLoading = false;
      if (!mounted) return;
      setState(() {});
      PdfReader.showDebugLog(
        e.toString(),
        tag: 'PdfrxReaderScreenBk:onPdfLoaded',
      );
    }
  }

  void onPdfPageChanged(int? pageNumber) {
    try {
      if ((pageNumber ?? 1) == currentPage) return;

      final offset = pdfController.centerPosition;
      config = config.copyWith(
        zoom: pdfController.currentZoom,
        offsetDx: offset.dx,
        // offsetDy: offset.dy,
      );

      currentPage = pageNumber ?? 1;
      pageCount = pdfController.pageCount;
      setState(() {});
    } catch (e) {
      debugPrint('onPageChanged: ${e.toString()}');
    }
  }

  void _initConfig() async {
    try {
      if (Platform.isAndroid) {
        await ThanPkg.android.app.toggleKeepScreenOn(
          isKeep: config.isKeepScreen,
        );
        await ThanPkg.android.app.requestOrientation(
          type: config.screenOrientation,
        );
        if (config.screenOrientation == ScreenOrientationTypes.landscape) {
          //full screen
          await ThanPkg.android.app.showFullScreen();
        }
      }
      await ThanPkg.platform.toggleFullScreen(
        isFullScreen: config.isFullscreen,
      );
      setState(() {
        isCanGoBack = !config.isOnBackpressConfirm;
      });
    } catch (e) {
      PdfReader.showDebugLog(
        e.toString(),
        tag: 'PdfrxReaderScreenBk:_initConfig',
      );
    }
  }

  //go page
  Future<void> goPage(int pageNumber) async {
    try {
      var controller = pdfController;
      if (loadedPdfController != null) {
        controller = loadedPdfController!;
      }
      double oldZoom = controller.currentZoom;

      await controller.goToPage(pageNumber: pageNumber);
      Offset oldOffset = controller.centerPosition;
      // delay
      await Future.delayed(Duration(milliseconds: delayMiliSec));
      await controller.setZoom(oldOffset, oldZoom);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _showGoToDialog() {
    showDialog(
      context: context,
      builder: (context) => TRenameDialog(
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
            if (TPlatform.isMobile) {
              Future.delayed(Duration(milliseconds: 900)).then((e) {
                goPage(int.parse(text));
              });
            } else {
              goPage(int.parse(text));
            }
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
    config = config.copyWith(isFullscreen: isFull);
    double oldZoom = pdfController.currentZoom;
    Offset oldOffset = pdfController.centerPosition;

    setState(() {});
    await ThanPkg.platform.toggleFullScreen(isFullScreen: isFull);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: delayMiliSec));
      await pdfController.setZoom(oldOffset, oldZoom);
    });
  }

  // setting
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

  void _onBackpress() async {
    if (!isCanGoBack) {
      showDialog(
        context: context,
        builder: (context) => TConfirmDialog(
          contentText: 'အပြင်ထွက်ချင်ပါသလား?',
          submitText: 'ထွက်မယ်',
          cancelText: 'မထွက်ဘူး',
          onCancel: () {},
          onSubmit: () {
            isCanGoBack = true;
            setState(() {});
            Navigator.pop(context);
            _saveConfig();
          },
        ),
      );
    } else {
      _saveConfig();
    }
  }

  //save config
  void _saveConfig() {
    try {
      //loading လုပ်နေရင် မသိမ်းဆည်းဘူး
      if (isLoading) return;
      if (oldPageNumber == currentPage) {
        debugPrint('Pdf Config Not Save');
        return;
      }

      if (widget.onConfigUpdated != null) {
        widget.onConfigUpdated!(config.copyWith(page: currentPage));
      }
    } catch (e) {
      PdfReader.showDebugLog(
        e.toString(),
        tag: 'PdfrxReaderScreenBk:_saveConfig',
      );
    }
  }

  void _close() async {
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    ThanPkg.platform.toggleKeepScreen(isKeep: false);
    if (Platform.isAndroid) {
      ThanPkg.android.app.requestOrientation(
        type: ScreenOrientationTypes.portrait,
      );
    }
  }

  // old page == new page
  void _checkConfigPageIndex() {
    if (currentPage == oldPageNumber) {
      return;
    }
    showTConfirmDialog(
      context,
      contentText:
          'ယခု Page: $currentPage\nConfig Page: $oldPageNumber\nPage အဟောင်းကို ပြန်သွားချင်ပါသလား?',
      submitText: 'Go Config Page',
      onSubmit: () {
        goPage(oldPageNumber);
      },
    );
  }
}
