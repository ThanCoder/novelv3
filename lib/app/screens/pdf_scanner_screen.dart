import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/core/app_components.dart';
import 'package:novel_v3/app/components/pdf_list_item.dart';
import 'package:novel_v3/app/dialogs/core/confirm_dialog.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/models/pdf_model.dart';
import 'package:novel_v3/app/provider/pdf_provider.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/services/core/app_services.dart';
import 'package:novel_v3/app/services/pdf_services.dart';
import 'package:novel_v3/app/widgets/index.dart';
import 'package:provider/provider.dart';
import 'package:than_pkg/than_pkg.dart';
import 'package:than_pkg/types/src_dist_type.dart';

class PdfScannerScreen extends StatefulWidget {
  NovelModel? novel;
  void Function(PdfModel pdf)? onChoosed;
  PdfScannerScreen({
    super.key,
    this.novel,
    this.onChoosed,
  });

  @override
  State<PdfScannerScreen> createState() => _PdfScannerScreenState();
}

class _PdfScannerScreenState extends State<PdfScannerScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  bool isSorted = true;
  List<PdfModel> list = [];

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });
    list = await PdfServices.instance.pdfScanner();
    //gen cover
    await ThanPkg.platform.genPdfThumbnail(
        pathList: list
            .map(
              (pdf) => SrcDistType(
                src: pdf.path,
                dist: pdf.coverPath,
              ),
            )
            .toList());
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void _deleteConfirm(PdfModel pdf) {
    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`${pdf.title}` ကိုဖျက်ချင်တာ သေချာပြီလား?`',
        submitText: 'Delete',
        onCancel: () {},
        onSubmit: () async {
          try {
            //ui
            list = list.where((pf) => pf.path != pdf.path).toList();
            pdf.delete();

            setState(() {});
          } catch (e) {
            if (!mounted) return;
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _showInfo(PdfModel pdf) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Title: ${pdf.title}'),
              Text('Size: ${pdf.size.toDouble().toParseFileSize()}'),
              Text(
                  'Date: ${DateTime.fromMillisecondsSinceEpoch(pdf.date).toParseTime()}'),
              Text(
                  'Ago: ${DateTime.fromMillisecondsSinceEpoch(pdf.date).toTimeAgo()}'),
              Text('Path: ${pdf.path}'),
            ],
          ),
        ),
      ),
    );
  }

  void _setCover(PdfModel pdf) async {
    final file = File(pdf.coverPath);
    if (!await file.exists()) return;
    if (widget.novel == null) return;
    final coverPath = widget.novel!.coverPath;
    if (coverPath.isEmpty) return;
    await file.copy(coverPath);
    await clearAndRefreshImage();
    if (!mounted) return;
    showMessage(context, 'Cover Added');
  }

  void _copyPdf(PdfModel pdf) async {
    try {
      final path = widget.novel!.path;
      final file = File(pdf.path);
      final newPath = '$path/${file.getName()}';
      if (!await file.exists()) return;
      if (await File(newPath).exists()) {
        showMessage(
          context,
          'Novel ထဲမှာ ရှိနေပြီးသား ဖြစ်နေပါတယ်!',
          oldStyle: true,
        );
        return;
      }
      setState(() {
        isLoading = true;
      });

      /// copy file
      final outFile = File(newPath);
      await file.openRead().pipe(outFile.openWrite());

      ///
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (widget.novel != null) {
        context.read<PdfProvider>().initList(novelPath: widget.novel!.path);
      }
      showMessage(context, 'PDF Copied', oldStyle: true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showDialogMessage(context, e.toString());
    }
  }

  void _movePdf(PdfModel pdf) async {
    try {
      final path = widget.novel!.path;
      final file = File(pdf.path);
      final newPath = '$path/${file.getName()}';
      if (!await file.exists()) return;
      if (await File(newPath).exists()) {
        showMessage(
          context,
          'Novel ထဲမှာ ရှိနေပြီးသား ဖြစ်နေပါတယ်!',
          oldStyle: true,
        );
        return;
      }

      await file.rename(newPath);
      list = list.where((pf) => pf.title != pdf.title).toList();
      if (!mounted) return;
      setState(() {});
      showMessage(context, 'PDF Moved');
    } catch (e) {
      showDialogMessage(context, e.toString());
    }
  }

  void _showMenu(PdfModel pdf) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
            spacing: 5,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  pdf.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const Divider(),
              //info
              ListTile(
                leading: const Icon(Icons.info_outlined),
                title: const Text('Infomation'),
                onTap: () {
                  Navigator.pop(context);
                  _showInfo(pdf);
                },
              ),
              //copy title
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy Name'),
                onTap: () {
                  Navigator.pop(context);
                  copyText(pdf.title);
                  if (Platform.isLinux) {
                    showMessage(context, 'Copied');
                  }
                },
              ),
              //move
              widget.novel == null
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: const Icon(Icons.move_to_inbox_outlined),
                      title: const Text('Novel ထဲကို ရွှေ့မယ် (Move)'),
                      onTap: () {
                        Navigator.pop(context);
                        _movePdf(pdf);
                      },
                    ),
              //copy
              widget.novel == null
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: const Icon(Icons.copy),
                      title: const Text('Novel ထဲကို ကူးမယ် (Copy)'),
                      onTap: () {
                        Navigator.pop(context);
                        _copyPdf(pdf);
                      },
                    ),
              //set cover
              widget.novel == null
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: const Icon(Icons.image),
                      title: const Text('Set Cover'),
                      onTap: () {
                        Navigator.pop(context);
                        _setCover(pdf);
                      },
                    ),
              //open
              widget.novel == null
                  ? const SizedBox.shrink()
                  : ListTile(
                      leading: const Icon(Icons.open_in_browser_rounded),
                      title: const Text('Open'),
                      onTap: () {
                        Navigator.pop(context);
                        goPdfReader(context, pdf);
                      },
                    ),
              //delete
              ListTile(
                iconColor: Colors.red,
                leading: const Icon(Icons.delete_forever_rounded),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteConfirm(pdf);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _backpress() async {
    if (widget.novel == null) return;
    context
        .read<PdfProvider>()
        .initList(novelPath: widget.novel!.path, isReset: true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        _backpress();
      },
      child: MyScaffold(
        contentPadding: 0,
        appBar: AppBar(
          title: const Text('PDF Scanner'),
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
        body: isLoading
            ? TLoader()
            : RefreshIndicator(
                onRefresh: init,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) => PdfListItem(
                    // isShowPathLabel: true,
                    pdf: list[index],
                    onClicked: (pdf) {
                      if (widget.novel == null) {
                        goPdfReader(context, pdf);
                        return;
                      }
                      //novel ရှိနေရင်
                      _showMenu(pdf);
                    },
                    onLongClicked: _showMenu,
                  ),
                ),
              ),
      ),
    );
  }
}
