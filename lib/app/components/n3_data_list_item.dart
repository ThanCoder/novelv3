import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/types/n3_data.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';
import '../novel_dir_app.dart';

class N3DataListItem extends StatefulWidget {
  N3Data n3data;
  String? cachePath;
  void Function(N3Data n3data) onClicked;
  void Function(N3Data n3data)? onRightClicked;
  N3DataListItem({
    super.key,
    required this.n3data,
    required this.onClicked,
    this.onRightClicked,
    this.cachePath,
  });

  @override
  State<N3DataListItem> createState() => _N3DataListItemState();
}

class _N3DataListItemState extends State<N3DataListItem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  bool isLoading = true;

  Future<void> init() async {
    try {
      await widget.n3data.saveCover(widget.n3data.getCoverPath);

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      NovelDirApp.showDebugLog(e.toString(), tag: 'N3DataListItem:init');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onClicked(widget.n3data),
      onSecondaryTap: () => widget.onRightClicked?.call(widget.n3data),
      onLongPress: () => widget.onRightClicked?.call(widget.n3data),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: FutureBuilder(
          future: _isNovelAlreadyExists(),
          builder: (context, asyncSnapshot) {
            final isExists = asyncSnapshot.data ?? false;
            return Card(
              color: isExists
                  ? const Color.fromARGB(141, 240, 220, 219)
                  : const Color.fromARGB(171, 4, 54, 6),
              child: Row(
                spacing: 8,
                children: [
                  SizedBox(
                    width: 140,
                    height: 150,
                    child: isLoading
                        ? TLoaderRandom()
                        : Container(
                            decoration: BoxDecoration(
                              color: Setting.getAppConfig.isDarkTheme
                                  ? Colors.white
                                  : null,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: TImage(source: widget.n3data.getCoverPath),
                          ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'T: ${widget.n3data.getTitle}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13),
                        ),
                        Text('Type: N3 Data'),
                        Text('Size: ${widget.n3data.getSize}'),
                        Row(
                          children: [
                            Icon(Icons.date_range),
                            Text(widget.n3data.getDate.toParseTime()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<bool> _isNovelAlreadyExists() async {
    final dataTile = await widget.n3data.getDataTitle();
    if (dataTile == null) return false;
    final file = File('${PathUtil.getSourcePath()}/$dataTile');
    return file.existsSync();
  }
}
