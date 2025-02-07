import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/drawers/pdf_book_mark_list_drawer.dart';
import 'package:novel_v3/app/models/pdf_config_model.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/services/android_app_services.dart';
import 'package:novel_v3/app/services/app_services.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:window_manager/window_manager.dart';

class PdfrxReader extends StatefulWidget {
  PdfFileModel pdfFile;
  PdfConfigModel? pdfConfig;
  void Function(PdfConfigModel pdfConfig)? saveConfig;
  PdfrxReader({
    super.key,
    required this.pdfFile,
    this.pdfConfig,
    this.saveConfig,
  });

  @override
  State<PdfrxReader> createState() => _PdfrxReaderState();
}

class _PdfrxReaderState extends State<PdfrxReader> {
  bool isDarkMode = false;
  PdfViewerController pdfController = PdfViewerController();
  bool isLoading = true;
  int currentPage = 1;
  int pageCount = 0;
  double scrollByMouseWheel = 1.2;
  bool isPanLocked = false;
  bool showScrollThumb = true;
  bool isFullScreen = false;
  bool initCalled = false;
  late PdfConfigModel pdfConfig;
  double currentZoom = 0;
  double currentOffsetDx = 0;
  double currentOffsetDy = 0;

  @override
  void initState() {
    pdfConfig = PdfConfigModel();
    super.initState();
  }

  //pdf loaded
  void onPdfLoaded() async {
    try {
      if (widget.pdfConfig == null) return;
      pdfConfig = widget.pdfConfig!;
      //go page
      // goPage(pdfConfig.page);
      isDarkMode = pdfConfig.isDarkMode;
      isPanLocked = pdfConfig.isPanLocked;
      showScrollThumb = pdfConfig.isShowScrollThumb;
      //set offset
      final newOffset = Offset(pdfConfig.offsetDx, pdfConfig.offsetDy);
      if (pdfConfig.zoom != 0 &&
          pdfConfig.offsetDx != 0 &&
          pdfConfig.offsetDy != 0) {
        pdfController.setZoom(newOffset, pdfConfig.zoom);
        //delay
        await Future.delayed(const Duration(milliseconds: 600));
        goPage(pdfConfig.page);
      } else {
        goPage(pdfConfig.page);
      }

      // pdfController.
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('onPdfLoaded: ${e.toString()}');
    }
  }

  //save config
  void saveConfig() {
    try {
      pdfConfig.isDarkMode = isDarkMode;
      pdfConfig.isPanLocked = isPanLocked;
      pdfConfig.isShowScrollThumb = showScrollThumb;
      pdfConfig.page = currentPage;
      //zoom
      pdfConfig.zoom = currentZoom;
      //offset

      pdfConfig.offsetDx = currentOffsetDx;
      pdfConfig.offsetDy = currentOffsetDy;

      if (widget.saveConfig != null) {
        widget.saveConfig!(pdfConfig);
      }
    } catch (e) {
      debugPrint('saveConfig: ${e.toString()}');
    }
  }

  void _onKeyboradPressed(RawKeyEvent ev) {
    if (ev is RawKeyDownEvent) {
      String? keyName = ev.logicalKey.debugName;
      if (keyName != null && keyName.isNotEmpty) {
        _keySwitch(keyName);
      }
      // print(ev.logicalKey.debugName);
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
        dialogContext: context,
        renameText: currentPage.toString(),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputType: TextInputType.number,
        renameLabelText: Text('Go To Page Range(1-$pageCount)'),
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
    toggleFullScreenPlatform(isFullScreen);
  }

  PdfViewerParams getParams() => PdfViewerParams(
        margin: 0,
        scrollByMouseWheel: scrollByMouseWheel,
        scaleEnabled: !isPanLocked,
        enableTextSelection: false,
        pageDropShadow: null,
        useAlternativeFitScaleAsMinScale: false,
        panAxis: isPanLocked ? PanAxis.vertical : PanAxis.free,
        //loading
        loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
          return Center(
            child: TLoader(
              isCustomTheme: true,
              isDarkMode: isDarkMode,
            ),
          );
        },
        //page changed
        onPageChanged: (pageNumber) {
          try {
            final offset = pdfController.centerPosition;
            setState(() {
              currentPage = pageNumber ?? 1;
              pageCount = pdfController.pageCount;
              currentZoom = pdfController.currentZoom;
              currentOffsetDx = offset.dx;
              currentOffsetDy = offset.dy;
            });
          } catch (e) {
            debugPrint('onPageChanged: ${e.toString()}');
          }
        },
        //pdf ready
        onViewerReady: (document, controller) {
          onPdfLoaded();
        },
        viewerOverlayBuilder: showScrollThumb
            ? (context, size, handleLinkTap) => [
                  // Add vertical scroll thumb on viewer's right side
                  PdfViewerScrollThumb(
                    controller: pdfController,
                    orientation: ScrollbarOrientation.right,
                    thumbSize: const Size(40, 25),
                    thumbBuilder:
                        (context, thumbSize, pageNumber, controller) =>
                            Container(
                      color: Colors.black,
                      // Show page number on the thumb
                      child: Center(
                        child: Text(
                          pageNumber.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ]
            : null,
      );

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 0,
      appBar: isFullScreen
          ? null
          : AppBar(
              title: Text(
                widget.pdfFile.title,
                style: const TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
      endDrawer: PdfBookMarkListDrawer(
        pdfFile: widget.pdfFile,
        currentPage: currentPage,
        onClick: (pageIndex) {
          goPage(pageIndex);
        },
      ),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _onKeyboradPressed,
        child: GestureDetector(
          onTap: () => _toggleFullScreen(false),
          child: Column(
            children: [
              //header
              !isFullScreen
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
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
                                isDarkMode = !isDarkMode;
                              });
                            },
                            icon: Icon(isDarkMode
                                ? Icons.light_mode
                                : Icons.dark_mode),
                          ),
                          //pan axis lock
                          IconButton(
                            onPressed: () {
                              setState(() {
                                isPanLocked = !isPanLocked;
                              });
                            },
                            icon: Icon(
                              isPanLocked ? Icons.lock : Icons.lock_open,
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
                            icon: Icon(isFullScreen
                                ? Icons.fullscreen_exit
                                : Icons.fullscreen),
                          ),
                          //show scroll thumbnail
                          IconButton(
                            color: showScrollThumb ? activeColor : null,
                            onPressed: () {
                              setState(() {
                                showScrollThumb = !showScrollThumb;
                              });
                            },
                            icon: const Icon(Icons.navigation_rounded),
                          ),
                        ],
                      ),
                    )
                  : Container(),
              // pdf viewer
              Expanded(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    isDarkMode ? BlendMode.difference : BlendMode.dst,
                  ),
                  child: PdfViewer.file(
                    widget.pdfFile.path,
                    controller: pdfController,
                    params: getParams(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void close() async {
    saveConfig();
    if (Platform.isAndroid) {
      toggleAndroidFullScreen(false);
    }
    if (Platform.isLinux) {
      await windowManager.setFullScreen(isFullScreen);
    }
  }

  @override
  void dispose() {
    close();
    super.dispose();
  }
}
