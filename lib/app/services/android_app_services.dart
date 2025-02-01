import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

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
  bool isGranted = false;
  if (await getAndroidVersion() >= 11) {
    //andrid 11 အထက်
    isGranted = await Permission.manageExternalStorage.isGranted;
  } else {
    //andrid 11 အောက်
    isGranted = await Permission.storage.isGranted;
  }
  return isGranted;
}

Future<void> requestStoragePermission() async {
  if (Platform.isLinux) return;
  if (await getAndroidVersion() >= 11) {
    //andrid 11 အထက်
    await Permission.manageExternalStorage.request();
  } else {
    //andrid 11 အောက်
    await Permission.storage.request();
  }
}

//full screen
void toggleAndroidFullScreen(bool isFullScreen) async {
  try {
    if (isFullScreen) {
      // SystemChrome.setSystemUIOverlayStyle(
      //   const SystemUiOverlayStyle(
      //     statusBarColor: Colors.transparent, // Transparent status bar
      //     systemNavigationBarColor:
      //         Colors.transparent, // Transparent navigation bar
      //   ),
      // );
      // Transparent status bar and navigation bar
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, // Transparent status bar
          systemNavigationBarColor:
              Colors.transparent, // Transparent navigation bar
          systemNavigationBarIconBrightness:
              Brightness.light, // For icon color on nav bar
          statusBarIconBrightness:
              Brightness.light, // For status bar icons color
        ),
      );

      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      // Exit Full-Screen Mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: SystemUiOverlay.values);
    }
  } catch (e) {
    debugPrint('toggleAndroidFullScreen: ${e.toString()}');
  }
}

Future<int> getAndroidVersion() async {
  int verInt = -1;
  if (Platform.isAndroid) {
    final process = await Process.run('getprop', ['ro.build.version.release']);
    final ver = int.tryParse(process.stdout.toString().trim());
    if (ver != null) {
      verInt = ver;
    }
  }
  return verInt;
}
