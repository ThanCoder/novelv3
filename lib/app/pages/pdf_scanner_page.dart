import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/pdf_list_view.dart';
import 'package:novel_v3/app/models/pdf_file_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/services/android_app_services.dart';
import 'package:novel_v3/app/services/pdf_services.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';

class PdfScannerPage extends StatefulWidget {
  void Function(PdfFileModel pdfFile)? onClick;
  void Function(PdfFileModel pdfFile)? onLongClick;
  PdfScannerPage({super.key, this.onClick, this.onLongClick});

  @override
  State<PdfScannerPage> createState() => _PdfScannerPageState();
}

class _PdfScannerPageState extends State<PdfScannerPage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isLoading = false;

  void init() async {
    try {
      if (!await checkStoragePermission()) {
        if (mounted) {
          showConfirmStoragePermissionDialog(context);
        }
        return;
      }
      setState(() {
        isLoading = true;
      });
      var pdfList = await pdfScannerIsolate();

      //gen cover
      pdfList = await genPdfCover(pdfList: pdfList);
      //set list
      pdfScannerListNotifier.value = pdfList;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: TLoader(),
      );
    } else {
      return SafeArea(
        child: ValueListenableBuilder(
          valueListenable: pdfScannerListNotifier,
          builder: (context, value, child) {
            if (value.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Pdf List မရှိပါ...'),
                    IconButton(
                      onPressed: () {
                        init();
                      },
                      icon: const Icon(
                        Icons.refresh,
                        size: 30,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 500));
                  init();
                },
                child: PdfListView(
                  pdfList: value,
                  onClick: (pdfFile) {
                    if (widget.onClick != null) {
                      widget.onClick!(pdfFile);
                    }
                  },
                  onLongClick: (pdfFile) {
                    if (widget.onLongClick != null) {
                      widget.onLongClick!(pdfFile);
                    }
                  },
                ),
              );
            }
          },
        ),
      );
    }
  }
}
