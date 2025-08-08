import 'package:flutter/material.dart';
import '../../novel_dir_db.dart';

class EditChapterScreen extends StatelessWidget {
  Chapter? chapter;
  EditChapterScreen({
    super.key,
    this.chapter,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Chapter'),
      ),
    );
  }
}
