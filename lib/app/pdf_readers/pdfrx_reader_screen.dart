import 'dart:io';

import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:window_manager/window_manager.dart';

import '../dialogs/index.dart';
import '../notifiers/app_notifier.dart';
import '../widgets/index.dart';
import 'pdf_config_model.dart';
import 'pdf_reader_setting_dialog.dart';

class PdfrxReaderScreen extends StatefulWidget {
  PdfConfigModel pdfConfig;
  String sourcePath;
  String title;
  void Function(PdfConfigModel pdfConfig)? saveConfig;
  PdfrxReaderScreen({
    super.key,
    required this.pdfConfig,
    required this.sourcePath,
    this.saveConfig,
    this.title = 'PDF Reader',
  });

  @override
  State<PdfrxReaderScreen> createState() => _PdfrxReaderScreenState();
}

class _PdfrxReaderScreenState extends State<PdfrxReaderScreen>
    with WindowListener {
  PdfViewerController pdfController = PdfViewerController();
  bool isLoading = true;
  int currentPage = 1;
  int pageCount = 0;
  bool initCalled = false;
  bool isFullScreen = false;
  late PdfConfigModel config;
  double oldZoom = 0;
  double oldOffsetX = 0;
  double oldOffsetY = 0;
  int oldPage = 1;

  @override
  void initState() {
    windowManager.addListener(this);
    config = widget.pdfConfig;
    oldPage = config.page;
    oldZoom = config.zoom;
    oldOffsetX = config.offsetDx;
    oldOffsetY = config.offsetDy;
    super.initState();
  }

  //pdf loaded
  void onPdfLoaded() async {
    try {
      //set offset
      final newOffset = Offset(oldOffsetX, oldOffsetY);
      if (oldZoom != 0 && oldOffsetX != 0 && oldOffsetY != 0) {
        pdfController.setZoom(newOffset, oldZoom);
        //delay
        await Future.delayed(const Duration(milliseconds: 800));
        goPage(oldPage);
      } else {
        goPage(oldPage);
      }

      // pdfController.
      setState(() {
        isLoading = false;
      });
      _initConfig();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('onPdfLoaded: ${e.toString()}');
    }
  }

  void _initConfig() {
    if (Platform.isAndroid) {
      //keep screen
      ThanPkg.android.app.toggleKeepScreenOn(isKeep: config.isKeepScreen);
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

  void _onKeyboradPressed(KeyEvent ev) {
    if (ev is KeyDownEvent) {
      String? keyName = ev.logicalKey.debugName;
      if (keyName != null && keyName.isNotEmpty) {
        _keySwitch(keyName);
      }
    }
  }

  void _keySwitch(String kName) {
    switch (kName) {
      case 'Arrow Right':
        if (currentPage <= pageCount) {
          goPage(currentPage + 1);
        }
        break;
      case 'Arrow Left':
        if (currentPage > 0) {
          goPage(currentPage - 1);
        }
        break;
      case 'Key F':
        _toggleFullScreen(!isFullScreen);

        break;
      case 'Arrow Up':
        break;
      case 'Arrow Down':
        break;
    }
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
    await ThanPkg.platform.toggleFullScreen(isFullScreen: isFullScreen);
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
          setState(() {});
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
        onViewerReady: (document, controller) {
          onPdfLoaded();
        },
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
                if (!isFullScreen) {
                  CherryToast.info(
                    inheritThemeColors: true,
                    title: const Text('Double Tap Is Exist FullScreen!'),
                  ).show(context);
                }
                _toggleFullScreen(!isFullScreen);
              },
              icon:
                  Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
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
    if (widget.sourcePath.isEmpty) return SizedBox.shrink();
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

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
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
      // endDrawer: PdfBookMarkListDrawer(
      //   pdfFile: widget.pdfFile,
      //   currentPage: currentPage,
      //   onClick: (pageIndex) {
      //     goPage(pageIndex);
      //   },
      // ),
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: _onKeyboradPressed,
        child: GestureDetector(
          onDoubleTap: () => _toggleFullScreen(!isFullScreen),
          onSecondaryTap: _showSetting,
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
    _saveConfig();
    if (Platform.isAndroid) {
      ThanPkg.android.app.toggleKeepScreenOn(isKeep: false);
      ThanPkg.android.app.hideFullScreen();
    }
    windowManager.removeListener(this);
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }
}
