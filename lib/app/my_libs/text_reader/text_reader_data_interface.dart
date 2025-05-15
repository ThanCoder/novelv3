abstract class TextReaderDataInterface<T> {
  String getContent();
  T getNext();
  T getPrev();
  bool isExistsNext();
  bool isExistsPrev();
}
