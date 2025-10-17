import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/assets_helper/assets_detail_screen.dart';
import 'package:novel_v3/more_libs/assets_helper/assets_file.dart';
import 'package:novel_v3/more_libs/assets_helper/assets_services.dart';

class AssetsHomeScreen extends StatefulWidget {
  const AssetsHomeScreen({super.key});

  @override
  State<AssetsHomeScreen> createState() => _AssetsHomeScreenState();
}

class _AssetsHomeScreenState extends State<AssetsHomeScreen> {
  final list = AssetsServices.getList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('အကူအညီများ')),
      body: _getViews(),
    );
  }

  Widget _getViews() {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => _getListItem(list[index]),
    );
  }

  Widget _getListItem(AssetsFile item) {
    return Column(
      children: [
        ListTile(
          title: Text(item.title),
          subtitle: item.desc.isEmpty ? null : Text(item.desc),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AssetsDetailScreen(file: item),
              ),
            );
          },
        ),
        Divider(),
      ],
    );
  }
}
