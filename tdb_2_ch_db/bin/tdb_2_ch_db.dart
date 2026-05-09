import 'package:chapters_db/chapters_db.dart';
import 'package:t_db/t_db.dart';
import 'package:tdb_2_ch_db/adapters/tdb_adapters.dart';
import 'package:tdb_2_ch_db/models/chapter.dart';
import 'package:tdb_2_ch_db/models/chapter_content.dart';

void main(List<String> arguments) async {
  final cdb = ChaptersDB.getInstance();
  await cdb.open('chapters.2.db');
  final box = cdb.getDefaultBox();

  await for (var ch in box.getAllStream()) {
    print(ch);
    final val =  await ch.getContent();
    print(val.chapterNumber);
  }

  await cdb.close();
}

Future<void> tdb2chDB() async {
  final cdb = ChaptersDB.getInstance();
  await cdb.open('chapters.2.db');
  final box = cdb.getDefaultBox();

  final tdb = TDB.getInstance();
  tdb.setAdapterNotExists<Chapter>(ChapterTDBAdapter());
  tdb.setAdapterNotExists<ChapterContent>(ChapterContentTDBAdapter());

  await tdb.open('chapters.db');
  final chBox = tdb.getBox<Chapter>();
  final contentBox = tdb.getBox<ChapterContent>();

  await for (var ch in chBox.getAllStream()) {
    print(ch);
    final content = await contentBox.getOne(
      (value) => value.chapterId == ch.autoId,
    );
    if (content == null) continue;
    // print('content: ${content.chapterId}');
    // add
    await box.add(
      DefaultChapter(
        title: ch.title,
        chapterNumber: ch.number,
        body: content.content,
      ),
    );
  }
  await tdb.close();
  await cdb.close();
}
