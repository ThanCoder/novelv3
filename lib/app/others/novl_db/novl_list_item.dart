import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/others/novl_db/novl_data.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/than_pkg.dart';

class NovlListItem extends StatelessWidget {
  NovlData data;
  String? cachePath;
  void Function(NovlData data) onClicked;
  void Function(NovlData data)? onRightClicked;
  NovlListItem({
    super.key,
    required this.data,
    required this.onClicked,
    this.onRightClicked,
    this.cachePath,
  });

  @override
  Widget build(BuildContext context) {
    final coverPath = PathUtil.getCachePath(name: '${data.title}.png');
    final isExistsInNovel = context.read<NovelProvider>().isNovelExists(
      data.novelMeta.title,
    );
    return GestureDetector(
      onTap: () => onClicked(data),
      onSecondaryTap: () => onRightClicked?.call(data),
      onLongPress: () => onRightClicked?.call(data),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Card(
          child: Row(
            spacing: 8,
            children: [
              SizedBox(
                width: 100,
                height: 120,
                child: Container(
                  decoration: BoxDecoration(
                    color: Setting.getAppConfig.isDarkTheme
                        ? Colors.white
                        : null,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FutureBuilder(
                    future: data.saveCover(coverPath),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return TLoader.random();
                      }
                      return TImage(source: coverPath);
                    },
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 2,
                  children: [
                    textIconWidget(
                      data.novelMeta.title,
                      iconData: Icons.title,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                    textIconWidget(
                      data.type,
                      iconData: Icons.insert_drive_file,
                    ),
                    textIconWidget(
                      data.size.toFileSizeLabel(),
                      iconData: Icons.sd_card,
                    ),
                    !isExistsInNovel
                        ? SizedBox.shrink()
                        : Text(
                            'Novel ထဲမှာရှိနေပါတယ်...',
                            style: TextStyle(color: Colors.red, fontSize: 11),
                          ),
                    textIconWidget(
                      data.date.toParseTime(),
                      iconData: Icons.date_range,
                      fontSize: 12,
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
}

Widget textIconWidget(
  String title, {
  required IconData iconData,
  double? fontSize,
  FontWeight? fontWeight,
}) {
  return Row(
    children: [
      Icon(iconData),
      Expanded(
        child: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: fontSize ?? 13, fontWeight: fontWeight),
        ),
      ),
    ],
  );
}
