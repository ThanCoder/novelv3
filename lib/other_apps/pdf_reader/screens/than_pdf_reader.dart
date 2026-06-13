import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/other_apps/pdf_reader/pdf_reader.dart';
import 'package:t_client/t_client.dart';
import 'package:t_pdf_reader/t_pdf_reader.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ThanPdfReader extends StatefulWidget {
  final String path;
  final PdfConfig pdfConfig;
  final String? bookmarkPath;
  final void Function(PdfConfig savedConfig)? onConfigUpdated;
  const ThanPdfReader({
    super.key,
    required this.path,
    required this.pdfConfig,
    this.onConfigUpdated,
    this.bookmarkPath,
  });

  @override
  State<ThanPdfReader> createState() => _ThanPdfReaderState();
}

class _ThanPdfReaderState extends State<ThanPdfReader> {
  @override
  void initState() {
    config = widget.pdfConfig;
    super.initState();
    _initConfig();
    init();
  }

  @override
  void dispose() {
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    if (Platform.isAndroid) {
      ThanPkg.android.app.toggleKeepScreenOn(isKeep: false);
      ThanPkg.android.app.requestOrientation(
        type: ScreenOrientationTypes.portrait,
      );
    }
    _saveConfig();
    super.dispose();
  }

  void init() {
    pdfController.onLoaded.listen((event) {
      pdfController.jumpToPage(widget.pdfConfig.page);
      pdfController.setZoom(widget.pdfConfig.zoom);

      if (!mounted) return;
      showTSnackBar(
        context,
        'Pdf Loaded Time: ${event.loadedElapsedTime.toAutoTimeLabel()}',
        showCloseIcon: true,
      );
    });
    if (Platform.isAndroid) {
      ThanPkg.android.app.toggleKeepScreenOn(isKeep: true);
    }
  }

  final pdfController = TPdfControllerV3(
    customScrollbar: (context, pageIndex) =>
        TCustomScrollbarWidget.ui3(pageIndex),
  );
  late PdfConfig config;
  bool isScaleEnable = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: config.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: config.isFullscreen
            ? null
            : AppBar(title: Text(widget.path.split('/').last)),
        endDrawer: widget.bookmarkPath == null
            ? null
            : PdfBookmarkDrawer(
                bookmarkPath: widget.bookmarkPath!,
                getCurrentPage: () => pdfController.currentPage,
                onClicked: (pageIndex) {
                  pdfController.jumpToPage(pageIndex);
                  // print('page: $pageIndex');
                },
              ),
        body: Stack(
          children: [
            Positioned.fill(
              top: config.isFullscreen ? 0 : 40,
              child: ClipRRect(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    config.isDarkMode ? BlendMode.difference : BlendMode.dst,
                  ),
                  child: GestureDetector(
                    onDoubleTap: () {
                      if (!config.isFullscreen) return;
                      config = config.copyWith(isFullscreen: false);
                      setState(() {});
                      ThanPkg.platform.toggleFullScreen(isFullScreen: false);
                    },
                    child: Container(
                      color: Colors.white,
                      width: double.infinity,
                      height: double.infinity,
                      child: TPdfReaderV3(
                        source: widget.path,
                        controller: pdfController,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!config.isFullscreen)
              Positioned(left: 0, right: 0, top: 0, child: _header),
          ],
        ),
      ),
    );
  }

