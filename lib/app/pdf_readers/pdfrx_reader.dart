import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/components/pdf_reader_config_action_component.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/drawers/pdf_book_mark_list_drawer.dart';
import 'package:novel_v3/app/models/pdf_config_model.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/services/app_services.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:window_manager/window_manager.dart';

class PdfrxReader extends StatefulWidget {
  PdfFileModel pdfFile;
  PdfConfigModel pdfConfig;
  bool isOffline;
  String onlineUrl;
  void Function(PdfConfigModel pdfConfig)? saveConfig;
  PdfrxReader({
    super.key,
    required this.pdfFile,
    required this.pdfConfig,
    this.saveConfig,
    this.isOffline = true,
    this.onlineUrl = '',
  });

  @override
  State<PdfrxReader> createState() => _PdfrxReaderState();
}

class _PdfrxReaderState extends State<PdfrxReader> with WindowListener {
  PdfViewerController pdfController = PdfViewerController();
  bool isLoading = true;
  int currentPage = 1;
  int pageCount = 0;
  bool initCalled = false;
  bool isFullScreen = false;
  double zoom = 0;
  double offsetDx = 0;
  double offsetDy = 0;
  double scrollByMouseWheel = 1.2;
  bool isDarkMode = false;
  bool isKeepScreen = false;
  bool isPanLocked = false;
  bool isShowScrollThumb = true;
  bool isTextSelection = false;
  late PdfConfigModel config;

  @override
  void initState() {
    windowManager.addListener(this);
    config = widget.pdfConfig;
    super.initState();
  }

  //pdf loaded
  void onPdfLoaded() async {
    try {
      isDarkMode = config.isDarkMode;
      isKeepScreen = config.isKeepScreen;
      isPanLocked = config.isPanLocked;
      isShowScrollThumb = config.isShowScrollThumb;
      isTextSelection = config.isTextSelection;
      offsetDx = config.offsetDx;
      offsetDy = config.offsetDy;
      currentPage = config.page;
      scrollByMouseWheel = config.scrollByMouseWheel;
      zoom = config.zoom;

      //set offset
      final newOffset = Offset(offsetDx, offsetDy);
      if (zoom != 0 && offsetDx != 0 && offsetDy != 0) {
        pdfController.setZoom(newOffset, zoom);
        //delay
        await Future.delayed(const Duration(milliseconds: 600));
        goPage(currentPage);
      } else {
        goPage(currentPage);
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
    //keep screen
    toggleAndroidKeepScreen(isKeepScreen);
  }

  //save config
  void _saveConfig() {
    try {
      config.offsetDx = offsetDx;
      config.offsetDy = offsetDy;
      config.page = currentPage;
      config.zoom = zoom;
      config.isDarkMode = isDarkMode;
      config.isKeepScreen = isKeepScreen;
      config.isPanLocked = isPanLocked;
      config.isShowScrollThumb = isShowScrollThumb;
      config.isTextSelection = isTextSelection;
      config.scrollByMouseWheel = scrollByMouseWheel;

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
    if (isFull) {
      showMessage(context, 'Double Tap Is Exist FullScreen!');
    }
    toggleFullScreenPlatform(isFullScreen);
  }

  PdfViewerParams getParams() => PdfViewerParams(
        margin: 0,
        scrollByMouseWheel: scrollByMouseWheel,
        scaleEnabled: isPanLocked == false,
        panAxis: isPanLocked ? PanAxis.vertical : PanAxis.free,
        enableTextSelection: isTextSelection,
        pageDropShadow: null,
        useAlternativeFitScaleAsMinScale: false,
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
              zoom = pdfController.currentZoom;
              offsetDx = offset.dx;
              offsetDy = offset.dy;
            });
          } catch (e) {
            debugPrint('onPageChanged: ${e.toString()}');
          }
        },
        //pdf ready
        onViewerReady: (document, controller) {
          onPdfLoaded();
        },
        viewerOverlayBuilder: isShowScrollThumb
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
                isDarkMode = !isDarkMode;
              });
            },
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
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
            icon: Icon(isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
          ),
          //setting
          PdfReaderConfigActionComponent(
            pdfConfig: config,
            onApply: (_pdfConfig) {
              setState(() {
                isKeepScreen = _pdfConfig.isKeepScreen;
                isTextSelection = _pdfConfig.isTextSelection;
                isShowScrollThumb = _pdfConfig.isShowScrollThumb;
                scrollByMouseWheel = _pdfConfig.scrollByMouseWheel;
              });
              _saveConfig();
              _initConfig();
            },
          ),
          //show scroll navigation thumbnail
          IconButton(
            color: isShowScrollThumb ? activeColor : null,
            onPressed: () {
              config.isShowScrollThumb = !isShowScrollThumb;
              setState(() {
                isShowScrollThumb = !isShowScrollThumb;
              });
            },
            icon: const Icon(Icons.navigation_rounded),
          ),
        ],
      ),
    );
  }

  Widget _getCurrentPdfReader() {
    if (widget.isOffline) {
      return PdfViewer.file(
        widget.pdfFile.path,
        controller: pdfController,
        params: getParams(),
      );
    }
    return PdfViewer.uri(
      Uri.parse(widget.onlineUrl),
      controller: pdfController,
      params: getParams(),
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
          // onTap: () => _toggleFullScreen(false),
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
                    isDarkMode ? BlendMode.difference : BlendMode.dst,
                  ),
                  child: _getCurrentPdfReader(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _close() async {
    _saveConfig();
    toggleFullScreenPlatform(false);
    windowManager.removeListener(this);
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }
}
