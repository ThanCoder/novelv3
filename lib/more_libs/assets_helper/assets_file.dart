// ignore_for_file: public_member_api_docs, sort_constructors_first
class AssetsFile {
  final String id;
  final String title;
  final String desc;
  final String assetsRootPath;
  final String mimeType;
  final int assetFilesNumberCount;
  AssetsFile({
    required this.id,
    required this.title,
    required this.desc,
    required this.assetsRootPath,
    required this.mimeType,
    required this.assetFilesNumberCount,
  });

  factory AssetsFile.create({
    required String id,
    required String title,
    required String assetsRootPath,
    required int assetFilesNumberCount,
    String mimeType = 'jpg',
    String desc = '',
  }) {
    return AssetsFile(
      id: id,
      title: title,
      desc: desc,
      assetsRootPath: assetsRootPath,
      mimeType: mimeType,
      assetFilesNumberCount: assetFilesNumberCount,
    );
  }
}
