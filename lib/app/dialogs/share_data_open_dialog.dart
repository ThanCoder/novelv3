import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:novel_v3/app/constants.dart';
import 'package:novel_v3/app/models/share_data_model.dart';
import 'package:novel_v3/app/services/core/recent_db_services.dart';

import '../widgets/index.dart';

class ShareDataOpenDialog extends StatelessWidget {
  BuildContext context;
  ShareDataModel shareData;
  String cancelText;
  String submitText;
  void Function() onCancel;
  void Function() onSubmit;

  ShareDataOpenDialog({
    super.key,
    required this.context,
    required this.shareData,
    this.cancelText = 'Cancel',
    this.submitText = 'Submit',
    required this.onCancel,
    required this.onSubmit,
  });

  Widget getCurrentWidget(ShareDataModel shareData) {
    final host = getRecentDB<String>('server_address');
    final url = 'http://$host:$serverPort/download?path=${shareData.path}';
    //png
    if (shareData.name.endsWith('.png')) {
      return MyImageUrl(url: url);
    }
    //text
    else if (shareData.name.endsWith('.json') ||
        int.tryParse(shareData.name) != null ||
        !shareData.name.endsWith('.png') ||
        !shareData.name.endsWith('.pdf')) {
      return FutureBuilder(
        future: Dio().get(url),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return TLoader();
          }
          if (snapshot.hasData) {
            return Text(snapshot.data.toString());
          }

          return const Text('data မရှိပါ');
        },
      );
    }

    return const Text(
      'လောလောဆယ် ဖွင့်မရသေးပါ',
      style: TextStyle(
        fontSize: 18,
        color: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(shareData.name),
      content: SingleChildScrollView(
        child: getCurrentWidget(shareData),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel();
          },
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onSubmit();
          },
          child: Text(submitText),
        ),
      ],
    );
  }
}
