// ignore_for_file: constant_identifier_names

enum PdfReaderType {
  RXPdfReader,
  SinglePage,
  TPdfReader;

  static PdfReaderType getType(String name) {
    if (name == SinglePage.name) return SinglePage;
    if (name == TPdfReader.name) return TPdfReader;
    return RXPdfReader;
  }
}
