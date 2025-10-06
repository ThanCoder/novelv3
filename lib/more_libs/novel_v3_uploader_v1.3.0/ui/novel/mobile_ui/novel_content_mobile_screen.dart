import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets_dev.dart';
import 'package:than_pkg/than_pkg.dart';
import '../../../novel_v3_uploader.dart';
import '../../components/index.dart';
import '../../components/see_all_screen.dart';
import '../../components/status_text.dart';
import '../../uploader_file/uploader_file_page.dart';
import '../novel_content_ui_switcher.dart';

class NovelContentMobileScreen extends StatefulWidget {
  Novel novel;
  NovelContentMobileScreen({super.key, required this.novel});

  @override
  State<NovelContentMobileScreen> createState() =>
      _NovelContentMobileScreenState();
}

class _NovelContentMobileScreenState extends State<NovelContentMobileScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: screenSize.height * 0.5, // cover height
                pinned: true, // TabBar ကိုအပေါ်မှာတင်ပိတ်မယ်
                floating: false,
                leading: _getBackButton(),
                flexibleSpace: FlexibleSpaceBar(background: _getHeaderWidget()),
                actions: [...NovelV3Uploader.instance.appBarActions],
                bottom: TabBar(
                  labelColor: Colors.white, // ရွေးထားတဲ့ tab color
                  unselectedLabelColor:
                      Colors.white70, // မရွေးရသေးတဲ့ tab color
                  indicatorColor: Colors.yellow, // indicator line color
                  tabs: [
                    Tab(text: "Description", icon: Icon(Icons.home)),
                    Tab(text: "Page Urls", icon: Icon(Icons.pageview_rounded)),
                    Tab(
                      text: "Download",
                      icon: Icon(Icons.cloud_download_rounded),
                    ),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              Center(child: _getHomeWidget(widget.novel)),
              _getPageUrlsWidget(),
              UploaderFilePage(novel: widget.novel),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getBackButton() {
    return IconButton(
      onPressed: () {
        Navigator.pop(context);
      },

      icon: Icon(Icons.arrow_back_ios),
    );
  }

  Widget _getHeaderWidget() {
    return Stack(
      fit: StackFit.expand,
      children: [
        TImage(source: widget.novel.coverUrl),

        // အောက်ခြမ်းမှာ အနက် gradient
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent, // အပေါ်မှာ ဖေါ့
                Colors.black.withValues(alpha: 0.7), // အောက်မှာ အနက်
              ],
            ),
          ),
        ),
        // Title ကို အောက်မှာ fix ထားမယ်
        Positioned(
          bottom: 80, // TabBar အပေါ်နည်းနည်း
          left: 5,
          right: 5,
          child: Column(
            children: [
              Text(
                widget.novel.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black54,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getHomeWidget(Novel novel) {
    return TScrollableColumn(
      children: [
        Text('Author: ${widget.novel.author}'),
        Text('ဘာသာပြန်: ${widget.novel.translator}'),
        Text('MC: ${widget.novel.mc}'),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 5,
          children: [
            StatusText(
              bgColor: widget.novel.isCompleted
                  ? StatusText.completedColor
                  : StatusText.onGoingColor,
              text: widget.novel.isCompleted ? 'Completed' : 'OnGoing',
            ),
            widget.novel.isAdult
                ? StatusText(text: 'Adult', bgColor: StatusText.adultColor)
                : const SizedBox.shrink(),
          ],
        ),
        Text('ရက်စွဲ: ${widget.novel.date.toParseTime()}'),
        // tags
        TTagsWrapView(values: widget.novel.getTags, onClicked: _goSeeAllScreen),
        SelectableText(novel.desc),
      ],
    );
  }

  Widget _getPageUrlsWidget() {
    final urls = widget.novel.getPageUrls;
    return Scaffold(
      body: ListView.separated(
        itemBuilder: (context, index) {
          final url = urls[index];
          return ListTile(
            title: Text(url),
            onTap: () {
              try {
                ThanPkg.platform.launch(url);
              } catch (e) {
                showTMessageDialogError(context, e.toString());
              }
            },
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: urls.length,
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

  void _goContentPage(Novel novel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelContentUiSwitcher(novel: novel),
      ),
    );
  }
}
