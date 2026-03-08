import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/bloc_app/ui/content/chapter_list_page.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_detail.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_info.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/extensions/t_platform.dart';

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
          final isDesktop = TPlatform.isDesktop;
          return DefaultTabController(
            length: 4,
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    snap: isDesktop,
                    floating: isDesktop,
                    title: Text(
                      state.currentNovel!.meta.title,
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                  SliverAppBar(
                    expandedHeight: 260,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    flexibleSpace: TImage(
                      source: state.currentNovel!.getCoverPath,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: NovelInfo(novel: state.currentNovel!),
                  ),
                  // tab
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabbarHeader(
                      TabBar(
                        labelStyle: TextStyle(fontSize: 13),
                        isScrollable: true,
                        tabs: [
                          Tab(text: 'Detail', icon: Icon(Icons.home)),
                          Tab(text: 'Chapter', icon: Icon(Icons.list)),
                          Tab(
                            text: 'PDF',
                            icon: Icon(Icons.picture_as_pdf_rounded),
                          ),
                          Tab(
                            text: 'BookMark',
                            icon: Icon(Icons.bookmark_added),
                          ),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: Container(
                margin: EdgeInsets.only(top: 10),
                child: TabBarView(
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
}

class _TabbarHeader extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  const _TabbarHeader(this._tabBar);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Theme.of(context).primaryColor, child: _tabBar);
  }

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
