import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/core/utils.dart';
import 'package:novel_v3/more_libs/setting/core/path_util.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:image/image.dart' as img;

class CoverImageSizeReducerDialog extends StatefulWidget {
  const CoverImageSizeReducerDialog({super.key});

  @override
  State<CoverImageSizeReducerDialog> createState() =>
      _CoverImageSizeReducerDialogState();
}

class _CoverImageSizeReducerDialogState
    extends State<CoverImageSizeReducerDialog> {
  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  bool isLoading = false;
  bool isSuccess = false;
  String errorText = '';
  final List<File> _reduceImageList = [];
  int minImageSize = (1024 * 1024) * 1;

  void init() async {
    try {
      setState(() {
        errorText = '';
        isLoading = true;
      });
      // await Future.delayed(Duration(seconds: 3));
      await _addBitImage();
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      errorText = e.toString();
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _addBitImage() async {
    _reduceImageList.clear();
    final dir = Directory(PathUtil.getSourcePath());
    if (!dir.existsSync()) return;
    await for (var file in dir.list(followLinks: false)) {
      if (!file.isDirectory) continue;
      final imageFile = File(file.path.pathJoin('cover.png'));
      if (!imageFile.existsSync()) continue;
      if (imageFile.size > minImageSize) {
        _reduceImageList.add(imageFile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading) TLoader(),
        if (!isLoading && errorText.isNotEmpty)
          Text(errorText, style: TextStyle(color: Colors.red)),
        if (!isLoading && _reduceImageList.isNotEmpty) _reduceImagesWidget(),
        if (isSuccess)
          Text('Success', style: TextStyle(fontSize: 17, color: Colors.green)),
        SizedBox(height: 20),
        _buttons(),
      ],
    );
  }

  Widget _reduceImagesWidget() {
    return FutureBuilder(
      future: Future.wait(_reduceImageList.map((e) => e.sizeAsync())),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          Text('တွက်ချက်နေပါတယ်....');
        }
        final size = snapshot.data ?? [];
        return Column(
          children: [
            Row(children: [Icon(Icons.list), Text('Count: ${size.length}')]),
            Row(
              children: [
                Icon(Icons.sd_card_rounded),
                Text(
                  'Size: ${size.fold(0, (previousValue, element) => previousValue + element).fileSizeLabel()}',
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  context.closeNavigator();
                },
          child: Text('ထွက်မယ်'),
        ),
        TextButton(
          onPressed: isLoading ? null : _reduceImages,
          child: Text('Size လျော့ချမယ်'),
        ),
      ],
    );
  }

  void _reduceImages() async {
    setState(() {
      isLoading = true;
      isSuccess = false;
      errorText = '';
    });
    try {
      for (var file in _reduceImageList) {
        final bytes = await file.readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) continue;
        final resizeImage = img.copyResize(
          image,
          width: 880,
          height: 1200,
          interpolation: img.Interpolation.average, // quality ပိုကောင်းအောင်
        );
        final compressedBytes = img.encodeJpg(resizeImage, quality: 75);
        await file.writeAsBytes(compressedBytes);
      }
      _reduceImageList.clear();
      if (!mounted) return;
      setState(() {
        isLoading = false;
        isSuccess = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isSuccess = false;
        isLoading = false;
        errorText = e.toString();
      });
    }
  }
}
