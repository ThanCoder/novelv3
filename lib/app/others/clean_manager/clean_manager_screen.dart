import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/clean_manager/clean_cache_manager.dart';
import 'package:novel_v3/app/others/clean_manager/clean_cahe_manager_dialog.dart';
import 'package:novel_v3/app/others/clean_manager/clean_novel_cache_manager.dart';

class CleanManagerScreen extends StatefulWidget {
  const CleanManagerScreen({super.key});

  @override
  State<CleanManagerScreen> createState() => _CleanManagerScreenState();
}

class _CleanManagerScreenState extends State<CleanManagerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Clean Manager')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(Icons.cleaning_services_outlined),
              title: Text('Novel ထဲက မလိုအပ်တာတွေ ရှင်းမယ်'),
              onTap: _cleanNovelCache,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.cleaning_services_outlined),
              title: Text('Cache ရှင်းလင်းမယ်'),
              onTap: _cleanCache,
            ),
          ],
        ),
      ),
    );
  }

  void _cleanNovelCache() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          CleanCaheManagerDialog(novelCacheManager: CleanNovelCacheManager()),
    );
  }

  void _cleanCache() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          CleanCaheManagerDialog(novelCacheManager: CleanCacheManager()),
    );
  }
}
