import 'package:flutter/material.dart';

class TagsView extends StatefulWidget {
  final List<String> tags;
  final void Function(String tag)? onClicked;
  final int? showCount;
  final Color? moreLessColor;
  const TagsView({
    super.key,
    required this.tags,
    this.onClicked,
    this.showCount = 8,
    this.moreLessColor,
  });

  @override
  State<TagsView> createState() => _TagsViewState();
}

class _TagsViewState extends State<TagsView> {
  bool isExpanded = false;

  @override
  void didUpdateWidget(covariant TagsView oldWidget) {
    if (oldWidget.tags.length != widget.tags.length) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 2,
      runSpacing: 2,
      children: [
        ..._getList.map((e) => _item(e, onTap: widget.onClicked)),
        _moreAndLessWidget(),
      ],
    );
  }

  List<String> get _getList {
    if (isExpanded) {
      return widget.tags;
    }
    if (widget.showCount != null) {
      return widget.tags.take(widget.showCount!).toList();
    }

    return widget.tags;
  }

  Widget _moreAndLessWidget() {
    if (widget.tags.length > (widget.showCount ?? 0)) {
      return _item(
        isExpanded ? 'Show Less' : 'More...',
        bgColor: widget.moreLessColor ?? const Color.fromARGB(255, 4, 74, 131),
        onTap: (name) {
          setState(() {
            isExpanded = !isExpanded;
          });
        },
      );
    }
    return SizedBox.shrink();
  }

  Widget _item(
    String name, {
    void Function(String name)? onTap,
    Color? textColor,
    Color? bgColor,
  }) {
    // bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onTap?.call(name),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: bgColor ?? const Color.fromARGB(255, 34, 33, 33),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
            child: Text(
              name,
              style: TextStyle(color: textColor ?? Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
