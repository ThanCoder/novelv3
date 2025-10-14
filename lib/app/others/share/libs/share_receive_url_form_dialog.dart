import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:t_server/t_server.dart';
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
  Dio dio = Dio(
    BaseOptions(
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

  void _checkHost() async {
    try {
      setState(() {
        isLoading = true;
      });
      final url = 'http://${urlController.text}:${TServer.instance.getPort}';

      await dio.get(url);

      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorText = null;
      });
      widget.onConnectedUrl?.call(urlController.text);
      // await RecentServices.instance
      //     .setValue<String>('share-host-address', urlController.text);
      // await RecentServices.set('url', urlController.text);

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
