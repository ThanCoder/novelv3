import 'package:flutter/material.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/utils.dart';
import 'package:t_widgets/functions/index.dart';

class ReadedComponent extends StatefulWidget {
  final Novel novel;
  const ReadedComponent({super.key, required this.novel});

  @override
  State<ReadedComponent> createState() => _ReadedComponentState();
}

class _ReadedComponentState extends State<ReadedComponent> {
  @override
  void didUpdateWidget(covariant ReadedComponent oldWidget) {
    if (oldWidget.novel.meta.readed != widget.novel.meta.readed) {
      if (!mounted) return;
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showBottomSheet,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          'Readed: ${widget.novel.meta.readed}',
          style: TextStyle(color: Colors.blue[600]),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.edit_document),
          title: Text('Edit'),
          onTap: () {
            context.closeNavigator();
            _showEditDialog();
          },
        ),
      ],
    );
  }

  void _showEditDialog() {
    showTReanmeDialog(
      context,
      title: Text('Edit Readed'),
      barrierDismissible: false,
      text: widget.novel.meta.readed.toString(),
      onSubmit: (text) {
        if (text.isEmpty) return;
        
      },
    );
  }
}
