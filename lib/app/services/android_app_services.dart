import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
