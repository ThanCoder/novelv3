import 'package:than_pkg/services/t_map.dart';

enum TutorialTypes {
  images,
  unknown;

  static TutorialTypes getName(String name) {
    if (images.name == name) {
      return images;
    }
    return unknown;
  }
}

class Tutorial {
  final String id;
  final String title;
  final String desc;
  final String packageName;
  final int imageListRangeNumber;
  final String rootDirPath;
  final String images;
  final TutorialTypes type;
  final String mimeType;

  Tutorial({
    required this.id,
    required this.title,
    required this.desc,
    required this.packageName,
    required this.imageListRangeNumber,
    required this.rootDirPath,
    required this.images,
    required this.type,
    required this.mimeType,
  });

  List<String> getImageList(String rootPath) {
    List<String> list = [];
    for (var i = 1; i <= imageListRangeNumber; i++) {
      list.add('$rootPath/$rootDirPath/$i.$mimeType');
    }
    return list;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'desc': desc,
      'packageName': packageName,
      'imageListRangeNumber': imageListRangeNumber,
      'rootDirPath': rootDirPath,
      'images': images,
      'type': type.name,
      'mimeType': mimeType,
    };
  }

  factory Tutorial.fromMap(Map<String, dynamic> map) {
    return Tutorial(
      id: map.getString(['id']),
      title: map.getString(['title']),
      desc: map.getString(['desc']),
      packageName: map.getString(['packageName']),
      imageListRangeNumber: map.getInt(['imageListRangeNumber']),
      rootDirPath: map.getString(['rootDirPath']),
      images: map.getString(['images']),
      type: TutorialTypes.getName(map.getString(['type'])),
      mimeType: map.getString(['mimeType'], def: 'png'),
    );
  }
}
