import 'package:flutter/material.dart';
import 'package:novel_v3/core/providers/novel_provider.dart';
import 'package:novel_v3/app/ui/home/novel_item_menu_actions.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ContentMainMenuActions extends StatefulWidget {
  const ContentMainMenuActions({super.key});

  @override
  State<ContentMainMenuActions> createState() => _ContentMainMenuActionsState();
}

class _ContentMainMenuActionsState extends State<ContentMainMenuActions> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showMenu,
      color: Colors.white,
      style: IconButton.styleFrom(
        backgroundColor: Colors.black.withValues(alpha: 0.7),
      ),
      icon: Icon(Icons.more_vert_rounded),
    );
  }

  void _showMenu() {
    final novel = context.read<NovelProvider>().currentNovel;
    if (novel == null) return;
    showTMenuBottomSheetSingle(
      context,
      title: Text(novel.meta.title),
      child: NovelItemMenuActions(novel: novel),
    );
  }
}
