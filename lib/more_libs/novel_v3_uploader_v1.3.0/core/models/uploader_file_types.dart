enum UploaderFileTypes {
  v3Data,
  chapter,
  pdf,
  unknown;

  static UploaderFileTypes getTypeFromPath(String path) {
    if (path.endsWith('.pdf')) {
      return pdf;
    }
    if (path.endsWith('.npz')) {
      return v3Data;
    }
    return unknown;
  }

  static UploaderFileTypes getTypeString(String type) {
    if (type == v3Data.name) {
      return v3Data;
    }
    if (type == chapter.name) {
      return chapter;
    }
    if (type == pdf.name) {
      return pdf;
    }
    return unknown;
  }
}
