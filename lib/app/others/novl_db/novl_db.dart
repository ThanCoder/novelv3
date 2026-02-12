import 'dart:io';
import 'dart:typed_data';

import 'package:hb_db/hb_db.dart';
import 'package:novel_v3/core/models/novel_meta.dart';
import 'package:novel_v3/app/others/novl_db/novl_info.dart';
import 'package:than_pkg/than_pkg.dart';

class NovlDB {
  static const String dbType = 'NOVL';
  static const String extName = 'novl';
  static final db = HBDB.getInstance();
  static final _dbConfig = DBConfig.defaultSetting().copyWith(
    saveLocalDBLockFile: false,
    type: dbType,
  );

  ///
  /// ### Register Adapters
  ///
  static void registerAdaptersNotExists() {
    db.registerAdapterNotExists<NovlInfo>(NovlInfoAdapter());
    db.registerAdapterNotExists<NovelMeta>(NovelMetaAdapter());
  }

  ///
  /// ### Export DB from Directory
  ///
  static Future<void> exportHBDB(
    Directory dir, {
    required String dbPath,
    required NovlInfo info,
    void Function(double progress, String message)? onProgress,
  }) async {
    if (!dir.existsSync()) return;
    registerAdaptersNotExists();
    await db.open(dbPath, config: _dbConfig);
    // info
    final infoBox = db.getBox<NovlInfo>();
    await infoBox.add(info);

    // add meta
    final meta = await NovelMeta.fromPath(dir.path);
    final box = db.getBox<NovelMeta>();
    await box.add(meta);
    // onProgress?.call(0.5, 'Added Novel Meta');
    // cover
    final coverFile = File(pathJoin(dir.path, 'cover.png'));
    if (coverFile.existsSync()) {
      final imageData = await coverFile.readAsBytes();
      await db.setCover(imageData);
      // onProgress?.call(1, 'Added Cover');
    }
    // add files
    for (var file in dir.listSync(followLinks: false)) {
      await db.addFile(
        File(file.path),
        isCompressed: true,
        onProgress: onProgress,
      );
    }
    await db.close();
  }

  ///
  /// ### Saves the provided imageData directly to savePath without opening the DB.
  ///
  static Future<bool> extractCoverToFile(
    String dbPath, {
    required String savePath,
    bool override = false,
  }) async {
    return await HBDB.extractCoverToFile(dbPath, savePath: savePath);
  }

  ///
  /// ### Read PDF List
  ///
  static Future<List<DBFEntry>> readPDF(String dbPath) async {
    List<DBFEntry> list = [];
    final entries = await HBDB.readFileEntriesFromDBFile(dbPath);
    for (var entry in entries) {
      if (!entry.name.endsWith('.pdf')) continue;
      list.add(entry);
    }
    return list;
  }

  static Future<List<DBFEntry>> readFiles(String dbPath) async {
    return await HBDB.readFileEntriesFromDBFile(dbPath);
  }

  ///
  /// ### Read NovelMeta from path
  ///
  static Future<NovelMeta?> readNovelMeta(String dbPath) async {
    registerAdaptersNotExists();

    await db.open(dbPath, config: _dbConfig);
    final box = db.getBox<NovelMeta>();
    final list = await box.getAll();
    await db.close();
    if (list.isEmpty) return null;
    return list.first;
  }

  ///
  /// ### Read Novl Info from path
  ///
  static Future<NovlInfo?> readNovlInfo(String dbPath) async {
    registerAdaptersNotExists();

    await db.open(dbPath, config: _dbConfig);
    final box = db.getBox<NovlInfo>();
    final list = await box.getAll();
    await db.close();
    if (list.isEmpty) return null;
    return list.first;
  }

  static Future<Uint8List?> getCoverData(String dbPath) async {
    return await HBDB.readCoverFromDBFile(dbPath);
  }

  static Future<String?> readType(String dbPath) async {
    final header = await HBDB.getHeaderFromDBFile(dbPath);
    if (header == null) return null;
    return header.type;
  }

  ///
  /// ### Export HBDB Export Entry File
  ///
  static Future<void> exportFile(
    DBFEntry entry, {
    required String outpath,
    OnDBProgressCallback? onProgress,
  }) async {
    await entry.extract(outpath, onProgress: onProgress);
  }

  ///
  /// ### Check Novel DB File
  ///
  static Future<bool> isDBFile(String dbPath) async {
    return await HBDB.checkDBTypeFromDBFile(dbPath, dbType);
  }
}
