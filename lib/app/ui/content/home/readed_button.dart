import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/providers/chapter_provider.dart';
import 'package:novel_v3/core/providers/novel_provider.dart';
import 'package:novel_v3/app/routes.dart';
import 'package:provider/provider.dart';
import 'package:t_widgets/t_widgets.dart';

class ReadedButton extends StatefulWidget {
  const ReadedButton({super.key});

  @override
  State<ReadedButton> createState() => _ReadedButtonState();
}

class _ReadedButtonState extends State<ReadedButton> {
  Novel get currentNovel => context.read<NovelProvider>().currentNovel!;
  int get readed => context.watch<NovelProvider>().currentNovel!.meta.readed;

  Chapter? get currentChapter {
    final list = context.read<ChapterProvider>().list;
    final index = list.indexWhere((e) => e.number == currentNovel.meta.readed);
    if (index == -1) return null;
    return list[index];
  }

  Chapter? get currentNextChapter {
    final list = context.read<ChapterProvider>().list;
    final index = list.indexWhere(
      (e) => e.number == (currentNovel.meta.readed + 1),
    );
    if (index == -1) return null;
    return list[index];
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(onPressed: _chooseDialog, child: Text('Readed: $readed'));
  }

  void _chooseDialog() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Edit'),
          onTap: () {
            closeContext(context);
            _edit();
          },
        ),
        currentChapter == null
            ? SizedBox.shrink()
            : ListTile(
                leading: Icon(Icons.chrome_reader_mode),
                title: Text('Read Readed Chapter'),
                onTap: () {
                  closeContext(context);
                  goChapterReader(context, chapter: currentChapter!);
                },
              ),
        currentNextChapter == null
            ? SizedBox.shrink()
            : ListTile(
                leading: Icon(Icons.chrome_reader_mode),
                title: Text('Read Next Chapter'),
                onTap: () {
                  closeContext(context);
                  goChapterReader(context, chapter: currentNextChapter!);
                },
              ),
      ],
    );
  }

  void _edit() {
    showTReanmeDialog(
      context,
      barrierDismissible: false,
      title: Text('Readed ပြောင်းလဲခြင်း'),
      text: currentNovel.meta.readed.toString(),
      textInputType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      cancelText: 'မလုပ်',
      submitText: 'ပြောင်းလဲ',
      onSubmit: (text) {
        final num = int.tryParse(text) ?? 0;
        final novel = currentNovel.copyWith(
          meta: currentNovel.meta.copyWith(readed: num),
        );
        context.read<NovelProvider>().update(novel);
        context.read<NovelProvider>().setCurrentNovel(novel);
      },
    );
  }
}
