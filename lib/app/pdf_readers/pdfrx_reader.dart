import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/pdf_readers/pdf_reader_config_action_component.dart';
import 'package:novel_v3/app/dialogs/confirm_dialog.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/drawers/pdf_book_mark_list_drawer.dart';
import 'package:novel_v3/app/pdf_readers/pdf_config_model.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/app_notifier.dart';
import 'package:novel_v3/app/services/core/app_services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:than_pkg/enums/screen_orientation_types.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:window_manager/window_manager.dart';

import '../widgets/index.dart';

class PdfrxReader extends StatefulWidget {
  PdfConfigModel? pdfConfig;
  String sourcePath;
  String title;
  void Function(PdfConfigModel pdfConfig)? saveConfig;
  PdfrxReader({
    super.key,
    this.pdfConfig,
    required this.sourcePath,
    required this.title,
    this.saveConfig,
  });

  @override
  State<PdfrxReader> createState() => _PdfrxReaderState();
}

class _PdfrxReaderState extends State<PdfrxReader> with WindowListener {
  PdfViewerController pdfController = PdfViewerController();
  bool isLoading = true;
  int currentPage = 1;
  int pageCount = 0;
  bool isInitCalled = false;
  late PdfConfigModel config;
  bool isFullScreen = false;
  bool isCanGoBack = true;

  @override
  void initState() {
    windowManager.addListener(this);
    if (widget.pdfConfig != null) {
      config = widget.pdfConfig!;
    } else {
      config = PdfConfigModel();
    }
    super.initState();
    _initConfig();
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

  //pdf loaded
  void onPdfLoaded(PdfDocument document, PdfViewerController controller) async {
    try {
      //set offset
      final newOffset = Offset(config.offsetDx, config.offsetDy);
      if (config.zoom != 0 && config.offsetDx != 0 && config.offsetDy != 0) {
        pdfController.setZoom(newOffset, config.zoom);
        //delay
        await Future.delayed(const Duration(milliseconds: 800));
        goPage(config.page);
      } else {
        goPage(config.page);
      }

      if (!mounted) return;
      // pdfController.
      setState(() {
        isLoading = false;
        isInitCalled = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isInitCalled = true;
      });
      debugPrint('onPdfLoaded: ${e.toString()}');
    }
  }

  // page change အရင်အခေါ်တယ်
  void _onPdfPageChanged(int? pageNumber) {
    try {
      setState(() {
        currentPage = pageNumber ?? 1;
        pageCount = pdfController.pageCount;
      });
      //init call ပြီးမှ
      if (!isInitCalled) return;
      final offset = pdfController.centerPosition;
      config.zoom = pdfController.currentZoom;
      config.offsetDx = offset.dx;
      config.offsetDy = offset.dy;
      // print('z:${config.zoom}-x:${config.offsetDx}-y:${config.offsetDy}');
    } catch (e) {
      debugPrint('onPageChanged: ${e.toString()}');
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

  @override
  void onWindowClose() {
    _saveConfig();
    super.onWindowClose();
  }

  //go page
  void goPage(int pageNum) {
    try {
      pdfController.goToPage(pageNumber: pageNum);
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

  void _toggleFullScreen(bool isFull) async {
    setState(() {
      isFullScreen = isFull;
    });
    if (isFull) {
      CherryToast.info(
        inheritThemeColors: true,
        title: const Text('Double Tap Is Exist FullScreen!'),
      ).show(context);
    }
    toggleFullScreenPlatform(isFullScreen);
  }

  //pdf params
  PdfViewerParams getParams() => PdfViewerParams(
        margin: 0,
        scrollByMouseWheel: config.scrollByMouseWheel,
        scaleEnabled: config.isPanLocked == false,
        panAxis: config.isPanLocked ? PanAxis.vertical : PanAxis.free,
        enableTextSelection: config.isTextSelection,
        pageDropShadow: null,
        useAlternativeFitScaleAsMinScale: false,
        //loading
        loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
          return Center(
            child: TLoader(
              isCustomTheme: true,
              isDarkMode: config.isDarkMode,
            ),
          );
        },
        //page changed
        onPageChanged: _onPdfPageChanged,
        //pdf ready
        onViewerReady: onPdfLoaded,
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
    if (isFullScreen) {
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
                _toggleFullScreen(!isFullScreen);
              },
              icon:
                  Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
            ),
            //setting
            PdfReaderConfigActionComponent(
              pdfConfig: config,
              onApply: (_pdfConfig) {
                config = _pdfConfig;
                _saveConfig();
                _initConfig();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentPdfReader() {
    if (widget.sourcePath.startsWith('http')) {
      //is online
      return PdfViewer.uri(
        Uri.parse(widget.sourcePath),
        controller: pdfController,
        params: getParams(),
      );
    } else {
      //offline
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
        SizedBox(height: isFullScreen ? 0 : 40),
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
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: isCanGoBack,
      onPopInvokedWithResult: (didPop, result) {
        _onBackpress();
      },
      child: MyScaffold(
        contentPadding: 0,
        appBar: isFullScreen
            ? null
            : AppBar(
                title: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 11,
                  ),
                ),
              ),
        endDrawer: widget.sourcePath.startsWith('http')
            ? null
            : PdfBookMarkListDrawer(
                pdfFile: PdfFileModel.fromPath(widget.sourcePath),
                currentPage: currentPage,
                onClick: (pageIndex) {
                  goPage(pageIndex);
                },
              ),
        body: GestureDetector(
          onDoubleTap: () {
            isFullScreen = !isFullScreen;
            toggleFullScreenPlatform(isFullScreen);
            setState(() {});
          },
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

  void _close() async {
    windowManager.removeListener(this);
    _saveConfig();
    toggleFullScreenPlatform(false);
    toggleAndroidKeepScreen(false);
    if (Platform.isAndroid) {
      ThanPkg.android.app
          .requestOrientation(type: ScreenOrientationTypes.Portrait);
    }
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }
}
