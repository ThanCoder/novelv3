import 'package:flutter/material.dart';
import 'package:t_release/services/t_release_version_services.dart';
import 'package:than_pkg/than_pkg.dart';

import '../widgets/core/index.dart';
import 'release_home_screen.dart';

class ReleaseVersionActionButton extends StatefulWidget {
  const ReleaseVersionActionButton({super.key});

  @override
  State<ReleaseVersionActionButton> createState() =>
      _ReleaseVersionActionButtonState();
}

class _ReleaseVersionActionButtonState
    extends State<ReleaseVersionActionButton> {
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  bool isLatestVersion = true;

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final packageInfo = await ThanPkg.platform.getPackageInfo();
      isLatestVersion = await TReleaseVersionServices.instance
          .isLatestVersion(packageInfo.version);

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
      return SizedBox(
        width: 20,
        height: 20,
        child: TLoader(
          size: 20,
        ),
      );
    }

    return IconButton(
      color: isLatestVersion == false
          ? const Color.fromARGB(255, 230, 208, 17)
          : null,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ReleaseHomeScreen(),
          ),
        );
      },
      icon: Icon(
        isLatestVersion
            ? Icons.notifications
            : Icons.notification_important_rounded,
      ),
    );
  }
}
