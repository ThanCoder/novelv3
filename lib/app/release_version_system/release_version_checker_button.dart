import 'package:flutter/material.dart';
import 'package:novel_v3/app/extensions/index.dart';
import 'package:novel_v3/app/widgets/core/index.dart';
import 'package:t_release/models/t_release_version_model.dart';
import 'package:t_release/services/t_release_version_services.dart';
import 'package:than_pkg/than_pkg.dart';

import '../components/index.dart';
import '../dialogs/confirm_dialog.dart';
import '../dialogs/download_dialog.dart';
import '../services/dio_services.dart';
import '../utils/path_util.dart';

class ReleaseVersionCheckerButton extends StatefulWidget {
  const ReleaseVersionCheckerButton({super.key});

  @override
  State<ReleaseVersionCheckerButton> createState() =>
      _ReleaseVersionCheckerButtonState();
}

class _ReleaseVersionCheckerButtonState
    extends State<ReleaseVersionCheckerButton> {
  bool isLoading = false;
  String currentVersion = '';

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    try {
      setState(() {
        isLoading = true;
      });
      final info = await ThanPkg.platform.getPackageInfo();
      currentVersion = info.version;
      // currentVersion = '1.0.1';

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void _downloadConfirm(TReleaseVersionModel release) {
    if (release.url.isEmpty) {
      showDialogMessage(
          context, 'download url မထည့်ရသေးပါ!။\nခဏစောင့်ဆိုင်းပေးပါ။');
      return;
    }
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => ConfirmDialog(
        contentText: '''update version `${release.version}`
${release.description}
${DateTime.fromMillisecondsSinceEpoch(release.date).toTimeAgo()}
${release.url}''',
        submitText: 'Update',
        onCancel: () {},
        onSubmit: () => _download(release),
      ),
    );
  }

  void _download(TReleaseVersionModel release) {
    final title = release.url.getName();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => DownloadDialog(
        title: 'Download App',
        url: DioServices.instance.getForwardProxyUrl(release.url),
        saveFullPath: '${PathUtil.instance.getOutPath()}/$title',
        message: '$title downloading...',
        onError: (msg) {
          showDialogMessage(context, msg);
        },
        onSuccess: () {
          showDialogMessage(context,
              'download လုပ်ပြီးပါပြီ။\npath: ${PathUtil.instance.getOutPath()}/${release.url.getName()}');
        },
      ),
    );
  }

  void _checkVersion() async {
    try {
      setState(() {
        isLoading = true;
      });
      final release = await TReleaseVersionServices.instance
          .getLatestVersion(currentVersion);
      if (release == null) {
        if (!mounted) return;
        showMessage(context, 'နောက်ဆုံး version');
      } else {
        //is new version
        _downloadConfirm(release);
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTileWithDesc(
      leading: isLoading
          ? SizedBox(
              width: 30,
              height: 30,
              child: TLoader(size: 30),
            )
          : const Icon(Icons.cloud_upload_rounded),
      title: 'Check Version',
      desc: 'Current Version - $currentVersion',
      onClick: _checkVersion,
    );
  }
}
