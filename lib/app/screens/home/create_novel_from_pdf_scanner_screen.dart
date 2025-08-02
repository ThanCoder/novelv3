import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/components/pdf_list_item.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/services/pdf_services.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class CreateNovelFromPdfScannerScreen extends StatefulWidget {
  void Function(PdfModel pdf) onChoosed;
  CreateNovelFromPdfScannerScreen({
    super.key,
    required this.onChoosed,
  });

  @override
  State<CreateNovelFromPdfScannerScreen> createState() =>
      _CreateNovelFromPdfScannerScreenState();
}

class _CreateNovelFromPdfScannerScreenState
    extends State<CreateNovelFromPdfScannerScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  bool isSorted = true;
  List<PdfModel> list = [];

  Future<void> init() async {
   try {
    if(!await ThanPkg.platform.isStoragePermissionGranted()){
      Navigator.pop(context);
      await ThanPkg.platform.requestStoragePermission();
      return;
    }

      setState(() {
      isLoading = true;
    });
    list = await PdfServices.instance.pdfScanner();
    
    //gen cover
    // await ThanPkg.platform.genPdfThumbnail(
    //     pathList: list
    //         .map(
    //           (pdf) => SrcDistType(
    //             src: pdf.path,
    //             dist: pdf.coverPath,
    //           ),
    //         )
    //         .toList());
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
   } catch (e) {
      if (!mounted) return;
    setState(() {
      isLoading = false;
    });
    showDialogMessage(context, e.toString());
   }
  }

  Widget _getList() {
    if (isLoading) {
      return Center(child: TLoaderRandom());
    }
    if (list.isEmpty) {
      return const Center(child: Text('PDF ရှာမတွေ့ပါ!'));
    }
    return RefreshIndicator(
      onRefresh: init,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) => PdfListItem(
          // isShowPathLabel: true,
          pdf: list[index],
          onClicked: (pdf) {
            Navigator.pop(context);
            widget.onChoosed(pdf);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create From PDF'),
        actions: [
          PlatformExtension.isDesktop()
              ? IconButton(
                  onPressed: init,
                  icon: const Icon(Icons.refresh),
                )
              : SizedBox.fromSize(),
          IconButton(
            onPressed: () {
              final res = list.reversed.toList();
              list = res;
              isSorted = !isSorted;
              setState(() {});
            },
            icon: const Icon(
              Icons.sort_by_alpha_sharp,
            ),
          ),
        ],
      ),
      body: _getList(),
    );
  }
}
