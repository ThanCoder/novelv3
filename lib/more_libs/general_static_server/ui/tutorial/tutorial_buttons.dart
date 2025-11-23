import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/general_static_server/ui/tutorial/tutorial_api_home_screen.dart';

class TutorialButtons extends StatelessWidget {
  const TutorialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TutorialApiHomeScreen()),
        );
      },
      icon: Icon(Icons.help_outline),
    );
  }
}

class TutorialListTileButton extends StatelessWidget {
  const TutorialListTileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.help_outline),
        title: Text('အကူအညီများ'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TutorialApiHomeScreen()),
          );
        },
      ),
    );
  }
}
