import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:than_pkg/than_pkg.dart';

import '../setting.dart';

class AppCurrentVersion extends StatelessWidget {
  const AppCurrentVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FutureBuilder(
        future: PackageInfo.fromPlatform(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (snapshot.hasData && data != null) {
            return ListTile(
              leading: Icon(Icons.new_releases),
              title: Text(
                'Current Version: ${data.version} ${Setting.appVersionLabel}',
              ),
              onTap: Setting.instance.releaseUrl == null
                  ? null
                  : () {
                      ThanPkg.platform.launch(Setting.instance.releaseUrl!);
                    },
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}
