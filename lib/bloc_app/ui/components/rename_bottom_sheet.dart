import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_widgets/t_widgets.dart';

void showRenameBottomSheet(
  BuildContext context, {
  Widget? title,
  required String rename,
  void Function(String text)? onApply,
  void Function(String original, String updated)? onUpdated,
  List<TextInputFormatter>? inputFormatters,
  Widget? labelText,
  bool isDismissible = true,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    builder: (context) => RenameBottomSheet(
      title: title,
      rename: rename,
      onApply: onApply,
      inputFormatters: inputFormatters,
      labelText: labelText,
      onUpdated: onUpdated,
    ),
  );
}

class RenameBottomSheet extends StatefulWidget {
  final Widget? title;
  final String rename;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String text)? onApply;
  final void Function(String original, String updated)? onUpdated;
  final Widget? labelText;
  const RenameBottomSheet({
    super.key,
    this.title,
    required this.rename,
    this.onApply,
    this.inputFormatters,
    this.labelText,
    this.onUpdated,
  });

  @override
  State<RenameBottomSheet> createState() => _RenameBottomSheetState();
}

class _RenameBottomSheetState extends State<RenameBottomSheet> {
  @override
  void initState() {
    renameController.text = widget.rename;
    isUpdate = widget.rename.isNotEmpty;
    super.initState();
  }

  @override
  void dispose() {
    renameController.dispose();
    super.dispose();
  }

  final renameController = TextEditingController();
  bool isUpdate = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 150),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              spacing: 10,
              children: [
                ?widget.title,
                TTextField(
                  label: widget.labelText ?? Text('Rename'),
                  inputFormatters: widget.inputFormatters,
                  maxLines: 1,
                  controller: renameController,
                  autofocus: true,
                  // isSelectedAll: true,
                  onSubmitted: (value) => _onSave(),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Close'),
                    ),
                    TextButton(onPressed: _onSave, child: Text('Save')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSave() {
    Navigator.pop(context);
    if (isUpdate) {
      widget.onUpdated?.call(widget.rename, renameController.text);
      return;
    }
    widget.onApply?.call(renameController.text);
  }
}
