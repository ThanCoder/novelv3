// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:than_pkg/than_pkg.dart';
import 'package:uuid/uuid.dart';

import '../../services/server_file_services.dart';
import 'uploader_file_types.dart';

class UploaderFile {
  final String id;
  final String novelId;
  final String name;
  final UploaderFileTypes type;
  final String filePath;
  final String fileUrl;
  final bool isDirectLink;
  final String fileSize;
  final DateTime date;
  final String description;
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
    required this.description,
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
    String description = '',
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
      description: description,
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
    final dateInt = map.getInt(['date']);
    final type = UploaderFileTypes.getTypeString(map.getString(['type']));

    return UploaderFile(
      id: map.getString(['id']),
      name: map.getString(['name']),
      novelId: map.getString(['novelId']),
      fileUrl: map.getString(['fileUrl']),
      filePath: map.getString(['filePath']),
      isDirectLink: map.getBool(['isDirectLink']),
      fileSize: map.getString(['fileSize']),
      type: type,
      date: DateTime.fromMillisecondsSinceEpoch(dateInt),
      description: map.getString(['description']),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'novelId': novelId,
    'name': name,
    'filePath': filePath,
    'fileUrl': fileUrl,
    'isDirectLink': isDirectLink,
    'fileSize': fileSize,
    'type': type.name,
    'date': date.millisecondsSinceEpoch,
    'description': description,
  };

  String get getLocalSizeLable {
    final file = File(filePath);
    if (!file.existsSync()) return '';
    return file.statSync().size.toDouble().toFileSizeLabel();
  }

  UploaderFile copyWith({
    String? id,
    String? novelId,
    String? name,
    UploaderFileTypes? type,
    String? filePath,
    String? fileUrl,
    bool? isDirectLink,
    String? fileSize,
    DateTime? date,
    String? description,
  }) {
    return UploaderFile(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      name: name ?? this.name,
      type: type ?? this.type,
      filePath: filePath ?? this.filePath,
      fileUrl: fileUrl ?? this.fileUrl,
      isDirectLink: isDirectLink ?? this.isDirectLink,
      fileSize: fileSize ?? this.fileSize,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
