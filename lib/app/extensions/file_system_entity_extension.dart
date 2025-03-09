import 'dart:io';

extension FileSystemEntityExtension on FileSystemEntity {
  String getName({bool withExt = true}) {
    var name = path.split('/').last;
    if (withExt) {
      return name;
    }
    //replace . ပါလာရင်
    String ext = name.split('.').last;
    final noExt = name.replaceAll('.$ext', '');
    // name = '${noExt.replaceAll('.', ' ')}.$ext';
    return noExt;
  }

  String getExt() {
    return path.split('/').last.split('.').last;
  }

  bool isDirectory() {
    return statSync().type == FileSystemEntityType.directory;
  }

  bool isFile() {
    return statSync().type == FileSystemEntityType.file;
  }
}
