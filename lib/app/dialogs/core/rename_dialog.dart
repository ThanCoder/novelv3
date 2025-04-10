import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/index.dart';

class RenameDialog extends StatefulWidget {
  String title;
  String text;
  String cancelText;
  String submitText;
  void Function() onCancel;
  void Function(String text) onSubmit;
  Widget? renameLabelText;
  void Function(String text)? onChanged;
  TextInputType? textInputType;
  List<TextInputFormatter>? inputFormatters;
  String? Function(String text)? onCheckIsError;

  RenameDialog({
    super.key,
    this.title = 'အတည်ပြုခြင်း',
    this.text = 'Untitled',
    this.cancelText = 'Cancel',
    this.submitText = 'Submit',
    required this.onCancel,
    required this.onSubmit,
    this.renameLabelText,
    this.onChanged,
    this.inputFormatters,
    this.textInputType,
    this.onCheckIsError,
  });

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.text;
    _checkError(controller.text);
    super.initState();
  }

  bool isSelectAll = false;
  String? errorText;

  void _checkError(String value) {
    if (value.isEmpty) {
      setState(() {
        errorText = 'တစ်ခုခုဖြည့်ရပါမယ်';
      });
      return;
    } else {
      if (widget.onCheckIsError != null) {
        final text = widget.onCheckIsError!(value);
        setState(() {
          errorText = text;
        });
        return;
      }
      setState(() {
        errorText = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isSelectAll = false;
      },
      child: AlertDialog(
        title: Text(widget.title),
        content: TTextField(
          controller: controller,
          inputFormatters: widget.inputFormatters,
          textInputType: widget.textInputType,
          label: widget.renameLabelText,
          errorText: errorText,
          onChanged: (value) {
            _checkError(value);
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }
          },
          onTap: () {
            if (!isSelectAll) {
              controller.selection = TextSelection(
                  baseOffset: 0, extentOffset: controller.text.length);
              isSelectAll = true;
            }
          },
          onSubmitted: (value) {
            if (errorText == null) {
              Navigator.pop(context);
              widget.onSubmit(value);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onCancel();
            },
            child: Text(widget.cancelText),
          ),
          TextButton(
            onPressed: errorText != null
                ? null
                : () {
                    Navigator.pop(context);
                    widget.onSubmit(controller.text);
                  },
            child: Text(widget.submitText),
          ),
        ],
      ),
    );
  }
}
