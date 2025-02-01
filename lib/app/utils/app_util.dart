import 'package:intl/intl.dart';

String getParseDate(int date) {
  String res = '';
  try {
    final lastModifiedDateTime = DateTime.fromMillisecondsSinceEpoch(date);

    // Format DateTime
    res = DateFormat('yyyy-MM-dd HH:mm:ss').format(lastModifiedDateTime);
  } catch (e) {}
  return res;
}

String getParseFileSize(double size) {
  String res = '';
  int pow = 1024;
  final labels = ['byte', 'KB', 'MB', 'GB', 'TB'];
  int i = 0;
  while (size > pow) {
    size /= pow;
    i++;
  }

  res = '${size.toStringAsFixed(2)} ${labels[i]}';

  return res;
}
