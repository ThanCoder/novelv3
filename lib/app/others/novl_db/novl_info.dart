import 'package:hb_db/hb_db.dart';

class NovlInfoAdapter extends HBAdapter<NovlInfo> {
  @override
  NovlInfo fromMap(Map<String, dynamic> map) {
    return NovlInfo.fromMap(map);
  }

  @override
  int getUniqueFieldId() {
    return 1;
  }

  @override
  Map<String, dynamic> toMap(NovlInfo value) {
    return value.toMap();
  }
}

class NovlInfo {
  final String desc;
  NovlInfo({required this.desc});

  NovlInfo copyWith({String? desc}) {
    return NovlInfo(desc: desc ?? this.desc);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'desc': desc};
  }

  factory NovlInfo.fromMap(Map<String, dynamic> map) {
    return NovlInfo(desc: map['desc'] as String);
  }
}
