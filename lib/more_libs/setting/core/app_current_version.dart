import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

import '../setting.dart';

class AppCurrentVersion extends StatelessWidget {
  const AppCurrentVersion({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ThanPkg.platform.getPackageInfo(),
      builder: (context, snapshot) {
        final data = snapshot.data;
        if (snapshot.hasData && data != null) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.new_releases),
              title: Text(
                'Current Version: ${data.version} ${Setting.appVersionLabel}',
              ),
              onTap: Setting.instance.releaseUrl == null
                  ? null
                  : () {
                      ThanPkg.platform.launch(Setting.instance.releaseUrl!);
                    },
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
