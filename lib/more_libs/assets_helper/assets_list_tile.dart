import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/assets_helper/assets_home_screen.dart';

class AssetsListTile extends StatelessWidget {
  const AssetsListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.help),
      title: Text('အကူအညီများ'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AssetsHomeScreen()),
        );
      },
    );
  }
}
