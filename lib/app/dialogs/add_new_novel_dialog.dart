import 'dart:io';

import 'package:flutter/material.dart';
import 'package:novel_v3/app/components/app_components.dart';
import 'package:novel_v3/app/models/novel_model.dart';
import 'package:novel_v3/app/notifiers/novel_notifier.dart';
import 'package:novel_v3/app/screens/novel_screens/novel_from_screen.dart';
import 'package:novel_v3/app/utils/path_util.dart';

import '../widgets/index.dart';

class AddNewNovelDialog extends StatefulWidget {
  BuildContext dialogContext;
  AddNewNovelDialog({super.key, required this.dialogContext});

  @override
  State<AddNewNovelDialog> createState() => _AddNewNovelDialogState();
}

class _AddNewNovelDialogState extends State<AddNewNovelDialog> {
  TextEditingController textController = TextEditingController();
  String? errorText;

  @override
  void initState() {
    textController.text = 'Untitled';
    onChanged(textController.text);
    super.initState();
  }

  void onChanged(String text) async {
    try {
      if (text.isEmpty) {
        setState(() {
          errorText = 'Novel title ရှိရပါမယ်!';
        });
        return;
      }

      final res = novelListNotifier.value
          .where((no) => no.title.toLowerCase().startsWith(text.toLowerCase()));
      if (res.isNotEmpty) {
        //novel ရှိနေတယ်
        setState(() {
          errorText = 'Novel ရှိနေပြီးသားပါ!';
        });
      } else {
        //not exists
        setState(() {
          errorText = null;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void addNovel() {
    try {
      final newNovel = NovelModel(
        title: textController.text,
        path: '${getSourcePath()}/${textController.text}',
        isCompleted: false,
        isAdult: false,
        date: DateTime.now().millisecondsSinceEpoch,
      );
      //update ui
      final novelList = novelListNotifier.value;
      novelListNotifier.value = [];
      novelList.insert(0, newNovel);
      novelListNotifier.value = novelList;
      //create data
      final dir = Directory(newNovel.path);
      if (!dir.existsSync()) {
        dir.createSync();
      }
      //show message
      showMessage(context, 'novel -${newNovel.title}- ကိုတည်ဆောက်ပြီးပါပြီ');
      //go edit form
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NovelFromScreen(novel: newNovel),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Novel'),
      content: TTextField(
        isSelectedAll: true,
        controller: textController,
        label: const Text('Novel Title'),
        onChanged: onChanged,
        errorText: errorText,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (errorText == null && textController.text.isNotEmpty) {
              Navigator.pop(context);
              addNovel();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
