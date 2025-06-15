import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/components/core/app_components.dart';
import 'package:novel_v3/app/dialogs/core/confirm_dialog.dart';
import 'package:novel_v3/app/extensions/novel_extension.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/riverpods/providers.dart';
import 'package:novel_v3/app/route_helper.dart';
import 'package:novel_v3/app/services/novel_services.dart';
import 'package:novel_v3/my_libs/novel_data/data_export_dialog.dart';
import 'package:novel_v3/my_libs/sort_dialog_v1.0.0/sort_component.dart';
import 'package:novel_v3/my_libs/sort_dialog_v1.0.0/sort_type.dart';
import 'package:t_widgets/types/t_loader_types.dart';
import 'package:t_widgets/widgets/t_loader.dart';
import 'package:than_pkg/than_pkg.dart';

class NovelTableScreen extends ConsumerStatefulWidget {
  const NovelTableScreen({super.key});

  @override
  ConsumerState<NovelTableScreen> createState() => _NovelTableScreenState();
}

class _NovelTableScreenState extends ConsumerState<NovelTableScreen> {
  final hScrollController = ScrollController();
  bool isLoading = true;
  List<NovelModel> list = [];
  SortType sortType = SortType.getDefaultValue;
  NovelModel? currentNovel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    setState(() {
      isLoading = true;
    });
    list = await NovelServices.instance.getList();

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });
  }

  List<DataColumn> get _getColumns {
    return const [
      DataColumn(label: Text('Title')),
      DataColumn(label: Text('Author')),
      DataColumn(label: Text('MC')),
      DataColumn(label: Text('Readed')),
      DataColumn(label: Text('Is Completed')),
      DataColumn(label: Text('Is Adult')),
      DataColumn(label: Text('ရက်စွဲ')),
    ];
  }

  List<DataRow> get _getRows {
    return list
        .map(
          (e) => DataRow(
            onLongPress: () => _showMenu(e),
            cells: [
              DataCell(
                Text(e.title),
                onLongPress: () => _showMenu(e),
                onTap: () {
                  goNovelContentPage(context, ref, e);
                },
              ),
              DataCell(Text(e.author)),
              DataCell(Text(e.mc)),
              DataCell(Text(e.readed.toString())),
              DataCell(Text(e.isCompleted.toString())),
              DataCell(Text(e.isAdult.toString())),
              DataCell(Text(
                  '${DateTime.fromMillisecondsSinceEpoch(e.date).toParseTime()}\n${DateTime.fromMillisecondsSinceEpoch(e.date).toTimeAgo()}')),
            ],
          ),
        )
        .toList();
  }

  void _sort(SortType type) {
    if (type.title == 'Title') {
      list.sortTitle(type.isAsc);
    }
    if (type.title == 'Completed') {
      list.sortCompleted(type.isAsc);
    }
    if (type.title == 'Adult') {
      list.sortAdult(type.isAsc);
    }
    if (type.title == 'Date') {
      list.sortDate(type.isAsc);
    }
    sortType = type;
    setState(() {});
  }

  void _exportDataFile(NovelModel novel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DataExportDialog(
        novelPath: novel.path,
        onDone: (savedPath) {
          showDialogMessage(context, '`$savedPath` Exported');
        },
      ),
    );
  }

  void _deleteConfirm(NovelModel novel) {
    final provider = ref.read(novelNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '`${novel.title}` ကိုဖျက်ချင်တာ သေချာပြီလား?`',
        submitText: 'Delete',
        onCancel: () {},
        onSubmit: () async {
          try {
            //remove ui
            provider.removeUI(novel);

            list = list.where((e) => e.title != novel.title).toList();
            setState(() {});

            //remove db
            await novel.delete();

            await Future.delayed(const Duration(seconds: 1));
            await ref.read(bookmarkNotifierProvider.notifier).initList();
            await ref.read(recentNotifierProvider.notifier).initList();
          } catch (e) {
            if (!mounted) return;
            showDialogMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _showMenu(NovelModel novel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(novel.title),
              ),
              ListTile(
                leading: const Icon(Icons.import_export),
                title: const Text('Export Data'),
                onTap: () {
                  Navigator.pop(context);
                  _exportDataFile(novel);
                },
              ),
              ListTile(
                iconColor: Colors.red,
                leading: const Icon(Icons.delete_forever),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteConfirm(novel);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table'),
        actions: [
          PlatformExtension.isDesktop()
              ? IconButton(
                  onPressed: init,
                  icon: const Icon(Icons.refresh),
                )
              : const SizedBox.shrink(),
          SortComponent(
            value: sortType,
            onChanged: _sort,
          ),
        ],
      ),
      body: isLoading
          ? TLoader(
              types: TLoaderTypes.Circle,
            )
          : SingleChildScrollView(
              child: Scrollbar(
                controller: hScrollController,
                child: SingleChildScrollView(
                  controller: hScrollController,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: _getColumns,
                    rows: _getRows,
                  ),
                ),
              ),
            ),
    );
  }
}
