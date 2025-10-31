import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:novel_v3/more_libs/general_static_server/core/models/tutorial.dart';
import 'package:novel_v3/more_libs/general_static_server/general_server.dart';
import 'package:novel_v3/more_libs/general_static_server/services/tutorial_services.dart';
import 'package:novel_v3/more_libs/general_static_server/ui/compoments/tutorial_list_item.dart';
import 'package:novel_v3/more_libs/general_static_server/ui/tutorial/tutorial_detail_screen.dart';
import 'package:than_pkg/than_pkg.dart';

class TutorialApiHomeScreen extends StatefulWidget {
  const TutorialApiHomeScreen({super.key});

  @override
  State<TutorialApiHomeScreen> createState() => _TutorialApiHomeScreenState();
}

class _TutorialApiHomeScreenState extends State<TutorialApiHomeScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  List<Tutorial> list = [];
  bool isLoading = false;
  bool isInternetConnected = false;

  Future<void> init() async {
    try {
      setState(() {
        isLoading = true;
      });
      isInternetConnected = await ThanPkg.platform.isInternetConnected();
      if (!isInternetConnected) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        return;
      }
      final res = await TutorialServices.getApiDB.getAll();
      list = res
          .where(
            (e) =>
                e.packageName.isEmpty ||
                GeneralServer.instance.packageName == null ||
                e.packageName == GeneralServer.instance.packageName,
          )
          .toList();
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tutorial API'),
        actions: [
          !TPlatform.isDesktop
              ? SizedBox.shrink()
              : IconButton(onPressed: init, icon: Icon(Icons.refresh_sharp)),
        ],
      ),
      body: _getViews(),
    );
  }

  Widget _getViews() {
    if (isLoading) {
      return Center(child: TLoader.random());
    }
    if (!isInternetConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Your Are Offline!\nInternet ဖွင့်ပေးပါ။',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            IconButton(onPressed: init, icon: Icon(Icons.refresh)),
          ],
        ),
      );
    }
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tutorial မရှိပါ!',
              style: TextStyle(fontSize: 18, color: Colors.red),
            ),
            IconButton(onPressed: init, icon: Icon(Icons.refresh)),
          ],
        ),
      );
    }
    return RefreshIndicator.noSpinner(
      onRefresh: init,
      child: CustomScrollView(
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
                      rootPath: GeneralServer.instance.getApiServerUrl(),
                      tutorial: item,
                    ),
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
