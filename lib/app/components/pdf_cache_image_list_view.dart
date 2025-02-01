import 'package:flutter/material.dart';
import 'package:novel_v3/app/models/pdf_cache_model.dart';
import 'package:novel_v3/app/widgets/my_image_file.dart';

class PdfCacheImageListView extends StatelessWidget {
  List<PdfCacheModel> imageList;
  ScrollController? scrollController;
  PdfCacheImageListView({
    super.key,
    required this.imageList,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: scrollController,
      separatorBuilder: (context, index) {
        return Center(
          child: Text('page ${index + 1}'),
        );
      },
      itemCount: imageList.length,
      itemBuilder: (context, index) => Container(
        key: ValueKey(index),
        child: _ListItem(
          image: imageList[index],
        ),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  PdfCacheModel image;
  _ListItem({required this.image});

  @override
  Widget build(BuildContext context) {
    return MyImageFile(
      path: image.path,
    );
  }
}
