import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:t_widgets/extensions/t_widgets_extensions.dart';
import 'package:t_widgets/t_widgets.dart';

void showAppRenameDialog(BuildContext context, {required String value}) {
  showDialog(
    context: context,
    builder: (context) => AppRenameDialog(value: value),
  );
}

class AppRenameDialog extends StatefulWidget {
  final String value;
  final Widget? title;
  final FocusNode? focusNode;
  final Widget? label;
  final String? hintText;
  final int? maxLines;
  final bool isSelectedAll;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String text)? onChanged;
  final void Function()? onTap;
  final void Function(String text)? onSubmitted;
  final TextStyle? inputStyle;
  final bool autofocus;
  final bool? enabled;
  final Widget Function(BuildContext context, void Function() callback)?
  cancelButton;
  final Widget Function(BuildContext context)? middleButton;
  final Widget Function(BuildContext context, void Function() callback)?
  submitButton;
  final String? Function(String text)? onTestError;

  const AppRenameDialog({
    super.key,
    required this.value,
    this.title,
    this.submitButton,
    this.cancelButton,
    this.middleButton,
    this.focusNode,
    this.label,
    this.hintText,
    this.maxLines = 1,
    this.isSelectedAll = false,
    this.textInputType,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.inputStyle,
    this.autofocus = false,
    this.enabled,
    this.onTestError,
  });

  @override
  State<AppRenameDialog> createState() => _AppRenameDialogState();
}

class _AppRenameDialogState extends State<AppRenameDialog> {
  String? errorText;
  final controller = TextEditingController();
  @override
  initState() {
    super.initState();
    controller.text = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: widget.title,
      scrollable: true,
      content: Column(
        children: [
          TTextField(
            controller: controller,
            label: widget.label,
            maxLines: widget.maxLines,
            autofocus: widget.autofocus,
            hintText: widget.hintText,
            isSelectedAll: widget.isSelectedAll,
            enabled: widget.enabled,
            errorText: errorText,
            focusNode: widget.focusNode,
            inputFormatters: widget.inputFormatters,
            onSubmitted: widget.onSubmitted,
            onTap: widget.onTap,
            style: widget.inputStyle,
            textInputType: widget.textInputType,
            onChanged: (value) {
              errorText = widget.onTestError?.call(value);
              setState(() {});
            },
          ),
        ],
      ),
      actions: _actions(),
    );
  }

  List<Widget> _actions() {
    return [
      if (widget.cancelButton != null)
        widget.cancelButton!(context, _onCancel)
      else
        TextButton(onPressed: _onCancel, child: Text('Close')),
      if (widget.middleButton != null) widget.middleButton!(context),

      if (errorText == null)
        if (widget.submitButton != null)
          widget.submitButton!(context, _onSubmit)
        else
          TextButton(onPressed: _onSubmit, child: Text('Rename')),
    ];
  }

  void _onCancel() {
    context.close();
  }

  void _onSubmit() {
    context.close();
  }
}

// bottom sheet
class RenameBottomSheet extends StatefulWidget {
  final Widget? title;
  final FocusNode? focusNode;
  final Widget? label;
  final String? hintText;
  final int? maxLines;
  final bool isSelectedAll;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final void Function(String text)? onChanged;
  final void Function()? onTap;
  final void Function(String text)? onSubmitted;
  final TextStyle? inputStyle;
  final bool autofocus;
  final bool? enabled;
  final Widget Function(BuildContext context, void Function() callback)?
  cancelButton;
  final Widget Function(BuildContext context)? middleButton;
  final Widget Function(BuildContext context, void Function() callback)?
  submitButton;
  final String? Function(String text)? onTestError;

  const RenameBottomSheet({
    super.key,
    this.title,
    this.submitButton,
    this.cancelButton,
    this.middleButton,
    this.focusNode,
    this.label,
    this.hintText,
    this.maxLines = 1,
    this.isSelectedAll = false,
    this.textInputType,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.inputStyle,
    this.autofocus = false,
    this.enabled,
    this.onTestError,
  });

  @override
  State<RenameBottomSheet> createState() => _RenameBottomSheetState();
}

class _RenameBottomSheetState extends State<RenameBottomSheet> {
  String? errorText;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            spacing: 4,
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.title ??
                  Text(
                    'Rename',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
              TTextField(
                label: widget.label ?? Text('Rename'),
                maxLines: widget.maxLines,
                autofocus: widget.autofocus,
                hintText: widget.hintText,
                isSelectedAll: widget.isSelectedAll,
                enabled: widget.enabled,
                errorText: errorText,
                focusNode: widget.focusNode,
                inputFormatters: widget.inputFormatters,
                onSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                style: widget.inputStyle,
                textInputType: widget.textInputType,
                onChanged: (value) {
                  errorText = widget.onTestError?.call(value);
                  setState(() {});
                },
              ),
              SizedBox(height: 20),
              _actions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 5,
        children: [
          if (widget.cancelButton != null)
            widget.cancelButton!(context, _onCancel)
          else
            TextButton(onPressed: _onCancel, child: Text('Close')),
          if (widget.middleButton != null) widget.middleButton!(context),
          if (widget.submitButton != null)
            widget.submitButton!(context, _onSubmit)
          else
            TextButton(onPressed: _onSubmit, child: Text('Rename')),
        ],
      ),
    );
  }

  void _onCancel() {
    context.close();
  }

  void _onSubmit() {
    context.close();
  }
}
