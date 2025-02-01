import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/novel_list_view.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/novel_content_screen.dart';
import 'package:novel_v3/app/services/novel_isolate_services.dart';
import 'package:novel_v3/app/widgets/t_loader.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    init();
    super.initState();
  }

  bool isLoading = false;

  //init
  void init() async {
    try {
      setState(() {
        isLoading = true;
      });

      final novelList = await getNovelListFromPathIsolate();
      novelListNotifier.value = novelList;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: TLoader(),
          )
        : ValueListenableBuilder(
            valueListenable: novelListNotifier,
            builder: (context, value, child) {
              //novel list empty
              if (value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Novel List မရှိပါ...'),
                      TextButton(
                        onPressed: () {
                          init();
                        },
                        child: const Icon(
                          Icons.refresh,
                          size: 30,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                //has novel list
                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.delayed(const Duration(milliseconds: 700));
                    init();
                  },
                  child: NovelListView(
                    novelList: value,
                    onClick: (novel) {
                      currentNovelNotifier.value = novel;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NovelContentScreen(novel: novel),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          );
  }
}
