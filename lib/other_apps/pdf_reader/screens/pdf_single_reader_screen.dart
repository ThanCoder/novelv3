import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/other_apps/pdf_reader/types/pdf_config.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:t_widgets/functions/dialog_func.dart';
import 'package:t_widgets/functions/message_func.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class PdfSingleReaderScreen extends StatefulWidget {
  final String path;
  final PdfConfig pdfConfig;
  final void Function(PdfConfig)? onConfigUpdated;
  const PdfSingleReaderScreen({
    super.key,
    required this.path,
    required this.pdfConfig,
    this.onConfigUpdated,
  });

  @override
  State<PdfSingleReaderScreen> createState() => _PdfSingleReaderScreenState();
}

class _PdfSingleReaderScreenState extends State<PdfSingleReaderScreen> {
  @override
  void initState() {
    pdfConfig = widget.pdfConfig;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  @override
  void dispose() {
    _dom?.dispose();
    widget.onConfigUpdated?.call(pdfConfig.copyWith(page: currentPage));
    ThanPkg.platform.toggleFullScreen(isFullScreen: false);
    super.dispose();
  }

  bool isLoading = false;
  PdfDocument? _dom;
  final TransformationController _zoomController = TransformationController();
  final _pageController = PageController();
  double _currentZoom = 1.0;
  final double _zoomRange = 0.1;
  int currentPage = 1;
  int pageCount = 0;
  late PdfConfig pdfConfig;

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });
      _dom = await PdfDocument.openFile(widget.path);
      if (_dom != null) {
        pageCount = _dom!.pages.length;
      }
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      Future.delayed(Duration(milliseconds: 1100)).then((_) {
        if (!mounted) return;
        _goToPage(pdfConfig.page);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: pdfConfig.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: pdfConfig.isFullscreen
            ? null
            : AppBar(title: Text('PDF Viewer')),
        body: _views,
      ),
    );
  }

  Widget get _views {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            if (!pdfConfig.isFullscreen)
              SliverAppBar(
                automaticallyImplyLeading: false,
                floating: true,
                snap: true,
                pinned: true,
                flexibleSpace: _header,
              ),
            if (isLoading)
              SliverFillRemaining(
                child: Center(child: CircularProgressIndicator.adaptive()),
              )
            else
              SliverFillRemaining(child: _dom == null ? null : _pdfSinglePage),
          ],
        ),
        // nav
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                color: Colors.red,
                onPressed: () {
                  _pageController.previousPage(
                    duration: Duration(microseconds: 500),
                    curve: Curves.bounceInOut,
                  );
                },
                icon: Container(
                  decoration: BoxDecoration(
                    color: pdfConfig.isDarkMode ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.navigate_before, size: 30),
                ),
              ),
              Spacer(),
              IconButton(
                color: Colors.red,
                onPressed: () {
                  _pageController.nextPage(
                    duration: Duration(microseconds: 500),
                    curve: Curves.bounceInOut,
                  );
                },
                icon: Container(
                  decoration: BoxDecoration(
                    color: pdfConfig.isDarkMode ? Colors.white : Colors.black,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.navigate_next, size: 30),
                ),
              ),
            ],
          ),
        ),

        if (pdfConfig.isFullscreen)
          Positioned(
            child: IconButton(
              onPressed: _toggleFullscreen,
              icon: Icon(Icons.fullscreen_exit),
            ),
          ),
      ],
    );
  }

  Widget get _header => Container(
    padding: EdgeInsets.all(5),
    // decoration: BoxDecoration(color: Colors.white),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 4,
        children: [
          // current page
          TextButton(
            onPressed: () {
              showTReanmeDialog(
                context,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputType: TextInputType.number,
                text: currentPage.toString(),
                submitText: 'GoToPage',
                onSubmit: (text) {
                  _goToPage(int.parse(text));

                  // Future.delayed(Duration(milliseconds: 1300)).then((_) {
                  //   _goToPage(int.parse(text));
                  // });
                },
              );
            },
            child: Text(
              '$currentPage/$pageCount',
              // style: TextStyle(color: Colors.blue),
            ),
          ),
          // zoom out
          IconButton(
            onPressed: () {
              _updateZoom(_currentZoom - _zoomRange);
            },
            icon: Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: () {
              _updateZoom(_currentZoom + _zoomRange);
            },
            icon: Icon(Icons.zoom_in),
          ),
          IconButton(
            onPressed: () {
              pdfConfig = pdfConfig.copyWith(isDarkMode: !pdfConfig.isDarkMode);
              setState(() {});
            },
            icon: Icon(
              pdfConfig.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
          ),
          IconButton(
            onPressed: () {
              _toggleFullscreen();
            },
            icon: Icon(
              pdfConfig.isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            ),
          ),
        ],
      ),
    ),
  );

  Widget get _pdfSinglePage {
    return PageView.builder(
      itemCount: pageCount,
      controller: _pageController,
      onPageChanged: (value) => setState(() {
        currentPage = value + 1;
      }),
      itemBuilder: (context, index) => _pdfItem(_dom!.pages[index], index),
    );
  }

  Widget _pdfItem(PdfPage page, int index) {
    currentPage = index + 1;
    return _darkModePdfView(
      child: Container(
        color: Colors.white,
        child: InteractiveViewer(
          transformationController: _zoomController,
          scaleEnabled: false,
          panEnabled: false,
          child: Center(
            child: SizedBox(
              width: page.width,
              height: page.height,
              child: GestureDetector(
                onDoubleTap: () => _toggleFullscreen,
                child: PdfPageView(
                  document: page.document,
                  pageNumber: index + 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _darkModePdfView({required Widget child}) {
    if (pdfConfig.isDarkMode) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(Colors.white, BlendMode.difference),
        child: child,
      );
    }
    return child;
  }

  void _goToPage(int page) async {
    try {
      // _pageController.animateToPage(
      //   page - 1,
      //   duration: Duration(milliseconds: 700),
      //   curve: Curves.bounceInOut,
      // );
      _pageController.jumpToPage(page - 1);
    } catch (e) {
      showTMessageDialogError(context, e.toString());
    }
  }

  void _toggleFullscreen() {
    pdfConfig = pdfConfig.copyWith(isFullscreen: !pdfConfig.isFullscreen);
    setState(() {});
    ThanPkg.platform.toggleFullScreen(isFullScreen: pdfConfig.isFullscreen);
  }

  void _updateZoom(double zoom) {
    setState(() {
      _currentZoom = zoom;
      // Matrix4 ကို သုံးပြီး scale ချဲ့တာပါ
      final double viewWidth = MediaQuery.of(context).size.width;
      final double viewHeight = MediaQuery.of(context).size.height;

      _zoomController.value = Matrix4.identity()
        ..translateByVector3(Vector3(viewWidth / 2, viewHeight / 2, 1.0))
        ..scaleByVector3(Vector3(_currentZoom, _currentZoom, 1.0))
        ..translateByVector3(Vector3(-viewWidth / 2, -viewHeight / 2, 1.0));
      // _zoomController.value = Matrix4.identity()
      //   ..scaleByVector3(Vector3(_currentZoom, _currentZoom, 1.0));
    });
  }
}
