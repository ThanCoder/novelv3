import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/t_history_v1.0.0/t_history_record.dart';
import 'package:novel_v3/more_libs/t_history_v1.0.0/t_history_services.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class THistoryScreen extends StatefulWidget {
  const THistoryScreen({super.key});

  @override
  State<THistoryScreen> createState() => _THistoryScreenState();
}

class _THistoryScreenState extends State<THistoryScreen> {
  final hScrollController = ScrollController();

  List<DataColumn> get _getColumns {
    return const [
      DataColumn(label: Text('Title')),
      DataColumn(label: Text('Method')),
      DataColumn(label: Text('Desc')),
      DataColumn(label: Text('ရက်စွဲ')),
    ];
  }

  List<DataRow> _getRows(List<THistoryRecord> list) {
    return list
        .map(
          (e) => DataRow(
            cells: [
              DataCell(
                Text(e.title),
              ),
              DataCell(Text(e.method.name.toCaptalize())),
              DataCell(Text(e.desc)),
              DataCell(Text('${e.date.toParseTime()}\n${e.date.toTimeAgo()}')),
            ],
          ),
        )
        .toList();
  }

  void _clearList() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => TConfirmDialog(
        contentText: 'ဖျက်ချင်တာ သေချာပြီလား?',
        submitText: 'Delete',
        onSubmit: () async {
          await THistoryServices.instance.delete();
          if (!context.mounted) return;
          setState(() {});
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Record'),
        actions: [
          IconButton(
            color: Colors.red,
            onPressed: _clearList,
            icon: const Icon(Icons.delete_forever),
          ),
        ],
      ),
      body: FutureBuilder(
        future: THistoryServices.instance.getList(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final list = snapshot.data ?? [];
            return SingleChildScrollView(
              child: Scrollbar(
                controller: hScrollController,
                child: SingleChildScrollView(
                  controller: hScrollController,
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: _getColumns,
                    rows: _getRows(list),
                  ),
                ),
              ),
            );
          }
          return TLoader();
        },
      ),
    );
  }
}
