import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/models/index.dart';
import 'package:novel_v3/app/providers/novel_provider.dart';
import 'package:novel_v3/app/ui/routes_helper.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:provider/provider.dart';

class RecentPdfButton extends StatelessWidget {
  const RecentPdfButton({super.key});

  @override
  Widget build(BuildContext context) {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) {
      return SizedBox.shrink();
    }
    String pdfName = PdfServices.getRecent(novelId: novel.title);
    if (pdfName.isEmpty) return SizedBox.shrink();
    final pdfFile = File('${novel.path}/$pdfName');
    if (!pdfFile.existsSync()) return SizedBox.shrink();
    return TextButton(
      onPressed: () {
        goPdfReader(context, NovelPdf.createPath(pdfFile.path));
      },
      child: Text('Recent PDF'),
    );
  }
}
