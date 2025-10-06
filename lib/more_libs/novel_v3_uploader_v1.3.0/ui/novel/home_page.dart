import 'package:flutter/material.dart';
import '../../novel_v3_uploader.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

import '../components/status_text.dart';
import '../components/tag_wrap_view.dart';
import '../components/see_all_screen.dart';
import 'desktop_ui/online_novel_grid_item.dart';
import 'desktop_ui/online_novel_page_button.dart';
import 'novel_content_ui_switcher.dart';

class HomePage extends StatefulWidget {
  Novel novel;
  HomePage({super.key, required this.novel});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 3,
                  children: [
                    SizedBox(
                      width: 160,
                      height: 200,
                      child: TCacheImage(
                        url: widget.novel.coverUrl,
                        // cachePath: PathUtil.getCachePath(),
                      ),
                    ),
                    SelectableText(widget.novel.title, maxLines: null),
                    Text('Author: ${widget.novel.author}'),
                    Text('ဘာသာပြန်: ${widget.novel.translator}'),
                    Text('MC: ${widget.novel.mc}'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 5,
                      children: [
                        StatusText(
                          bgColor: widget.novel.isCompleted
                              ? StatusText.completedColor
                              : StatusText.onGoingColor,
                          text: widget.novel.isCompleted
                              ? 'Completed'
                              : 'OnGoing',
                        ),
                        widget.novel.isAdult
                            ? StatusText(
                                text: 'Adult',
                                bgColor: StatusText.adultColor,
                              )
                            : const SizedBox.shrink(),
                        // page
                        OnlineNovelPageButton(novel: widget.novel),
                      ],
                    ),
                    Text('ရက်စွဲ: ${widget.novel.date.toParseTime()}'),
                  ],
                ),
              ),
            ),
            TagWrapView(list: widget.novel.getTags, onClicked: _goSeeAllScreen),
            widget.novel.desc.isEmpty ? SizedBox.shrink() : Divider(),
            SelectableText(
              widget.novel.desc,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  void _goContentPage(Novel novel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelContentUiSwitcher(novel: novel),
      ),
    );
  }

  void _goSeeAllScreen(String tag) async {
    try {
      final allList = await NovelServices.getOnlineList();
      final list = allList.where((e) => e.tags.contains(tag)).toList();
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeeAllScreen(
            title: Text(tag),
            list: list,
            gridItemBuilder: (context, item) =>
                OnlineNovelGridItem(novel: item, onClicked: _goContentPage),
          ),
        ),
      );
    } catch (e) {
      NovelV3Uploader.instance.showLog(e.toString());
    }
  }
}
