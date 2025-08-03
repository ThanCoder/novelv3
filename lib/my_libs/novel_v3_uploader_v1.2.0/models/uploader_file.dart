import 'dart:io';

import 'package:than_pkg/than_pkg.dart';
import 'package:uuid/uuid.dart';

import '../services/server_file_services.dart';
import 'uploader_file_types.dart';


class UploaderFile {
  String id;
  String novelId;
  String name;
  UploaderFileTypes type;
  String filePath;
  String fileUrl;
  bool isDirectLink;
  String fileSize;
  DateTime date;
  // constrctor
  UploaderFile({
    required this.id,
    required this.novelId,
    required this.name,
    required this.type,
    required this.filePath,
    required this.fileUrl,
    required this.isDirectLink,
    required this.fileSize,
    required this.date,
  });

  factory UploaderFile.createEmpty({required String novelId}) {
    return UploaderFile.create(
      novelId: novelId,
      filePath: '',
      fileUrl: '',
      isDirectLink: false,
      fileSize: '0 MB',
    );
  }

  factory UploaderFile.create({
    required String novelId,
    required String filePath,
    required String fileUrl,
    required bool isDirectLink,
    required String fileSize,
    String name = 'Untitled',
    UploaderFileTypes type = UploaderFileTypes.v3Data,
  }) {
    final id = Uuid().v4();
    return UploaderFile(
      id: id,
      novelId: novelId,
      name: name,
      type: type,
      filePath: filePath,
      fileUrl: fileUrl,
      isDirectLink: isDirectLink,
      fileSize: fileSize,
      date: DateTime.now(),
    );
  }

  factory UploaderFile.createFromPath(
    String path, {
    required String novelId,
    required String fileName,
  }) {
    final fileSize = File(path).statSync().size.toDouble().toFileSizeLabel();
    final file = UploaderFile.create(
      novelId: novelId,
      name: fileName,
      type: UploaderFileTypes.getTypeFromPath(path),
      filePath: path,
      fileUrl: ServerFileServices.getFileUrl(fileName),
      isDirectLink: true,
      fileSize: fileSize,
    );
    return file;
  }

  // map
  factory UploaderFile.fromMap(Map<String, dynamic> map) {
    final dateFromMillisecondsSinceEpoch = MapServices.get<int>(map, [
      'date',
    ], defaultValue: 0);

    final type = UploaderFileTypes.getTypeString(
      MapServices.get(map, ['type'], defaultValue: ''),
    );

    return UploaderFile(
      id: MapServices.get(map, ['id'], defaultValue: ''),
      name: MapServices.get(map, ['name'], defaultValue: 'Untitled'),
      novelId: MapServices.get(map, ['novelId'], defaultValue: ''),
      fileUrl: MapServices.get(map, ['fileUrl'], defaultValue: ''),
      filePath: MapServices.get(map, ['filePath'], defaultValue: ''),
      isDirectLink: MapServices.get(map, ['isDirectLink'], defaultValue: false),
      fileSize: MapServices.get(map, ['fileSize'], defaultValue: '0'),
      type: type,
      date: DateTime.fromMillisecondsSinceEpoch(dateFromMillisecondsSinceEpoch),
    );
  }

  Map<String, dynamic> get toMap => {
    'id': id,
    'novelId': novelId,
    'name': name,
    'filePath': filePath,
    'fileUrl': fileUrl,
    'isDirectLink': isDirectLink,
    'fileSize': fileSize,
    'type': type.name,
    'date': date.millisecondsSinceEpoch,
  };

  String get getLocalSizeLable {
    final file = File(filePath);
    if (!file.existsSync()) return '';
    return file.statSync().size.toDouble().toFileSizeLabel();
  }
}
