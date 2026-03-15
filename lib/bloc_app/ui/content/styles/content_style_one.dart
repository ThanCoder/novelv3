import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/bloc_app/ui/components/circle_button.dart';
import 'package:novel_v3/bloc_app/ui/content/chapter_list_page.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_detail.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_page_component.dart';
import 'package:novel_v3/bloc_app/ui/content/pdf_list_page.dart';
import 'package:novel_v3/bloc_app/ui/content/readed_component.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class ContentStyleOne extends StatefulWidget {
  final NovelDetailState state;
  const ContentStyleOne({super.key, required this.state});

  @override
  State<ContentStyleOne> createState() => _ContentStyleOneState();
}

class _ContentStyleOneState extends State<ContentStyleOne>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ၁။ Main Scroll Content
        CustomScrollView(
          slivers: [
            // အပေါ်က Background Cover နဲ့ Blur အပိုင်း
            SliverAppBar(
              expandedHeight: 300,
              automaticallyImplyLeading: false,
              pinned: false,
              floating: true,
              snap: true, // Snap ကို ဒီမှာ သုံးမယ်
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background Blur
                    TImage(source: widget.state.currentNovel!.getCoverPath),
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ),
                    // Foreground Image
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 220,
                        child: TImage(
                          source: widget.state.currentNovel!.getCoverPath,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Novel Info Header
            SliverToBoxAdapter(child: _header(widget.state.currentNovel!)),

            // Sticky TabBar
            SliverPersistentHeader(
              pinned: true, // TabBar ကိုတော့ ကပ်ထားချင်လို့ Pinned သုံးပါတယ်
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabs: [
                    Tab(text: "Home"),
                    Tab(text: "Chapter"),
                    Tab(text: "PDF"),
                    Tab(text: "Bookmark"),
                  ],
                ),
              ),
            ),

            // TabBarView ရဲ့ အစား စာမျက်နှာတွေကို Sliver တွေနဲ့ပဲ စီပြရပါမယ်
            // CustomScrollView ထဲမှာ TabBarView တိုက်ရိုက်ထည့်လို့မရလို့ပါ
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  NovelDetail(novel: widget.state.currentNovel!),
                  ChapterListPage(
                    novel: widget.state.currentNovel!,
                  ), // ဒီထဲက SliverAppBar ကို ဖြုတ်လိုက်ပါ
                  PdfListPage(novel: widget.state.currentNovel!),
                  Center(child: Text('bookmark')),
                ],
              ),
            ),
          ],
        ),

        // ၂။ Floating UI (Back Button က Image ပေါ်မှာ အမြဲရှိနေစေချင်ရင်)
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 10,
          child: CircleButton(
            onTap: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: Colors.white),
            // color: Colors.black.withOpacity(
            //   0.5,
            // ), // Back button နောက်ခံ
          ),
        ),
      ],
    );
  }

  

  Widget _header(Novel novel) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            novel.meta.title,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          Text(
            "Author: ${novel.meta.author}",
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            "Translator: ${novel.meta.translator}",
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            "Main Character: ${novel.meta.mc}",
            style: TextStyle(color: Colors.grey[600]),
          ),
          ReadedComponent(novel: novel),
          // page
          NovelPageComponent(novel: novel),
        ],
      ),
    );
  }

  
}

// TabBar ကို Sliver ထဲမှာ Pinned ဖြစ်နေစေဖို့ Delegate class
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
