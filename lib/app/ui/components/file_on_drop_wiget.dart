import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

class FileOnDropWiget extends StatefulWidget {
  final Widget child;
  final void Function(List<String> files)? onDragDone;
  final bool? Function(String path)? onTest;
  const FileOnDropWiget({
    super.key,
    this.onTest,
    this.onDragDone,
    required this.child,
  });

  @override
  State<FileOnDropWiget> createState() => _PdfOnDropWigetState();
}

class _PdfOnDropWigetState extends State<FileOnDropWiget> {
  List<String> files = [];

  @override
  Widget build(BuildContext context) {
    return DropTarget(
      onDragDone: (details) {
        files.clear();
        final list = details.files.map((e) => e.path).toList();
        for (var path in list) {
          final isTested = widget.onTest?.call(path);
          if (widget.onTest == null || isTested == null) {
            files.add(path);
            continue;
          }
          if (isTested == true) {
            files.add(path);
            continue;
          }
        }
        widget.onDragDone?.call(files);
      },
      child: widget.child,
    );
  }
}
