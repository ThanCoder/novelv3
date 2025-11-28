import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

import '../setting.dart';
import 'path_util.dart';

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
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListTile(title: Text('တွက်ချက်နေပါတယ်...'));
        }
        final (size, itemCount) = snapshot.data ?? ('', 0);
        if (snapshot.hasData && size.isNotEmpty) {
          return Card(
            child: ListTile(
              title: Text('Cache: $size - ( Items: $itemCount )'),
              onTap: _cleanCache,
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Future<(String, int)> _getCalSize() async {
    final dir = Directory(getCachePath);
    int sizeInt = 0;
    int itemCount = 0;
    if (dir.existsSync()) {
      for (var file in dir.listSync()) {
        if (!file.isFile) continue;
        sizeInt += (await file.stat()).size;
        itemCount++;
      }
    }
    // await Future.delayed(Duration(seconds: 3));
    final label = sizeInt > 0 ? sizeInt.toDouble().toFileSizeLabel() : '';
    return (label, itemCount);
  }

  void _cleanCache() async {
    // local func
    Future<void> scanDir(Directory dir) async {
      try {
        if (dir.existsSync()) {
          for (var file in dir.listSync()) {
            if (file.isDirectory) {
              await scanDir(Directory(file.path));
              await file.delete(recursive: true);
            } else if (file.isFile) {
              // print('del: ${file.path}');
              await file.delete(recursive: true);
            }
          }
        }
      } catch (e) {
        Setting.showDebugLog(e.toString(), tag: 'AppCacheManager:_cleanCache');
      }
    }

    // call inner func
    await scanDir(Directory(getCachePath));

    if (!mounted) return;
    setState(() {});
  }

  String get getCachePath => PathUtil.getCachePath();
}

