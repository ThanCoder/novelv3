import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  void Function(String text)? onChanged;
  void Function(String text)? onSubmitted;
  void Function()? onCleared;
  SearchField({
    super.key,
    this.onChanged,
    this.onSubmitted,
    this.onCleared,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final controller = TextEditingController();
  final focus = FocusNode();
  bool showClearBtn = false;

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focus,
      decoration: InputDecoration(
        hintText: 'Search...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: showClearBtn
            ? IconButton(
                onPressed: () {
                  controller.text = '';
                  showClearBtn = false;
                  setState(() {});
                  if (widget.onCleared != null) {
                    widget.onCleared!();
                  }
                },
                icon: const Icon(Icons.clear_all_rounded),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        // fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      ),
      autofocus: true,
      onChanged: (text) {
        if (widget.onChanged != null) {
          widget.onChanged!(text);
        }
        //text ရှိိနေရင်
        if (text.isNotEmpty && !showClearBtn) {
          setState(() {
            showClearBtn = true;
          });
          return;
        }
        //text ရှိိနေရင်
        if (text.isEmpty && showClearBtn) {
          setState(() {
            showClearBtn = false;
          });
        }
      },
      onSubmitted: widget.onSubmitted,
      maxLines: 1,
    );
  }
}
