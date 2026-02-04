import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/core/providers/novel_provider.dart';
import 'package:novel_v3/app/core/services/novel_services.dart';
import 'package:novel_v3/app/others/novel_config/novel_config_services.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:novel_v3/app/ui/forms/edit_novel_screen.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/functions/message_func.dart';

class HomePageDropView extends StatefulWidget {
  final Widget child;
  const HomePageDropView({super.key, required this.child});

  @override
  State<HomePageDropView> createState() => _HomePageDropViewState();
}

class _HomePageDropViewState extends State<HomePageDropView> {
  @override
  Widget build(BuildContext context) {
    return DropTarget(
      enable: true,
      onDragDone: (details) => _fileChecker(details.files.first.path),
      child: widget.child,
    );
  }

  void _fileChecker(String path) {
    // config
    if (path.endsWith('.meta.json')) {
      addConfig(path);
      return;
    }
  }

  Future<void> addConfig(String path) async {
    try {
      final meta = await NovelConfigServices.getNovelMetaFromPath(path);
      if (meta == null) {
        throw Exception('Meta Is Null,Meta File မှာပြသနာရှိနေပါတယ်!...');
      }
      if (!mounted) return;

      final provider = context.read<NovelProvider>();
      final novel = await NovelServices.createNovelFolder(meta: meta);

      provider.add(novel);
      if (!mounted) return;
      goRoute(
        context,
        builder: (context) => EditNovelScreen(
          novel: novel,
          coverUrl: meta.coverUrl,
          onUpdated: (updatedNovel) {
            provider.update(updatedNovel);
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }
}
