import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../dialogs/core/index.dart';
import '../../services/core/app_services.dart';
import '../../widgets/index.dart';
import '../index.dart';

class CoverComponents extends StatefulWidget {
  String coverPath;
  VoidCallback? onChanged;
  CoverComponents({super.key, required this.coverPath, this.onChanged});

  @override
  State<CoverComponents> createState() => _CoverComponentsState();
}

class _CoverComponentsState extends State<CoverComponents> {
  bool isLoading = false;
  late String imagePath;

  @override
  void initState() {
    imagePath = widget.coverPath;
    super.initState();
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 150),
          child: Column(
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
          ),
        ),
      ),
    );
  }

  void _downloadUrl() {
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        renameLabelText: const Text('Download From Url'),
        submitText: 'Download',
        text: '',
        onCancel: () {},
        onSubmit: (url) async {
          try {
            setState(() {
              isLoading = true;
            });
            await Dio().download(url, widget.coverPath);

            setState(() {
              isLoading = false;
            });
            if (widget.onChanged != null) {
              widget.onChanged!();
            }
          } catch (e) {
            setState(() {
              isLoading = false;
            });
            _showMsg(e.toString());
          }
        },
      ),
    );
  }

  void _showMsg(String msg) {
    showDialogMessage(context, msg);
  }

  void _addFromPath() async {
    try {
      setState(() {
        isLoading = true;
      });
      final files = await openFiles(
        acceptedTypeGroups: [
          const XTypeGroup(mimeTypes: [
            'image/png',
            'image/jpg',
            'image/webp',
            'image/jpeg'
          ]),
        ],
      );
      if (files.isNotEmpty) {
        final path = files.first.path;
        final file = File(path);
        if (widget.coverPath.isNotEmpty) {
          await file.copy(widget.coverPath);
          // clear image cache
          await clearAndRefreshImage();
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
      debugPrint(e.toString());
      setState(() {
        isLoading = false;
      });
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
        await clearAndRefreshImage();

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
      debugPrint(e.toString());
    }
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
              ? TLoader()
              : MyImageFile(
                  path: imagePath,
                  borderRadius: 5,
                ),
        ),
      ),
    );
  }
}
