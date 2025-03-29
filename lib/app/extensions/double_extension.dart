extension DoubleExtension on double {
  String toParseFileSize(double size, {int asFixed = 2}) {
    String res = '';
    int pow = 1024;
    final labels = ['byte', 'KB', 'MB', 'GB', 'TB'];
    int i = 0;
    while (size > pow) {
      size /= pow;
      i++;
    }

    res = '${size.toStringAsFixed(asFixed)} ${labels[i]}';

    return res;
  }
}
