import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class CurrentVersionComponent extends StatelessWidget {
  const CurrentVersionComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ThanPkg.platform.getPackageInfo(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return TLoader();
        }
        if (snapshot.data == null) return const SizedBox.shrink();
        final version = snapshot.data!.version;
        return TListTileWithDesc(
          title: 'Current Version: $version',
        );
      },
    );
  }
}
