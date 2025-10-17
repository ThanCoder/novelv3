import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/assets_helper/assets_home_screen.dart';

class AssetsButton extends StatelessWidget {
  const AssetsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AssetsHomeScreen()),
        );
      },
      icon: Icon(Icons.help),
    );
  }
}
