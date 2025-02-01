import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:novel_v3/app/widgets/t_text_field.dart';

class RenameDialog extends StatefulWidget {
  BuildContext dialogContext;
  String title;
  String renameText;
  String cancelText;
  String submitText;
  void Function() onCancel;
  void Function(String text) onSubmit;
  Widget? renameLabelText;
  String? errorText;
  void Function(String text)? onChanged;
  TextInputType? textInputType;
  List<TextInputFormatter>? inputFormatters;

  RenameDialog({
    super.key,
    required this.dialogContext,
    this.title = 'အတည်ပြုခြင်း',
    this.renameText = '',
    this.cancelText = 'Cancel',
    this.submitText = 'Submit',
    required this.onCancel,
    required this.onSubmit,
    this.renameLabelText,
    this.errorText,
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TTextField(
        controller: controller,
        inputFormatters: widget.inputFormatters,
        textInputType: widget.textInputType,
        label: widget.renameLabelText,
        errorText: widget.errorText,
        onChanged: widget.onChanged,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(widget.dialogContext);
            widget.onCancel();
          },
          child: Text(widget.cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(widget.dialogContext);
            widget.onSubmit(controller.text);
          },
          child: Text(widget.submitText),
        ),
      ],
    );
  }
}
