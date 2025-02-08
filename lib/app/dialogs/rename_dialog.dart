import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/widgets/t_text_field.dart';

class RenameDialog extends StatefulWidget {
  String title;
  String renameText;
  List<String>? renameExistsTextList;
  String cancelText;
  String submitText;
  void Function() onCancel;
  void Function(String text) onSubmit;
  Widget? renameLabelText;
  void Function(String text)? onChanged;
  TextInputType? textInputType;
  List<TextInputFormatter>? inputFormatters;

  RenameDialog({
    super.key,
    this.title = 'အတည်ပြုခြင်း',
    this.renameText = 'Untitled',
    this.renameExistsTextList,
    this.cancelText = 'Cancel',
    this.submitText = 'Submit',
    required this.onCancel,
    required this.onSubmit,
    this.renameLabelText,
    this.onChanged,
    this.inputFormatters,
    this.textInputType,
  });

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    controller.text = widget.renameText;
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
      setState(() {
        errorText = null;
      });
    }
    if (widget.renameExistsTextList != null) {
      final res = widget.renameExistsTextList!.where((name) => name == value);
      setState(() {
        errorText = res.isNotEmpty ? 'title က ရှိနေပြီးသား ဖြစ်နေပါတယ်' : null;
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
