import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/clean_manager/clean_manager.dart';
import 'package:t_widgets/widgets/index.dart';
import 'package:than_pkg/extensions/index.dart';

class CleanCaheManagerDialog extends StatefulWidget {
  final CleanManager novelCacheManager;
  const CleanCaheManagerDialog({super.key, required this.novelCacheManager});

  @override
  State<CleanCaheManagerDialog> createState() => _CleanCaheManagerDialogState();
}

class _CleanCaheManagerDialogState extends State<CleanCaheManagerDialog> {
  CacheData? cacheData;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      scrollable: true,
      content: FutureBuilder(
        future: widget.novelCacheManager.getCacheInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 5,
                children: [TLoader.random(), Text('တွက်ချက်နေပါတယ်....')],
              ),
            );
          }
          if (!snapshot.hasData) {
            return SizedBox.fromSize();
          }
          cacheData = snapshot.data!;
          final files = cacheData!.files;
          if (files.isEmpty) {
            return Center(
              child: Text(
                'Cache မရှိပါ!',
                style: TextStyle(fontSize: 17, color: Colors.green),
              ),
            );
          }

          return TScrollableColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cache Count: ${cacheData!.count}'),
              Text('Size: ${cacheData!.size}'),
              Divider(),
              ExpansionTile(
                title: Text('Clean Path List'),
                children: List.generate(files.length, (index) {
                  final file = files[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        file.getName().trim(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Type: ${file.isDirectory ? 'Folder' : 'File'}',
                        style: TextStyle(fontSize: 12),
                      ),
                      Divider(),
                    ],
                  );
                }),
              ),
            ],
          );
        },
      ),
      actions: _getActions(),
    );
  }

  List<Widget> _getActions() {
    return [
      TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Text('Close'),
      ),
      TextButton(
        onPressed: () async {
          if (cacheData == null) return;
          await widget.novelCacheManager.clean(cacheData!);
          cacheData = null;
          if (!mounted) return;
          setState(() {});
        },
        child: Text('ရှင်းလင်းမယ်'),
      ),
    ];
  }
}
