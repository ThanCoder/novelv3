import 'package:than_pkg/than_pkg.dart';
import 'package:uuid/uuid.dart';

class HelperFile {
  String id;
  String title;
  String desc;
  List<String> imagesUrl;
  DateTime date;
  HelperFile({
    required this.id,
    required this.title,
    required this.desc,
    required this.imagesUrl,
    required this.date,
  });

  factory HelperFile.create({
    String title = 'Untitled',
    String desc = '',
    required List<String> imagesUrl,
  }) {
    final id = Uuid().v4();
    return HelperFile(
      id: id,
      title: title,
      desc: desc,
      imagesUrl: imagesUrl,
      date: DateTime.now(),
    );
  }

  factory HelperFile.fromMap(Map<String, dynamic> map) {
    final dateInt = MapServices.get<int>(map, ['date'], defaultValue: 0);
    final strList = MapServices.get(map, [
      'imagesUrl',
    ], defaultValue: []);

    return HelperFile(
      id: MapServices.get(map, ['id'], defaultValue: Uuid().v4()),
      title: MapServices.get(map, ['title'], defaultValue: 'Untitled'),
      desc: MapServices.get(map, ['desc'], defaultValue: ''),
      imagesUrl:List<String>.from(strList),
      date: DateTime.fromMillisecondsSinceEpoch(dateInt),
    );
  }

  Map<String, dynamic> get toMap => {
    'id': id,
    'title': title,
    'desc': desc,
    'imagesUrl': imagesUrl,
    'date': date.millisecondsSinceEpoch,
  };
}
