extension StringExtension on String {
  String toCaptalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1, length)}';
  }

  String getName({bool withExt = true}) {
    var name = split('/').last;
    if (withExt) {
      return name;
    }
    //replace . ပါလာရင်
    String ext = name.split('.').last;
    final noExt = name.replaceAll('.$ext', '');
    // name = '${name.replaceAll('.', ' ')}.$ext';
    return noExt;
  }

  String getExt() {
    return split('/').last.split('.').last;
  }
}
