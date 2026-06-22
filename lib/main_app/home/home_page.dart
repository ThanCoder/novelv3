import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/state/novel_state_controller.dart';
import 'package:novel_v3/core/state/novel_state_event.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final stateController = NovelStateController();

  @override
  void initState() {
    stateController.initSource();
    super.initState();
  }

  @override
  void dispose() {
    // stateController.dispose();
    super.dispose();
  }

  void init() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: NovelStateController.instance.initSource,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: StreamBuilder(
        initialData: stateController.state,
        stream: stateController.stream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (!snapshot.hasData || state!.isLoading) {
            return Center(child: CircularProgressIndicator.adaptive());
          }

          return listWidget(state.novelList);
        },
      ),
    );
  }

  Widget listWidget(List<Novel> list) {
    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) => listItem(list[index]),
    );
  }

  Widget listItem(Novel novel) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            height: 160,
            child: Image.file(
              File(novel.coverPath),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: Text(error.toString())),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    novel.meta.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13),
                  ),
                  Text('Author: ${novel.meta.author}'),
                  Text('MC: ${novel.meta.mc}'),
                  Text('Size: ${novel.size.toFileSizeLabel()}'),
                  Text(
                    DateTime.fromMillisecondsSinceEpoch(
                      novel.meta.date,
                    ).toDetailedAgeLabel(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
