import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../../novel_v3_uploader.dart';

class UploaderFilePage extends StatefulWidget {
  UploaderNovel novel;
  UploaderFilePage({super.key, required this.novel});

  @override
  State<UploaderFilePage> createState() => _UploaderFilePageState();
}

class _UploaderFilePageState extends State<UploaderFilePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((e) => init());
    super.initState();
  }

  List<UploaderFile> list = [];
  bool isLoading = false;

  void init() async {
    setState(() {
      isLoading = true;
    });
    list = await OnlineNovelServices.getFilesList(novelId: widget.novel.id);
    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  void _download(UploaderFile file) async {
    try {
      if (file.isDirectLink) {
        // direct download
      }
      await ThanPkg.platform.launch(file.fileUrl);
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: TLoaderRandom());
    }
    return ListView.separated(
      itemBuilder: (context, index) =>
          OnlineFileListItem(file: list[index], onClicked: _download),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: list.length,
    );
  }
}
