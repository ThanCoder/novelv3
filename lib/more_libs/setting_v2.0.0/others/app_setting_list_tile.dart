import 'package:flutter/material.dart';

import 'app_setting_screen.dart';

class AppSettingListTile extends StatelessWidget {
  const AppSettingListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.settings),
      title: Text('Setting'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppSettingScreen(),
          ),
        );
      },
    );
  }
}
