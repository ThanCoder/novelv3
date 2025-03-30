import 'package:flutter/material.dart';
import 'package:t_release/services/t_release_services.dart';
import 'package:t_release/services/t_release_version_services.dart';
import 'package:than_pkg/than_pkg.dart';

import '../widgets/core/index.dart';

class ReleaseHomeHeader extends StatefulWidget {
  const ReleaseHomeHeader({super.key});

  @override
  State<ReleaseHomeHeader> createState() => _ReleaseHomeHeaderState();
}

class _ReleaseHomeHeaderState extends State<ReleaseHomeHeader> {
  @override
  void initState() {
    init();
    super.initState();
  }

  String version = '';
  String releaseVersion = '';
  String coverUrl = '';
  bool isLatestVersion = true;
  bool isLoading = true;

  void init() async {
    try {
      final packageInfo = await ThanPkg.platform.getPackageInfo();
      final release = await TReleaseServices.instance.getRelease();
      isLatestVersion = !await TReleaseVersionServices.instance
          .isLatestVersion(packageInfo.version);

      version = packageInfo.version;

      if (release != null) {
        releaseVersion = release.version;
        coverUrl = release.coverUrl;
      }
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return TLoader();
    }
    return Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 5,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: MyImageUrl(url: coverUrl),
          ),
          Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ယခု Version: $version'),
              Text('နောက်ဆုံး Version: $isLatestVersion'),
              Text('Release Version: $releaseVersion'),
            ],
          ),
        ],
      ),
    );
  }
}
