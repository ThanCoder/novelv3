import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_list_view.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/screens/novel_content_screen.dart';
import 'package:novel_v3/app/widgets/my_scaffold.dart';
import 'package:novel_v3/app/widgets/t_chip.dart';
import 'package:provider/provider.dart';

class NovelMcSearchScreen extends StatefulWidget {
  String? mcName;
  NovelMcSearchScreen({super.key, this.mcName});

  @override
  State<NovelMcSearchScreen> createState() => _NovelMcSearchScreenState();
}

class _NovelMcSearchScreenState extends State<NovelMcSearchScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NovelProvider>().initList();
      init();
    });
  }

  String currentMCName = 'all';
  List<String> mcNames = [];
  List<NovelModel> novelList = [];

  void init() {
    try {
      if (widget.mcName != null) {
        currentMCName = widget.mcName!;
      }
      final novels = context.read<NovelProvider>().getList;
      final list = novels.map((nv) => nv.mc).toSet();
      setState(() {
        mcNames = list.toList();
      });
      _filterMC();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List<Widget> _getHeaderWidgets() {
    return mcNames
        .map((name) => TChip(
              title: name,
              avatar: currentMCName == name ? const Icon(Icons.check) : null,
              onClick: () {
                setState(() {
                  currentMCName = name;
                });
                _filterMC();
              },
            ))
        .toList();
  }

  void _filterMC() {
    final novels = context.read<NovelProvider>().getList;
    if (currentMCName == 'all') {
      setState(() {
        novelList = novels;
      });
      return;
    }
    final res = novels.where((nv) => nv.mc == currentMCName).toList();
    setState(() {
      novelList = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Main Character (MC)'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          //header
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: [
              TChip(
                title: 'All',
                avatar: currentMCName == 'all' ? const Icon(Icons.check) : null,
                onClick: () {
                  setState(() {
                    currentMCName = 'all';
                  });
                  _filterMC();
                },
              ),
              ..._getHeaderWidgets(),
            ],
          ),
          const Divider(),
          Expanded(
            child: NovelListView(
              novelList: novelList,
              onClick: (novel) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovelContentScreen(novel: novel),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
