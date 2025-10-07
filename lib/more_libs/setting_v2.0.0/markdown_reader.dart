import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:t_widgets/functions/message_func.dart';

class MarkdownReader extends StatefulWidget {
  final String assetFileName;
  final Widget? title;
  const MarkdownReader({super.key, required this.assetFileName, this.title});

  @override
  State<MarkdownReader> createState() => _MarkdownReaderState();
}

class _MarkdownReaderState extends State<MarkdownReader> {
  String text = '';
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    try {
      text = await rootBundle.loadString(widget.assetFileName);
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: widget.title ?? Text('Markdown Reader')),
      body: Markdown(data: text),
    );
  }
}
