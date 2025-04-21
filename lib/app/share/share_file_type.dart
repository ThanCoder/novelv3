enum ShareFileType {
  all,
  unknownFile,
  content,
  link,
  pdf,
  chapter,
  readed,
  cover,
  config,
  png,
  mc,
  author,
}

extension ShareFileTypeExtension on ShareFileType {
  static ShareFileType getTypeFromString(String type) {
    if (type == ShareFileType.author.name) {
      return ShareFileType.author;
    }
    if (type == ShareFileType.chapter.name) {
      return ShareFileType.chapter;
    }
    if (type == ShareFileType.config.name) {
      return ShareFileType.config;
    }
    if (type == ShareFileType.content.name) {
      return ShareFileType.config;
    }
    if (type == ShareFileType.cover.name) {
      return ShareFileType.cover;
    }
    if (type == ShareFileType.link.name) {
      return ShareFileType.link;
    }
    if (type == ShareFileType.mc.name) {
      return ShareFileType.mc;
    }
    if (type == ShareFileType.pdf.name) {
      return ShareFileType.pdf;
    }
    if (type == ShareFileType.png.name) {
      return ShareFileType.png;
    }
    if (type == ShareFileType.readed.name) {
      return ShareFileType.readed;
    }
    return ShareFileType.unknownFile;
  }
}
