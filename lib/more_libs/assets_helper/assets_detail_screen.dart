import 'package:flutter/material.dart';
import 'package:novel_v3/more_libs/assets_helper/assets_file.dart';
import 'package:t_widgets/t_widgets_dev.dart';

class AssetsDetailScreen extends StatelessWidget {
  final AssetsFile file;
  const AssetsDetailScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(file.title)),
      body: TScrollableColumn(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: _getList(),
      ),
    );
  }

  List<Widget> _getList() {
    return List.generate(
      file.assetFilesNumberCount,
      (index) =>
          _getListItem('${file.assetsRootPath}/${index + 1}.${file.mimeType}'),
    ).toList();
  }

  Widget _getListItem(String assetsPath) {
    return Image.asset(
      assetsPath,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('[Image.asset]: ${error.toString()}');
        return Text('Error Image');
      },
    );
  }
}
