import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/services/app_services.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';
import 'package:pdfrx/pdfrx.dart';

class PdfrxReaderOnline extends StatefulWidget {
  String url;
  String title;
  PdfrxReaderOnline(
      {super.key, required this.url, this.title = 'Online Viewer'});

  @override
  State<PdfrxReaderOnline> createState() => _PdfrxReaderOnlineState();
}

class _PdfrxReaderOnlineState extends State<PdfrxReaderOnline> {
  bool isDarkMode = false;
  PdfViewerController pdfController = PdfViewerController();
  bool isLoading = true;
  int currentPage = 1;
  int pageCount = 0;
  double scrollByMouseWheel = 1.2;
  bool isPanLocked = false;
  bool showScrollThumb = true;
  bool isFullScreen = false;
  double currentZoom = 0;
  double currentOffsetDx = 0;
  double currentOffsetDy = 0;

  PdfViewerParams getParams() => PdfViewerParams(
        margin: 0,
        scrollByMouseWheel: scrollByMouseWheel,
        scaleEnabled: !isPanLocked,
        enableTextSelection: false,
        pageDropShadow: null,
        panAxis: isPanLocked ? PanAxis.vertical : PanAxis.free,
        //loading
        loadingBannerBuilder: (context, bytesDownloaded, totalBytes) {
          return Center(
            child: TLoader(),
          );
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

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      contentPadding: 0,
      appBar: isFullScreen
          ? null
          : AppBar(
              title: Text(widget.title),
            ),
      body: GestureDetector(
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
                            // _showGoToDialog();
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
                          icon: Icon(
                              isDarkMode ? Icons.light_mode : Icons.dark_mode),
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
                child: PdfViewer.uri(
                  Uri.parse(widget.url),
                  controller: pdfController,
                  params: getParams(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
