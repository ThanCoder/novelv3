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
        suffixIcon: IconButton(
            onPressed: () {
              controller.text = '';
              if (widget.onCleared != null) {
                widget.onCleared!();
              }
            },
            icon: const Icon(Icons.clear_all_rounded)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        filled: true,
        // fillColor: Colors.grey[200],
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
      ),
      autofocus: true,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      maxLines: 1,
    );
  }
}
