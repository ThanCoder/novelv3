import 'package:flutter/material.dart';

import 'app_helper_screen.dart';

class AppHelpButton extends StatelessWidget {
  const AppHelpButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AppHelperScreen(),
            ));
      },
      icon: Icon(Icons.help),
    );
  }
}
