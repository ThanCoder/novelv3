import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';
import '../../novel_dir_db.dart';

class ContentHomePage extends StatefulWidget {
  const ContentHomePage({
    super.key,
  });

  @override
  State<ContentHomePage> createState() => _ContentHomePageState();
}

class _ContentHomePageState extends State<ContentHomePage> {
  @override
  Widget build(BuildContext context) {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Novel is null!'),
        ),
      );
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: TImage(source: novel.getCoverPath)),
          Container(
            color: Colors.black.withValues(alpha: 0.8),
          ),
          CustomScrollView(
            slivers: [
              // appbar
              SliverAppBar(
                title: Text('Content'),
                floating: true,
                snap: true,
                backgroundColor: Colors.transparent,
              ),
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _getHeader(),
              )),
              SliverToBoxAdapter(child: _getBottoms()),
              SliverToBoxAdapter(child: _getDesc()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getHeader() {
    final novel = context.read<NovelProvider>().getCurrent!;
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 5,
          runSpacing: 5,
          children: [
            TImage(
              source: novel.getCoverPath,
              width: 180,
              height: 200,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 5,
              children: [
                Text('T: ${novel.title}'),
                Text('Author: ${novel.getAuthor}'),
                Text('Translator: ${novel.getTranslator}'),
                Text('MC: ${novel.getMC}'),
                Text('ရက်စွဲ: ${novel.date.toParseTime()}'),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: [
                    StatusText(
                      bgColor: novel.isCompleted
                          ? StatusText.completedColor
                          : StatusText.onGoingColor,
                      text: novel.isCompleted ? 'Completed' : 'OnGoing',
                    ),
                    !novel.isAdult
                        ? StatusText(
                            text: 'Adult',
                            bgColor: StatusText.adultColor,
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Widget _getBottoms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 5,
          runSpacing: 5,
          children: [
            _getPageButton(),
          ],
        ),
        Divider(),
      ],
    );
  }

  Widget _getDesc() {
    final novel = context.read<NovelProvider>().getCurrent!;
    if (novel.getContent.isEmpty) {
      return SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SelectableText(novel.getContent),
    );
  }

  // page button
  Widget _getPageButton() {
    final novel = context.read<NovelProvider>().getCurrent!;
    final list = novel.getPageUrls;
    if (list.isNotEmpty) {
      return IconButton(
          onPressed: () {
            showTListDialog<String>(
              context,
              list: list,
              listItemBuilder: (context, item) => ListTile(
                title: Text(
                  item,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                  maxLines: 2,
                ),
                onTap: () {
                  Navigator.pop(context);
                  try {
                    ThanPkg.platform.launch(item);
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },
              ),
            );
          },
          icon: Icon(Icons.open_in_browser));
    }
    return SizedBox.shrink();
  }
}
