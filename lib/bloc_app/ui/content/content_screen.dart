import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/bloc_app/ui/components/circle_button.dart';
import 'package:novel_v3/bloc_app/ui/content/chapter_list_page.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_detail.dart';
import 'package:novel_v3/bloc_app/ui/content/novel_page_component.dart';
import 'package:novel_v3/bloc_app/ui/content/pdf_list_page.dart';
import 'package:novel_v3/bloc_app/ui/content/readed_component.dart';
import 'package:novel_v3/bloc_app/ui/forms/add_chapter_form.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/utils.dart';
import 'package:t_widgets/t_widgets.dart';

class ContentScreen extends StatefulWidget {
  final String id;
  const ContentScreen({super.key, required this.id});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  void _init() async {
    try {
      final novel = await context.read<NovelDetailCubit>().getNovelById(
        widget.id,
      );
      if (novel == null) return;

      if (!mounted) return;
      await context.read<ChapterListCubit>().fetchList();
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            body: Stack(
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
                      actions: state.currentNovel == null ? [] : _actions(),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Background Blur
                            TImage(source: state.currentNovel!.getCoverPath),
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
                                  source: state.currentNovel!.getCoverPath,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Novel Info Header
                    SliverToBoxAdapter(child: _header(state.currentNovel!)),

                    // Sticky TabBar
                    SliverPersistentHeader(
                      pinned:
                          true, // TabBar ကိုတော့ ကပ်ထားချင်လို့ Pinned သုံးပါတယ်
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
                          NovelDetail(novel: state.currentNovel!),
                          ChapterListPage(
                            novel: state.currentNovel!,
                          ), // ဒီထဲက SliverAppBar ကို ဖြုတ်လိုက်ပါ
                          PdfListPage(novel: state.currentNovel!),
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
            ),
          );
        },
      ),
    );
  }

  List<Widget> _actions() {
    return [
      CircleButton(
        icon: Icon(Icons.more_vert, color: Colors.white),
        onTap: _showMainMenu,
      ),
    ];
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

  // show menu
  void _showMainMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Chapter'),
          onTap: () {
            context.closeNavigator();
            goBlocRoute(
              context,
              builder: (context) => AddChapterForm(
                novel: context.read<NovelDetailCubit>().state.currentNovel!,
              ),
            );
          },
        ),
      ],
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
