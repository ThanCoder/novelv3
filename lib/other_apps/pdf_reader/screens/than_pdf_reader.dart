import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/other_apps/pdf_reader/components/pdf_bookmark_drawer.dart';
import 'package:novel_v3/other_apps/pdf_reader/types/pdf_config.dart';
import 'package:t_client/t_client.dart';
import 'package:t_pdf_reader/t_pdf_reader.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ThanPdfReader extends StatefulWidget {
  final String path;
  final PdfConfig pdfConfig;
  final String? bookmarkPath;
  final void Function(PdfConfig)? onConfigUpdated;
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
    isDarkMode = widget.pdfConfig.isDarkMode;
    super.initState();
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

    widget.onConfigUpdated?.call(
      widget.pdfConfig.copyWith(
        page: pdfController.currentPage,
        zoom: pdfController.currentZoom,
      ),
    );
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

  final pdfController = TPdfControllerV2();
  bool isDarkMode = false;
  bool isScaleEnable = false;
  bool isFullscreen = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: isFullscreen
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
              top: isFullscreen ? 0 : 40,
              child: ClipRRect(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.white,
                    isDarkMode ? BlendMode.difference : BlendMode.dst,
                  ),
                  child: GestureDetector(
                    onDoubleTap: () {
                      if (!isFullscreen) return;
                      isFullscreen = false;
                      setState(() {});
                      ThanPkg.platform.toggleFullScreen(isFullScreen: false);
                    },
                    child: Container(
                      color: Colors.white,
                      width: double.infinity,
                      height: double.infinity,
                      child: TPdfReaderV2(
                        source: widget.path,
                        controller: pdfController,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (!isFullscreen)
              Positioned(left: 0, right: 0, top: 0, child: _header),
          ],
        ),
      ),
    );
  }

  Widget get _header => ListenableBuilder(
    listenable: pdfController,
    builder: (context, child) {
      return Theme(
        data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
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
                      child: Text(
                        '${pdfController.currentPage}/${pdfController.totalPages}',
                        style: TextStyle(color: Colors.teal),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        isDarkMode = !isDarkMode;
                      });
                    },
                    icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                  ),
                  Text('Zoom: ${(pdfController.currentZoom * 100).toInt()}%'),
                  IconButton(
                    icon: Icon(Icons.zoom_out),
                    onPressed: () => pdfController.setZoom(
                      pdfController.currentZoom - 0.25,
                    ), // ၂၅% လျှော့မယ်
                  ),
                  IconButton(
                    icon: Icon(Icons.zoom_in),
                    onPressed: () => pdfController.setZoom(
                      pdfController.currentZoom + 0.25,
                    ), // ၂၅% တိုးမယ်
                  ),
                  IconButton(
                    onPressed: () {
                      isFullscreen = !isFullscreen;
                      ThanPkg.platform.toggleFullScreen(
                        isFullScreen: isFullscreen,
                      );
                      setState(() {});
                    },
                    icon: Icon(
                      isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      isScaleEnable = !isScaleEnable;
                      pdfController.setPanEnabled(isScaleEnable);
                      if (Platform.isAndroid) {
                        pdfController.setScaleEnabled(isScaleEnable);
                      }
                    },
                    icon: Icon(isScaleEnable ? Icons.lock_open : Icons.lock),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
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
}

/**
 * 
 StreamBuilder(
                stream: pdfController.lowImageProgressStream.stream,
                builder: (context, snapshot) {
                  double? value;
                  if (snapshot.hasData) {
                    value = snapshot.data!.$2 / snapshot.data!.$1;
                  }
                  return LinearProgressIndicator(value: value);
                },
              ),

             
 */
