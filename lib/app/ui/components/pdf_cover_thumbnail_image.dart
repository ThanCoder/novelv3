import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/pdf_file.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dest_type.dart';

class PdfCoverThumbnailImage extends StatelessWidget {
  final PdfFile pdfFile;
  final String savePath;
  const PdfCoverThumbnailImage({
    super.key,
    required this.pdfFile,
    required this.savePath,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ThanPkg.platform.genPdfThumbnail(
        pathList: [SrcDestType(src: pdfFile.path, dest: savePath)],
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TLoader();
        }
        return TImage(
          source: savePath,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('[PdfListItem:TImageFile]: $error');
            final file = File(savePath);
            if (file.existsSync()) {
              file.deleteSync();
            }
            return TImage(source: '');
          },
        );
      },
    );
  }
}
