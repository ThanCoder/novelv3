import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/pdf_cache_image_list_view.dart';
import 'package:novel_v3/app/models/pdf_cache_model.dart';
import 'package:novel_v3/app/utils/path_util.dart';
import 'package:novel_v3/app/utils/poppler_util.dart';

class PopplerPdfReader extends StatefulWidget {
  String path;
  bool isDarkMode;
  PopplerPdfReader({
    super.key,
    required this.path,
    this.isDarkMode = false,
  });

  @override
  State<PopplerPdfReader> createState() => _PopplerPdfReaderState();
}

class _PopplerPdfReaderState extends State<PopplerPdfReader> {
  @override
  void initState() {
    init();
    isDarkMode = widget.isDarkMode;
    pdfScrollController.addListener(_onScroll);
    super.initState();
  }

  bool isLoading = false;
  bool isDarkMode = false;
  String pdfCacheDirPath = '';
  List<PdfCacheModel> pdfCacheImageList = [];
  ScrollController pdfScrollController = ScrollController();

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final pdfHash = await getPdfHash(widget.path);
      pdfCacheDirPath = createDir('${getCachePath()}/$pdfHash');

      await genPdfListIsolate(
        pdfPath: widget.path,
        outImagePath: pdfCacheDirPath,
        onError: (msg) {
          debugPrint(msg);
          setState(() {
            isLoading = false;
          });
        },
        onSuccess: () {
          setState(() {
            isLoading = false;
          });
          initPdfCacheList();
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void initPdfCacheList() {
    try {
      setState(() {
        isLoading = true;
      });
      final dir = Directory(pdfCacheDirPath);
      for (final file in dir.listSync()) {
        pdfCacheImageList.add(PdfCacheModel.fromPath(file.path));
      }
      pdfCacheImageList.sort((a, b) {
        int an = int.parse(a.title.replaceAll('0-', '').replaceAll('.png', ''));
        int bn = int.parse(b.title.replaceAll('0-', '').replaceAll('.png', ''));
        return an.compareTo(bn);
      });
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _onScroll() {
    // print(pdfScrollController.position.pixels);
  }

  @override
  void dispose() {
    pdfScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Column(
        children: [
          //header
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                //page size
                Text('0/${pdfCacheImageList.length}'),
                const Spacer(),
                //icon
                IconButton(
                    onPressed: () {
                      setState(() {
                        isDarkMode = !isDarkMode;
                      });
                    },
                    icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode))
              ],
            ),
          ),
          //image
          Expanded(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.white,
                isDarkMode ? BlendMode.difference : BlendMode.dstIn,
              ),
              child: PdfCacheImageListView(
                imageList: pdfCacheImageList,
                scrollController: pdfScrollController,
              ),
            ),
          ),
        ],
      );
    }
  }
}
