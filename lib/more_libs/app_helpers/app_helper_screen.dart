import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

import 'app_helper_content_screen.dart';
import 'app_helper_services.dart';

class AppHelperScreen extends StatelessWidget {
  const AppHelperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('အကူအညီ'),
      ),
      body: FutureBuilder(
        future: AppHelperServices.getList(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: TLoaderRandom());
          }
          final list = snapshot.data ?? [];
          return ListView.separated(
              itemBuilder: (context, index) {
                final item = list[index];
                return ListTile(
                  title: Text(item.title),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AppHelperContentScreen(helper: item),
                        ));
                  },
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: list.length);
        },
      ),
    );
  }
}
