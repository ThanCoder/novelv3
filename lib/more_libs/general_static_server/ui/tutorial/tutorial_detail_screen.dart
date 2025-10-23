import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:novel_v3/more_libs/general_static_server/core/models/tutorial.dart';

class TutorialDetailScreen extends StatefulWidget {
  final String rootPath;
  final Tutorial tutorial;
  const TutorialDetailScreen({
    super.key,
    required this.rootPath,
    required this.tutorial,
  });

  @override
  State<TutorialDetailScreen> createState() => _TutorialDetailScreenState();
}

class _TutorialDetailScreenState extends State<TutorialDetailScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  List<String> list = [];

  void init() async {
    try {
      list = widget.tutorial.getImageList(widget.rootPath);

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.tutorial.title)),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: _getViews(),
        ),
      ),
    );
  }

  Widget _getViews() {
    return CustomScrollView(
      slivers: [
        SliverList.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: list.length,
          itemBuilder: (context, index) => _getListItem(list[index]),
        ),
      ],
    );
  }

  Widget _getListItem(String source) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 400),
      child: TImage(
        source: source,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return TLoader();
        },
      ),
    );
  }
}
