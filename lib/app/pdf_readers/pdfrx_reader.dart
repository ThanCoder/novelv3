import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/components/pdf_reader_config_action_component.dart';
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
  bool isOffline;
  String onlineUrl;
  void Function(PdfConfigModel pdfConfig)? saveConfig;
  PdfrxReader({
    super.key,
    required this.pdfFile,
    this.pdfConfig,
    this.saveConfig,
    this.isOffline = true,
    this.onlineUrl = '',
  });

  @override
  State<PdfrxReader> createState() => _PdfrxReaderState();
}

class _PdfrxReaderState extends State<PdfrxReader> {
  PdfViewerController pdfController = PdfViewerController();
  bool isLoading = true;
  int currentPage = 1;
  int pageCount = 0;
  bool initCalled = false;
  bool isFullScreen = false;
  double currentZoom = 0;
  double currentOffsetDx = 0;
  double currentOffsetDy = 0;
  late PdfConfigModel pdfConfig;

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
      _initConfig();

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

  void _initConfig() {
    //keep screen
    toggleAndroidKeepScreen(pdfConfig.isKeepScreen);
  }

  //save config
  void _saveConfig() {
    try {
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
        scrollByMouseWheel: pdfConfig.scrollByMouseWheel,
        scaleEnabled: !pdfConfig.isPanLocked,
        enableTextSelection: pdfConfig.isTextSelection,
        pageDropShadow: null,
        useAlternativeFitScaleAsMinScale: false,
        panAxis: pdfConfig.isPanLocked ? PanAxis.vertical : PanAxis.free,
        //loading
        loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
          return Center(
            child: TLoader(
              isCustomTheme: true,
              isDarkMode: pdfConfig.isDarkMode,
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
        viewerOverlayBuilder: pdfConfig.isShowScrollThumb
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

  Widget _getHeaderWidgets() {
    if (isFullScreen) {
      return Container();
    }
    return SingleChildScrollView(
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
                pdfConfig.isDarkMode = !pdfConfig.isDarkMode;
              });
            },
            icon:
                Icon(pdfConfig.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          //pan axis lock
          IconButton(
            onPressed: () {
              setState(() {
                pdfConfig.isPanLocked = !pdfConfig.isPanLocked;
              });
            },
            icon: Icon(
              pdfConfig.isPanLocked ? Icons.lock : Icons.lock_open,
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
            icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
          ),
          //setting
          PdfReaderConfigActionComponent(
            pdfConfig: pdfConfig,
            onApply: (_pdfConfig) {
              setState(() {
                pdfConfig = _pdfConfig;
              });
              _saveConfig();
            },
          ),
          //show scroll navigation thumbnail
          IconButton(
            color: pdfConfig.isShowScrollThumb ? activeColor : null,
            onPressed: () {
              setState(() {
                pdfConfig.isShowScrollThumb = !pdfConfig.isShowScrollThumb;
              });
            },
            icon: const Icon(Icons.navigation_rounded),
          ),
        ],
      ),
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
          onLongPress: () => _toggleFullScreen(false),
          onDoubleTap: () => _toggleFullScreen(false),
          child: Column(
            children: [
              //header
              _getHeaderWidgets(),
              // pdf viewer
              Expanded(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    pdfConfig.isDarkMode ? BlendMode.difference : BlendMode.dst,
                  ),
                  child: widget.isOffline
                      ? PdfViewer.file(
                          widget.pdfFile.path,
                          controller: pdfController,
                          params: getParams(),
                        )
                      : PdfViewer.uri(
                          Uri.parse(widget.onlineUrl),
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
    _saveConfig();
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
