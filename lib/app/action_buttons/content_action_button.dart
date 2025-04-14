import 'package:flutter/material.dart';
import 'package:novel_v3/app/provider/novel_provider.dart';
import 'package:novel_v3/app/screens/novel_form_screen.dart';
import 'package:provider/provider.dart';

class ContentActionButton extends StatefulWidget {
  const ContentActionButton({super.key});

  @override
  State<ContentActionButton> createState() => _ContentActionButtonState();
}

class _ContentActionButtonState extends State<ContentActionButton> {
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 100,
          ),
          child: Column(
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _goEditScreen();
                },
                leading: const Icon(Icons.edit),
                title: const Text('Edit'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _goEditScreen() {
    final novel = context.read<NovelProvider>().getCurrent;
    if (novel == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelFormScreen(novel: novel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showMenu,
      icon: const Icon(Icons.more_vert),
    );
  }
}
