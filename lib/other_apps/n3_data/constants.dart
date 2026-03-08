import 'dart:convert';

String getSecretKey() {
  final list = ['QHRo', 'YW5jb2', 'Rlci5', '2M2Rhd', 'GEu', 'a2V5'];
  return String.fromCharCodes(base64.decode(list.join('')));
}
