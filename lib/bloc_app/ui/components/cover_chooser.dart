import 'dart:io';

import 'package:flutter/material.dart';
import 'package:t_widgets/t_widgets.dart';

String? initialDirectory;

class CoverChooser extends StatefulWidget {
  String coverPath;
  VoidCallback? onChanged;
  CoverChooser({super.key, required this.coverPath, this.onChanged});

  @override
  State<CoverChooser> createState() => _CoverChooserState();
}

class _CoverChooserState extends State<CoverChooser> {
  bool isLoading = false;
  late String imagePath;
  final client = HttpClient();

  @override
  void initState() {
    imagePath = widget.coverPath;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _showMenu,
        child: SizedBox(
          width: 150,
          height: 150,
          child: isLoading
              ? Center(child: TLoader.random())
              : TImageFile(path: imagePath, borderRadius: 5),
        ),
      ),
    );
  }

  void _showMenu() {
    showTMenuBottomSheet(
      context,
      children: [
        ListTile(
          onTap: () {
            Navigator.pop(context);
            _addFromPath();
          },
          leading: const Icon(Icons.add),
          title: const Text('Add From Path'),
        ),
        ListTile(
          onTap: () {
            Navigator.pop(context);
            _downloadUrl();
          },
          leading: const Icon(Icons.add),
          title: const Text('Add From Url'),
        ),
        File(widget.coverPath).existsSync()
            ? ListTile(
                onTap: () {
                  Navigator.pop(context);
                  _delete();
                },
                iconColor: Colors.red,
                leading: const Icon(Icons.delete_forever_rounded),
                title: const Text('Delete'),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  void _downloadUrl() {
    showDialog(
      context: context,
      builder: (context) => TRenameDialog(
        autofocus: true,
        renameLabelText: const Text('Image Direct Url'),
        submitText: 'Download',
        cancelText: 'Close',
        text: '',
        hintText: 'http***....',
        onCheckIsError: (text) {
          if (!text.startsWith('http')) {
            return 'url required!';
          }
          return null;
        },
        onSubmit: (url) async {
          try {
            setState(() {
              isLoading = true;
            });

            // default
            await downloadImageDefaultFun(
              url,
              widget.coverPath,
              client: client,
              onProgress: (double progress) {},
              onDownloadStart: (subscription, request) {},
            );

            if (!mounted) return;

            setState(() {
              isLoading = false;
            });
            if (widget.onChanged != null) {
              widget.onChanged!();
            }
          } catch (e) {
            TWidgets.showDebugLog(e.toString());
            if (!mounted) return;
            setState(() {
              isLoading = false;
            });
          }
        },
      ),
    );
  }

  void _addFromPath() async {
    try {
      setState(() {
        isLoading = true;
      });
      // default chooser
      String? path;
      // check custom image chooser
      if (TWidgets.instance.onOpenImageFileChooser != null) {
        // custom
        path = await TWidgets.instance.onOpenImageFileChooser!(
          initialDirectory: initialDirectory,
        );
      } else {
        // default
        path = await getDefaultImageChooser(initialDirectory: initialDirectory);
      }

      if (path != null) {
        final file = File(path);
        initialDirectory = file.parent.path;

        if (widget.coverPath.isNotEmpty) {
          await file.copy(widget.coverPath);
          // clear image cache
          await TAppServices.clearAndRefreshImage();
        }
        imagePath = path;
      }
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (widget.onChanged != null) {
        widget.onChanged!();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      TWidgets.showDebugLog(e.toString());
    }
  }

  void _delete() async {
    try {
      setState(() {
        isLoading = true;
      });
      final file = File(widget.coverPath);
      if (await file.exists()) {
        await file.delete();
        await TAppServices.clearAndRefreshImage();

        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
        if (widget.onChanged != null) {
          widget.onChanged!();
        }
      }
    } catch (e) {
      TWidgets.showDebugLog(e.toString());
    }
  }
}
