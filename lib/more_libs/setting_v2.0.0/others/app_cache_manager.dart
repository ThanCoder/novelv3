import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

import '../setting.dart';

class AppCacheManager extends StatefulWidget {
  const AppCacheManager({super.key});

  @override
  State<AppCacheManager> createState() => _AppCacheManagerState();
}

class _AppCacheManagerState extends State<AppCacheManager> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getCalSize(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.waiting) {
          return ListTile(title: Text('တွက်ချက်နေပါတယ်...'));
        }
        final size = asyncSnapshot.data ?? '';
        if (asyncSnapshot.hasData && size.isNotEmpty) {
          return Card(
            child: ListTile(title: Text('Cache: $size'), onTap: _cleanCache),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Future<String> _getCalSize() async {
    final dir = Directory(getCachePath);
    int sizeInt = 0;
    if (dir.existsSync()) {
      for (var file in dir.listSync()) {
        if (!file.isFile()) continue;
        sizeInt += (await file.stat()).size;
      }
    }
    // await Future.delayed(Duration(seconds: 3));

    return sizeInt > 0 ? sizeInt.toDouble().toFileSizeLabel() : '';
  }

  void _cleanCache() async {
    try {
      final dir = Directory(getCachePath);
      if (dir.existsSync()) {
        for (var file in dir.listSync()) {
          if (!file.isFile()) continue;
          await file.delete(recursive: true);
        }
      }
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      Setting.showDebugLog(e.toString(), tag: 'AppCacheManager:_cleanCache');
    }
  }

  String get getCachePath => PathUtil.getCachePath();
}
