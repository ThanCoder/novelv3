import 'package:flutter/material.dart';

import '../app_setting_screen.dart';

class AppSettingListTile extends StatelessWidget {
  const AppSettingListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.settings),
        title: Text('Setting'),
        trailing: Icon(Icons.arrow_forward_ios_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AppSettingScreen()),
          );
        },
      ),
    );
  }
}
