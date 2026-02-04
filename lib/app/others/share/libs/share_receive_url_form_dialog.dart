import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/others/share/server_services.dart';
import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ShareReceiveUrlFormDialog extends StatefulWidget {
  final String recentUrl;
  final void Function(String url) onSuccess;
  final void Function(String connectedUrl)? onConnectedUrl;
  const ShareReceiveUrlFormDialog({
    super.key,
    required this.onSuccess,
    this.recentUrl = '',
    this.onConnectedUrl,
  });

  @override
  State<ShareReceiveUrlFormDialog> createState() =>
      _ShareReceiveUrlFormDialogState();
}

class _ShareReceiveUrlFormDialogState extends State<ShareReceiveUrlFormDialog> {
  final urlController = TextEditingController();
  @override
  void initState() {
    super.initState();
    init();
  }

  bool isLoading = false;
  List<String> hostAddress = [];
  String? errorText;
  TClient client = TClient(
    options: TClientOptions(
      sendTimeout: Duration(seconds: 3),
      connectTimeout: Duration(seconds: 3),
      receiveTimeout: Duration(seconds: 3),
    ),
  );

  void init() async {
    try {
      hostAddress = await ThanPkg.platform.getWifiAddressList();
      urlController.text = hostAddress.isEmpty ? '' : hostAddress.first;
      if (widget.recentUrl.isNotEmpty) {
        urlController.text = widget.recentUrl;
      }
      // final oldUrl = await RecentServices.get<String>('url', defaultValue: '');
      // urlController.text = oldUrl.isEmpty ? hostAddress.first : oldUrl;
      // _checkHost();
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      showTMessageDialogError(context, e.toString());
    }
  }

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: Column(
        children: [
          TTextField(
            label: Text('Connect Url'),
            controller: urlController,
            errorText: errorText,
            onSubmitted: (value) {
              _checkHost();
            },
          ),
          isLoading ? LinearProgressIndicator() : SizedBox.shrink(),
          _getHostAddressList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Close'),
        ),
        TextButton(onPressed: _checkHost, child: Text('စစ်ဆေးမယ်')),
      ],
    );
  }

  Widget _getHostAddressList() {
    return Column(
      children: List.generate(hostAddress.length, (index) {
        final address = hostAddress[index];
        return Column(
          children: [
            ListTile(
              title: Text(address),
              onTap: () {
                urlController.text = address;
                _checkHost();
              },
            ),
            Divider(),
          ],
        );
      }),
    );
  }

  final http = HttpClient();

  void _checkHost() async {
    try {
      setState(() {
        isLoading = true;
      });
      final url =
          'http://${urlController.text}:${ServerServices.getInstance.server.port}';

      // final res = await client.get(url);
      http.connectionTimeout = Duration(seconds: 8);

      final request = await http.getUrl(Uri.parse(url));
      final res = await request.close();
      await res.drain();

      // print('res.statusCode: ${res.statusCode} - url: $url');
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorText = null;
      });
      widget.onConnectedUrl?.call(urlController.text);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onSuccess(url);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorText = 'ချိတ်ဆက် မရပါ';
      });
    }
  }
}
