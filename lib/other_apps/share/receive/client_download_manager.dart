// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:t_client/t_client.dart';
import 'package:t_widgets/t_widgets.dart';
import 'package:than_pkg/than_pkg.dart';

class ClientDownloadManager extends TDownloadManager {
  final TClientToken token;
  final Directory saveDir;
  final bool isExistsFileSkip;
  ClientDownloadManager({
    required this.token,
    required this.saveDir,
    this.isExistsFileSkip = true,
  });

  final client = TClient();

  @override
  void cancel() {
    token.cancel();
  }

  @override
  Stream<TProgress> actions(List<String> urls) {
    final controller = StreamController<TProgress>();
    (() async {
      try {
        if (!saveDir.existsSync()) {
          await saveDir.create();
        }
        controller.add(TProgress.preparing(indexLength: urls.length));
        int index = 0;
        for (var url in urls) {
          final name = url.getName();
          final temFile = File(
            '${saveDir.path}/${name.getName(withExt: false)}.tem',
          );
          index++;
          // skip
          if (isExistsFileSkip && File('${saveDir.path}/$name').existsSync()) {
            continue;
          }

          await client.download(
            url,
            token: token,
            savePath: temFile.path,
            onError: controller.addError,
            onCancelCallback: controller.addError,
            onReceiveProgressSpeed: (received, total, speed, eta) {
              controller.add(
                TProgress.progress(
                  index: index,
                  indexLength: urls.length,
                  loaded: received,
                  total: total,
                  message:
                      'Downloading...\n$name\nSpeed: ${speed.getAutoSpeedLabel()} - Left: ${eta?.getAutoTimeLabel()}',
                ),
              );
            },
          );

          // rename
          await temFile.rename('${saveDir.path}/$name');
        }

        controller.add(TProgress.done(message: 'Downloaded'));
      } catch (e) {
        controller.addError(e.toString());
      } finally {
        controller.close();
      }
    })();
    return controller.stream;
  }
}
