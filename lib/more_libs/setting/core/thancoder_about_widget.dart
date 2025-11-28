import 'package:novel_v3/more_libs/setting/core/markdown_reader.dart';
import 'package:novel_v3/more_libs/setting/setting.dart';
import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

class ThancoderAboutWidget extends StatelessWidget {
  const ThancoderAboutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "App Info",
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('CHANGELOG'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarkdownReader(
                    assetFileName: 'CHANGELOG.md',
                    title: Text('CHANGELOG'),
                  ),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.menu_book),
            title: Text('README'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MarkdownReader(
                    assetFileName: 'README.md',
                    title: Text('README'),
                  ),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.telegram),
            title: Text('Developer'),
            onTap: () {
              ThanPkg.platform.launch('https://t.me/thancoder_novel');
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.new_releases),
            title: Text('App Release'),
            onTap: () {
              if (Setting.instance.releaseUrl == null) {
                Setting.showDebugLog(
                  '[App Release]: `Setting.instance.releaseUrl` == null',
                );
                return;
              }
              ThanPkg.platform.launch(Setting.instance.releaseUrl!);
            },
          ),
        ],
      ),
    );
  }
}
