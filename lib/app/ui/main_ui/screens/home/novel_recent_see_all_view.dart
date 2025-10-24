import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/interfaces/database.dart';
import 'package:novel_v3/app/core/models/novel.dart';
import 'package:novel_v3/app/others/recents/novel_recent_db.dart';
import 'package:novel_v3/app/ui/main_ui/screens/home/style_pages/novel_see_all_view.dart';
import 'package:t_widgets/t_widgets.dart';

class NovelRecentSeeAllView extends StatefulWidget {
  final void Function(Novel novel)? onRightClicked;
  final void Function(Novel novel) onClicked;
  const NovelRecentSeeAllView({
    super.key,
    required this.onClicked,
    this.onRightClicked,
  });

  @override
  State<NovelRecentSeeAllView> createState() => _NovelRecentSeeAllViewState();
}

class _NovelRecentSeeAllViewState extends State<NovelRecentSeeAllView>
    with DatabaseListener {
  @override
  void initState() {
    NovelRecentDB.getInstance().addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    NovelRecentDB.getInstance().removeListener(this);
    super.dispose();
  }

  @override
  void onDatabaseChanged(DatabaseListenerEvent event, {String? id}) {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: NovelRecentDB.getInstance().getNovelList(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: TLoaderRandom());
        }
        if (asyncSnapshot.hasData) {
          return NovelSeeAllView(
            title: 'မကြာခင်က',
            list: asyncSnapshot.data ?? [],
            onClicked: widget.onClicked,
            onRightClicked: widget.onRightClicked,
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
