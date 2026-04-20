import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:novel_v3/bloc_app/bloc/chapter_list_cubit.dart';
import 'package:novel_v3/bloc_app/bloc/novel_detail_cubit.dart';
import 'package:novel_v3/bloc_app/bloc_routes_func.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/novel.dart';
import 'package:novel_v3/core/extensions/build_context_extensions.dart';
import 'package:t_widgets/t_widgets.dart';

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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: BlocBuilder<ChapterListCubit, ChapterListState>(
        builder: (context, state) {
          if (state.isLoading) {
            return TLoader.random();
          }
          final readedResponses = context
              .read<ChapterListCubit>()
              .getReadedResponse();

          return Row(
            children: [
              InkWell(
                onTap: _showBottomSheet,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: Text(
                    'Readed: ${widget.novel.meta.readed}',
                    style: TextStyle(color: Colors.blue[600]),
                  ),
                ),
              ),
              readedResponses.readedChapter == null
                  ? SizedBox.shrink()
                  : TextButton(
                      onPressed: () =>
                          _goReadedChapter(readedResponses.readedChapter!),
                      child: Text(
                        'Read',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                    ),
              readedResponses.readedPrevChapter == null
                  ? SizedBox.shrink()
                  : TextButton(
                      onPressed: () => _goReadedPrevChapter(
                        readedResponses.readedPrevChapter!,
                      ),
                      child: Text(
                        'Prev Chapter',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                    ),
              readedResponses.readedNextChapter == null
                  ? SizedBox.shrink()
                  : TextButton(
                      onPressed: () => _goReadedNextChapter(
                        readedResponses.readedNextChapter!,
                      ),
                      child: Text(
                        'Next Chapter',
                        style: TextStyle(color: Colors.blue[600]),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }

  void _goReadedChapter(Chapter chapter) {
    goBlocChapterReader(context, chapter: chapter);
  }

  void _goReadedPrevChapter(Chapter chapter) {
    goBlocChapterReader(context, chapter: chapter);
  }

  void _goReadedNextChapter(Chapter chapter) {
    goBlocChapterReader(context, chapter: chapter);
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
      textInputType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onSubmit: (text) {
        if (text.isEmpty) return;
        context.read<NovelDetailCubit>().updateNovel(
          widget.novel.id,
          widget.novel.copyWith(
            meta: widget.novel.meta.copyWith(readed: int.tryParse(text)),
          ),
        );
      },
    );
  }
}
