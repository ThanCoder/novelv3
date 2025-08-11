import 'dart:io';

import 'package:flutter/material.dart';
import 'package:than_pkg/than_pkg.dart';

void showConfirmStoragePermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Storage Permisson'),
      content: const Text('Storage Permisson လိုအပ်နေပါတယ်။ပေးချင်ပါသလား?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('No'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              await requestStoragePermission();
            } catch (e) {
              debugPrint(e.toString());
            }
          },
          child: const Text('Yes'),
        ),
      ],
    ),
  );
}

//permission
Future<bool> checkStoragePermission() async {
  if (Platform.isLinux) return true;
  return await ThanPkg.platform.isStoragePermissionGranted();
}

Future<void> requestStoragePermission() async {
  if (Platform.isLinux) return;
  await ThanPkg.platform.requestStoragePermission();
}

