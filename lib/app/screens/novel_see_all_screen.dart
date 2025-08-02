import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/novel_grid_item.dart';
import 'package:novel_v3/app/dialogs/novel_data_config_exporter_dialog.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/route_helper.dart';

ValueNotifier<List<NovelModel>> novelSeeAllScreenNotifier = ValueNotifier([]);

void novelSeeAllScreenTitleChanged({
  required String oldTitle,
  required String newTitle,
}) {
  final list = novelSeeAllScreenNotifier.value;
  novelSeeAllScreenNotifier.value = list.map((e) {
    if (e.title == oldTitle) {
      return NovelModel.fromTitle(newTitle);
    }
    return e;
  }).toList();
}

class NovelSeeAllScreen extends ConsumerStatefulWidget {
  String title;
  NovelSeeAllScreen({
    super.key,
    required this.title,
  });

  @override
  ConsumerState<NovelSeeAllScreen> createState() => _NovelSeeAllScreenState();
}

class _NovelSeeAllScreenState extends ConsumerState<NovelSeeAllScreen> {
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.import_export_rounded),
                title: const Text('Data Config Files ထုတ်မယ်'),
                onTap: () {
                  Navigator.pop(context);
                  _exportDataConfig();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportDataConfig() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NovelDataConfigExporterDialog(
        list: novelSeeAllScreenNotifier.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(onPressed: _showMenu, icon: const Icon(Icons.more_vert))
        ],
      ),
      body: ValueListenableBuilder(
          valueListenable: novelSeeAllScreenNotifier,
          builder: (context, list, child) {
            return GridView.builder(
              itemCount: list.length,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisExtent: 200,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemBuilder: (context, index) => NovelGridItem(
                novel: list[index],
                onClicked: (novel) {
                  goNovelContentPage(context, ref, novel);
                },
                onLongClicked: (novel) {},
              ),
            );
          }),
    );
  }
}
