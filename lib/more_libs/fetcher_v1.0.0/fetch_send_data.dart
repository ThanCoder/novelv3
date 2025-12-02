// ignore_for_file: public_member_api_docs, sort_constructors_first
class FetchSendData {
  String url;
  int chapterNumber;
  FetchSendData({required this.url, required this.chapterNumber});

  factory FetchSendData.createEmpty() {
    return FetchSendData(url: '', chapterNumber: 1);
  }
}
