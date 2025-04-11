import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showMenu,
      icon: const Icon(Icons.more_vert),
    );
  }
}
