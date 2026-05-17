import 'dart:async';
import 'dart:io';

import 'package:chapters_db/chapters_db.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/core/adapters/tdb_adapters.dart';
import 'package:novel_v3/core/databases/chapter_db_manager.dart';
import 'package:novel_v3/core/models/chapter.dart';
import 'package:novel_v3/core/models/chapter_content.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:t_db/t_db.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class DbMigration {
  static bool isDBMigration(String novelId) {
    final newDB = File(
      PathUtil.getSourcePath(
        name: novelId,
      ).join(ChapterDBManager.newChapterDBName),
    );
    final oldDB = File(
      PathUtil.getSourcePath(
        name: novelId,
      ).join(ChapterDBManager.oldChapterDBName),
    );
    // new db မရှိဘူး old db ကို ပြန်စစ်တယ်
    if (!newDB.existsSync() && oldDB.existsSync() && oldDB.lengthSync() > 9) {
      return true;
    }
    // new db ရှိတယ် old db ကို ပြန်စစ်တယ်
    if (newDB.existsSync() &&
        newDB.lengthSync() == 0 &&
        oldDB.existsSync() &&
        oldDB.lengthSync() > 9) {
      return true;
    }
    return false;
  }

  static Future<void> migrate(BuildContext context, String novelId) async {
    // print('need migration');

    final completer = Completer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(
        progressManager: MigrationManager(
          novelId: novelId,
          completer: completer,
        ),
      ),
    );
    return await completer.future;
  }
}

class MigrationManager extends ProgressManagerInterface {
  final String novelId;
  final Completer completer;

  MigrationManager({required this.novelId, required this.completer});

  bool isCancel = false;

  @override
  void cancel() {
    isCancel = true;
  }

  @override
  Future<void> start(StreamController<ProgressMessage> streamController) async {
    try {
      if (Platform.isAndroid) {
        ThanPkg.android.app.toggleKeepScreenOn(isKeep: true);
      }
      final novelPath = PathUtil.getSourcePath(name: novelId);

      streamController.add(
        ProgressMessage.preparing(message: 'Database Migration'),
      );

      final cdb = ChaptersDB();
      await cdb.open(novelPath.join(ChapterDBManager.newChapterDBName));
      final newBox = cdb.getDefaultBox();

      // old db
      final tdb = TDB();
      tdb.setAdapterNotExists<Chapter>(ChapterTDBAdapter());
      tdb.setAdapterNotExists<ChapterContent>(ChapterContentTDBAdapter());

      await tdb.open(novelPath.join(ChapterDBManager.oldChapterDBName));
      final chBox = tdb.getBox<Chapter>();
      final contentBox = tdb.getBox<ChapterContent>();
      // cache ထဲသိမ်းထား
      final Map<int, Chapter> chCache = {};
      await for (var ch in chBox.getAllStream()) {
        chCache[ch.autoId] = ch;
        streamController.add(
          ProgressMessage.progress(
            index: 0,
            indexLength: 0,
            progress: 0,
            message: 'Ch: ${ch.number} Fetching.....',
          ),
        );
      }
      int index = 0;
      await for (var content in contentBox.getAllStream()) {
        // await Future.delayed(Duration(milliseconds: 200));
        if (isCancel) {
          break;
        }
        index++;
        final ch = chCache[content.chapterId];
        if (ch == null) continue;

        streamController.add(
          ProgressMessage.progress(
            index: index,
            indexLength: chCache.length,
            progress: index / chCache.length,
            message: 'Database ပြောင်းလဲနေပါတယ်...\nChapter: ${ch.number}',
          ),
        );
        await newBox.add(
          DefaultChapter(
            title: ch.title,
            chapterNumber: ch.number,
            body: content.content,
          ),
        );
      }

      streamController.add(ProgressMessage.done());

      await tdb.close();
      await cdb.close();

      if (isCancel) {
        final newDbFile = File(
          novelPath.join(ChapterDBManager.newChapterDBName),
        );
        if (newDbFile.existsSync()) {
          await newDbFile.delete();
        }
      }

      await streamController.close();
      completer.complete();
    } catch (e) {
      streamController.addError(e);
      completer.completeError(e);
    } finally {
      if (Platform.isAndroid) {
        ThanPkg.android.app.toggleKeepScreenOn(isKeep: false);
      }
    }
  }
}
