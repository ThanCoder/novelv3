import 'package:t_server/core/method.dart';
import 'package:than_pkg/than_pkg.dart';

class ShareDoc {
  final String name;
  final Method method;
  final String requestUrl;
  final String returnType;
  ShareDoc({
    required this.name,
    required this.method,
    required this.requestUrl,
    required this.returnType,
  });
  factory ShareDoc.create({
    String name = 'home',
    Method method = Method.get,
    String requestUrl = '/',
    required String returnType,
  }) {
    return ShareDoc(
      name: name,
      method: method,
      requestUrl: requestUrl,
      returnType: returnType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'method': method.value,
      'requestUrl': requestUrl,
      'returnType': returnType,
    };
  }

  factory ShareDoc.fromMap(Map<String, dynamic> map) {
    return ShareDoc(
      name: map['name'] as String,
      method: Method.fromName(map.getString(['method'], def: 'get')),
      requestUrl: map['requestUrl'] as String,
      returnType: map['returnType'] as String,
    );
  }
}
