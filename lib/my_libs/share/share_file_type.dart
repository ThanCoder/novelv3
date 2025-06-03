enum ShareFileType {
  all,
  unknownFile,
  pdf,
  chapter,
  cover,
  config,
}

extension ShareFileTypeExtension on ShareFileType {
  static ShareFileType getTypeFromString(String type) {
    if (type == ShareFileType.chapter.name) {
      return ShareFileType.chapter;
    }
    if (type == ShareFileType.config.name) {
      return ShareFileType.config;
    }
    if (type == ShareFileType.cover.name) {
      return ShareFileType.cover;
    }
    if (type == ShareFileType.pdf.name) {
      return ShareFileType.pdf;
    }
    return ShareFileType.unknownFile;
  }
}
