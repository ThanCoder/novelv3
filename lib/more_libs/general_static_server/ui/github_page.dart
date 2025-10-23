import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

import '../services/app_services.dart';

class GithubPage extends StatefulWidget {
  const GithubPage({super.key});

  @override
  State<GithubPage> createState() => _GithubPageState();
}

class _GithubPageState extends State<GithubPage> {
  @override
  Widget build(BuildContext context) {
    return TScaffold(
      appBar: AppBar(title: Text('General Server')),
      body: _getAppList(),
    );
  }

  Widget _getAppList() {
    return FutureBuilder(
      future: AppServices.getApiDB.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: TLoader.random());
        }
        if (snapshot.hasData) {
          final list = snapshot.data ?? [];
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, index) {
              final item = list[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 160,
                    height: 200,
                    child: TImage(source: item.coverSource),
                  ),
                  Text(item.title),
                ],
              );
            },
          );
        }
        return Center(child: Text('Not List'));
      },
    );
  }
}
