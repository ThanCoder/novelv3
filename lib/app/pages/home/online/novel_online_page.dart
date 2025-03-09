import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:provider/provider.dart';

import '../../../widgets/index.dart';

class NovelOnlinePage extends StatefulWidget {
  const NovelOnlinePage({super.key});

  @override
  State<NovelOnlinePage> createState() => _NovelOnlinePageState();
}

class _NovelOnlinePageState extends State<NovelOnlinePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  void init() async {
    context.read<OnlineNovelProvider>().initList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OnlineNovelProvider>();
    final isLoading = provider.isLoading;
    final novelList = provider.getList;
    return MyScaffold(
      appBar: AppBar(
        title: const Text('Online'),
      ),
      body: isLoading
          ? TLoader()
          : novelList.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Novel List Empty'),
                    IconButton(
                      onPressed: init,
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ))
              : OnlineNovleListView(
                  novelList: novelList,
                  onClick: (novel) {
                    // currentNovelNotifier.value = novel;
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => NovelFormScreen(),
                    //   ),
                    // );
                  },
                ),
    );
  }
}
