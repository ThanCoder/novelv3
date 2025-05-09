import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:novel_v3/app/models/index.dart';
import 'package:novel_v3/app/route_helper.dart';

class NovelReadedButton extends ConsumerStatefulWidget {
  NovelModel novel;
  NovelReadedButton({super.key, required this.novel});

  @override
  ConsumerState<NovelReadedButton> createState() => _NovelReadedButtonState();
}

class _NovelReadedButtonState extends ConsumerState<NovelReadedButton> {
  void _getReader() {
    goTextReader(
      context,
      ref,
      ChapterModel.fromPath('${widget.novel.path}/${widget.novel.readed}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.novel.readed == 0) return const SizedBox.shrink();
    if (!widget.novel.isExistsReaded) {
      return const SizedBox.shrink();
    }
    return ElevatedButton(
      onPressed: _getReader,
      child: Text('${widget.novel.readed} ကနေ ဖတ်မယ်'),
    );
  }
}