  Widget get _header => Theme(
    data: config.isDarkMode ? ThemeData.dark() : ThemeData.light(),
    child: Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            spacing: 6,
            children: [
              SizedBox(width: 10),
              InkWell(
                mouseCursor: SystemMouseCursors.click,
                onTap: _showGoToPageDialog,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: StreamBuilder(
                    stream: pdfController.onPageChanged,
                    builder: (context, asyncSnapshot) {
                      return Text(
                        '${pdfController.currentPage}/${pdfController.totalPages}',
                        style: TextStyle(color: Colors.teal),
                      );
                    },
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  config = config.copyWith(isDarkMode: !config.isDarkMode);
                  setState(() {});
                },
                icon: Icon(
                  config.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                ),
              ),
              StreamBuilder(
                stream: pdfController.onZoomChanged,
                builder: (context, asyncSnapshot) {
                  return Text(
                    'Z: ${(pdfController.currentZoom * 100).toInt()}%',
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.zoom_out),
                onPressed: () => pdfController.setZoom(
                  pdfController.currentZoom - 0.2,
                ), // ၂၅% လျှော့မယ်
              ),
              IconButton(
                icon: Icon(Icons.zoom_in),
                onPressed: () => pdfController.setZoom(
                  pdfController.currentZoom + 0.2,
                ), // ၂၅% တိုးမယ်
              ),
              IconButton(
                onPressed: () {
                  config = config.copyWith(isFullscreen: !config.isFullscreen);

                  ThanPkg.platform.toggleFullScreen(
                    isFullScreen: config.isFullscreen,
                  );
                  setState(() {});
                },
                icon: Icon(
                  config.isFullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                ),
              ),
              ListenableBuilder(
                listenable: pdfController,
                builder: (context, child) => IconButton(
                  onPressed: () {
                    isScaleEnable = !isScaleEnable;
                    pdfController.setOffsetXAutoLockedEnable(!isScaleEnable);
                    pdfController.setOffsetXLocked(!isScaleEnable);
                    config = config.copyWith(isLockScreen: !isScaleEnable);
                  },
                  icon: Icon(!isScaleEnable ? Icons.lock : Icons.lock_open),
                ),
              ),
              ListenableBuilder(
                listenable: pdfController,
                builder: (context, child) => IconButton(
                  onPressed: () {
                    pdfController.setShowScrollbar(
                      !pdfController.isShowScrollbar,
                    );
                    config = config.copyWith(
                      isShowScrollThumb: pdfController.isShowScrollbar,
                    );
                  },
                  icon: Icon(
                    pdfController.isShowScrollbar
                        ? Icons.unfold_less
                        : Icons.unfold_more_rounded,
                  ),
                ),
              ),
              //setting
              IconButton(
                onPressed: _showSetting,
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _showGoToPageDialog() {
    showTReanmeDialog(
      context,
      text: pdfController.currentPage.toString(),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputType: TextInputType.number,
      submitText: 'Go To Page',
      onCheckIsError: (text) {
        final number = int.tryParse(text);
        if (number == null) return 'Page Number is Required!';
        if (number == 0) return 'Page Number Start 1';
        if (number > pdfController.totalPages) {
          return 'Page: `$number` > Total: `${pdfController.totalPages}`';
        }
        return null;
      },
      onSubmit: (text) {
        pdfController.jumpToPage(int.parse(text));
      },
    );
  }

  // setting
  void _showSetting() {
    showDialog(
      context: context,
      builder: (context) => PdfReaderSettingDialog(
        config: config,
        onApply: (changedConfig) {
          config = changedConfig;
          setState(() {});
          _saveConfig();
          _initConfig();
        },
      ),
    );
  }

  void _saveConfig() {
    try {
      widget.onConfigUpdated?.call(
        config.copyWith(
          isShowScrollThumb: pdfController.isShowScrollbar,
          page: pdfController.currentPage,
          zoom: pdfController.currentZoom,
          readerOffsetX: pdfController.currentReaderOffsetX,
        ),
      );
    } catch (e) {
      PdfReader.showDebugLog(
        e.toString(),
        tag: 'PdfrxReaderScreen:_saveConfig',
      );
    }
  }

  void _initConfig() async {
    try {
      // inif config
      isScaleEnable = !config.isLockScreen;
      pdfController.setOffsetXAutoLockedEnable(!isScaleEnable);
      pdfController.setOffsetXLocked(!isScaleEnable);
      pdfController.setShowScrollbar(config.isShowScrollThumb);
      setState(() {});

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
    } catch (e) {
      PdfReader.showDebugLog(
        e.toString(),
        tag: 'PdfrxReaderScreen:_initConfig',
      );
    }
  }
}
