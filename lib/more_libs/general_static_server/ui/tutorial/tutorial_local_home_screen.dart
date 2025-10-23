import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/general_static_server/core/models/tutorial.dart';
import 'package:novel_v3/more_libs/general_static_server/general_server.dart';
import 'package:novel_v3/more_libs/general_static_server/services/tutorial_services.dart';
import 'package:novel_v3/more_libs/general_static_server/ui/compoments/tutorial_list_item.dart';
import 'package:novel_v3/more_libs/general_static_server/ui/tutorial/tutorial_detail_screen.dart';

class TutorialLocalHomeScreen extends StatefulWidget {
  const TutorialLocalHomeScreen({super.key});

  @override
  State<TutorialLocalHomeScreen> createState() =>
      _TutorialLocalHomeScreenState();
}

class _TutorialLocalHomeScreenState extends State<TutorialLocalHomeScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  List<Tutorial> list = [];

  void init() async {
    try {
      list = await TutorialServices.getLocalDB.getAll();

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tutorial Local')),
      body: _getViews(),
    );
  }

  Widget _getViews() {
    return CustomScrollView(
      slivers: [
        SliverList.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: list.length,
          itemBuilder: (context, index) => TutorialListItem(
            item: list[index],
            onClicked: (item) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TutorialDetailScreen(
                    rootPath: GeneralServer.instance.getLocalServerPath(),
                    tutorial: item,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
