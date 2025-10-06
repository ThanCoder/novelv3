import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:than_pkg/services/t_map.dart';

import '../../novel_v3_uploader.dart';

class ApiUploaderFileDatabase extends ApiDatabaseInterface<UploaderFile> {
  ApiUploaderFileDatabase()
    : super(
        root: '${NovelV3Uploader.instance.getApiServerUrl()}/content_db',
        storage: Storage(
          root: '${NovelV3Uploader.instance.getApiServerUrl()}/files',
        ),
      );

  @override
  Future<List<UploaderFile>> getAll({
    Map<String, dynamic> query = const {},
  }) async {
    List<UploaderFile> list = [];
    try {
      final id = query.getString(['id']);
      if (id.isEmpty) {
        throw Exception('`novelId`[id]: Not Found!');
      }
      final content = await getDBContent('$root/$id.db.json');
      // print(content);
      List<dynamic> mapList = jsonDecode(content);
      list = mapList.map((map) => fromMap(map)).toList();
    } catch (e) {
      debugPrint('[ApiUploaderFileDatabase:getAll]: ${e.toString()}');
    }
    return list;
  }

  @override
  UploaderFile fromMap(Map<String, dynamic> map) {
    return UploaderFile.fromMap(map);
  }

  @override
  Map<String, dynamic> toMap(UploaderFile value) {
    return value.toMap();
  }

  @override
  String getId(UploaderFile value) {
    return value.id;
  }
}
