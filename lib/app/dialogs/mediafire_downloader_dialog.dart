import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/core/app_components.dart';
import 'package:novel_v3/app/widgets/index.dart';

class MediafireDownloaderDialog extends StatefulWidget {
  String saveDirPath;
  void Function(String filePath) onSuccess;
  void Function(String msg) onError;
  MediafireDownloaderDialog({
    super.key,
    required this.saveDirPath,
    required this.onError,
    required this.onSuccess,
  });

  @override
  State<MediafireDownloaderDialog> createState() =>
      _MediafireDownloaderDialogState();
}

class _MediafireDownloaderDialogState extends State<MediafireDownloaderDialog> {
  final TextEditingController urlController = TextEditingController();

  String? errorText;
  bool isLoading = false;
  bool isUsedProxyServer = true;

  @override
  void initState() {
    super.initState();
    _checkError();
  }

  void _checkError() {
    if (urlController.text.isEmpty) {
      setState(() {
        errorText = 'တစ်ခုခု ထည့်ပေးပါ';
      });
    }
  }

  void _download() async {
    try {
      setState(() {
        isLoading = true;
      });
      // final res = await MediafireServices.fetchDirectDownloadLink(
      //   urlController.text,
      //   isUsedProxy: isUsedProxyServer,
      // );
      // final html = await DioServices.instance
      //     .getBrowsesrProxyHtml(urlController.text, delaySec: 3);
      // File('res.html').writeAsStringSync(html);
      // print('pass');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      showDialogMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: const Text('Mediafire Downloader'),
      content: Column(
        spacing: 5,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //url
          TTextField(
            label: const Text('Url'),
            controller: urlController,
            errorText: errorText,
            onChanged: (value) {
              if (value.isEmpty) {
                setState(() {
                  errorText = 'တစ်ခုခု ထည့်ပေးပါ';
                });
                return;
              }
              if (!value.startsWith('https://www.mediafire.com')) {
                setState(() {
                  errorText = 'mediafire url ပဲလက်ခံပါတယ်';
                });
                return;
              }
              //pass
              setState(() {
                errorText = null;
              });
            },
          ),
          //progress
          isLoading ? const LinearProgressIndicator() : const SizedBox.shrink(),
          // proxy status
          Row(
            spacing: 5,
            children: [
              const Text('Use Forward Proxy'),
              Checkbox(
                value: isUsedProxyServer,
                onChanged: (value) {
                  setState(() {
                    isUsedProxyServer = value!;
                  });
                },
              ),
            ],
          ),
          //download
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Download'),
            onTap: errorText != null ? null : _download,
          ),
        ],
      ),
    );
  }
}
