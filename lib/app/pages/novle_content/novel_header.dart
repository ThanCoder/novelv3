import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/components/index.dart';
import 'package:novel_v3/app/dialogs/rename_dialog.dart';
import 'package:novel_v3/app/enums/book_mark_sort_name.dart';
import 'package:novel_v3/app/extensions/datetime_extenstion.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/provider/index.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_lib_screen.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_mc_search_screen.dart';
import 'package:novel_v3/app/services/index.dart';
import 'package:novel_v3/app/widgets/core/index.dart';
import 'package:provider/provider.dart';

class NovelHeader extends StatefulWidget {
  NovelModel novel;
  NovelHeader({super.key, required this.novel});

  @override
  State<NovelHeader> createState() => _NovelHeaderState();
}

class _NovelHeaderState extends State<NovelHeader> {
  void editReaded(int readed) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RenameDialog(
        title: 'Readed',
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        textInputType: TextInputType.number,
        text: readed.toString(),
        onCancel: () {},
        onSubmit: (text) {
          try {
            if (int.tryParse(text) == null) {
              showMessage(context, 'readed number ထည့်သွင်းပေးပါ!');
              return;
            }

            final novel = currentNovelNotifier.value;
            int num = int.parse(text);
            //check
            if (novel == null) {
              showMessage(context, 'novel is null!');
              return;
            }
            //no error
            novel.readed = num;

            //change data
            updateNovelReaded(novel: novel);
            //change ui
            currentNovelNotifier.value = null;
            currentNovelNotifier.value = novel;
            context
                .read<NovelProvider>()
                .setCurrentNovel(novelSourcePath: novel.path);
          } catch (e) {
            showMessage(context, e.toString());
          }
        },
      ),
    );
  }

  void _goNovelLibPage(BookMarkSortName bmsn) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovelLibScreen(
          bookMarkSortName: bmsn,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: [
        //cover
        SizedBox(
          width: 150,
          height: 180,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: MyImageFile(
              path: widget.novel.coverPath,
              fit: BoxFit.fill,
            ),
          ),
        ),
        //text
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              //title
              TextButton(
                onPressed: () {
                  copyText(widget.novel.title);
                },
                child: Text(
                  widget.novel.title,
                  maxLines: 3,
                  style: const TextStyle(
                    fontSize: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              //readed
              TextButton(
                onPressed: () {
                  editReaded(widget.novel.readed);
                },
                child: Text(
                  'Readed: ${widget.novel.readed.toString()}',
                  style: const TextStyle(color: Colors.teal),
                ),
              ),
              //Author
              TextButton(
                onPressed: () {},
                child: Text('Author: ${widget.novel.author}'),
              ),
              //mc
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NovelMcSearchScreen(mcName: widget.novel.mc),
                    ),
                  );
                },
                child: Text('MC: ${widget.novel.mc}'),
              ),

              //date
              Text(
                  'Date: ${DateTime.fromMillisecondsSinceEpoch(widget.novel.date).toParseTime()}'),
              Text(
                  'Updated: ${DateTime.fromMillisecondsSinceEpoch(widget.novel.date).toTimeAgo()}'),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  widget.novel.isAdult
                      ? NovelStatusBadge(
                          onClick: (text) {
                            _goNovelLibPage(BookMarkSortName.novleAdult);
                          },
                          text: 'Adult Novel',
                          bgColor: Colors.red,
                        )
                      : Container(),
                  NovelStatusBadge(
                    onClick: (text) {
                      if (text == 'Completed') {
                        _goNovelLibPage(BookMarkSortName.novelIsCompleted);
                      } else if (text == 'OnGoing') {
                        _goNovelLibPage(BookMarkSortName.novelOnGoing);
                      }
                    },
                    text: widget.novel.isCompleted ? 'Completed' : 'OnGoing',
                    bgColor: widget.novel.isCompleted
                        ? Colors.blue[900]
                        : Colors.teal[900],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
