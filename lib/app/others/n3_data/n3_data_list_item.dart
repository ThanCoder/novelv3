import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/app/others/n3_data/n3_data.dart';
import 'package:novel_v3/more_libs/setting_v2.0.0/setting.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';
import '../../ui/novel_dir_app.dart';

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
      // widget.n3data.isNovelExists = await _isNovelAlreadyExists();

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
        child: Card(
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
                          color: Setting.getAppConfig.isDarkMode
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
                    _getTitleWidget(),
                    Text('Type: N3 Data'),
                    _getNovelExistsWidget(),
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
        ).animate().shimmer(duration: Duration(milliseconds: 700)),
      ),
    );
  }

  Widget _getTitleWidget() {
    return FutureBuilder(
      future: widget.n3data.getDataTitle(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData && asyncSnapshot.data != null) {
          final title = asyncSnapshot.data;
          return Text(
            'T: $title',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13),
          );
        }
        return Text(
          'T: ${widget.n3data.getTitle}',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 13),
        );
      },
    );
  }

  Widget _getNovelExistsWidget() {
    // if (widget.n3data.isNovelExists) {
    //   return Text(
    //     'ရှိနေပြီးသားဖြစ်နေပါတယ်...',
    //     style: TextStyle(color: Colors.red, fontSize: 12),
    //   );
    // }

    // return Text(
    //   'မသွင်းရသေးပါ...',
    //   style: TextStyle(color: Colors.teal, fontSize: 12),
    // );
    return FutureBuilder(
      future: _isNovelAlreadyExists(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text(
            'စစ်ဆေးနေပါတယ်....',
            style: TextStyle(color: Colors.amber, fontSize: 12),
          );
        }
        if (snapshot.hasData) {
          final isExists = snapshot.data ?? false;
          if (isExists) {
            return Text(
              'ရှိနေပြီးသားဖြစ်နေပါတယ်...',
              style: TextStyle(color: Colors.red, fontSize: 12),
            );
          }
        }
        return Text(
          'မသွင်းရသေးပါ...',
          style: TextStyle(color: Colors.teal, fontSize: 12),
        );
      },
    );
  }

  Future<bool> _isNovelAlreadyExists() async {
    final dataTile = await widget.n3data.getDataTitle();
    if (dataTile == null) return false;
    final dir = Directory('${PathUtil.getSourcePath()}/$dataTile');
    // await Future.delayed(Duration(seconds: 2));
    // print('Data Title: $dataTile');
    return dir.existsSync();
  }
}
