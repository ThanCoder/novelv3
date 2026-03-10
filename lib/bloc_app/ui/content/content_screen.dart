import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/bloc_app/ui/content/chapter_list_page.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_detail.dart';
import 'package:novel_v3/bloc_app/ui/content/readed_component.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:t_widgets/t_widgets.dart';

class ContentScreen extends StatefulWidget {
  final String id;
  const ContentScreen({super.key, required this.id});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<NovelDetailCubit>().getNovelById(widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<NovelDetailCubit, NovelDetailState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: TLoader.random());
          }
          if (state.errorMessage != null) {
            return Center(child: Text('Error: ${state.errorMessage}'));
          }
          if (state.currentNovel == null) {
            return Center(child: Text('Novel is Null'));
          }
          // final isDesktop = TPlatform.isDesktop;
          return Scaffold(
            body: DefaultTabController(
              length: 4,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    // Header with Blurred Background
                    SliverAppBar(
                      expandedHeight: 300,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background Image
                            TImage(source: state.currentNovel!.getCoverPath),
                            // Blur Effect
                            BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                            ),
                            // Center Foreground Image
                            Center(
                              child: SizedBox(
                                height: 180,
                                width: 120,
                                child: TImage(
                                  source: state.currentNovel!.getCoverPath,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Novel Header Widget
                    _header(state.currentNovel!),

                    // Sticky Tab Bar
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _SliverAppBarDelegate(
                        const TabBar(
                          labelColor: Colors.blue,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.blue,
                          tabs: [
                            Tab(text: "Home"),
                            Tab(text: "Chapter"),
                            Tab(text: "PDF"),
                            Tab(text: "Bookmark"),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
                // Tab Body
                body: TabBarView(
                  children: [
                    NovelDetail(novel: state.currentNovel!),
                    ChapterListPage(novel: state.currentNovel!),
                    Text('pdf'),
                    Text('bookmark'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(Novel novel) {
    return SliverToBoxAdapter(
      child: Padding(
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
          ],
        ),
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
