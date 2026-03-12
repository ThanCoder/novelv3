import 'package:flutter/material.dart';

typedef ExpandableTagsTagCallback = void Function(String name);

class ExpandableTags extends StatefulWidget {
  final List<String> list;
  final int showCount;
  final Widget? expandedText;
  final Widget? collapsedText;
  final Color? expandedTextBgColor;
  final Color? collapsedTextBgColor;
  const ExpandableTags({
    super.key,
    required this.list,
    this.showCount = 8,
    this.expandedText,
    this.collapsedText,
    this.collapsedTextBgColor,
    this.expandedTextBgColor,
  });

  @override
  State<ExpandableTags> createState() => _ExpandableTagsState();
}

class _ExpandableTagsState extends State<ExpandableTags> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final showList = widget.showCount < widget.list.length && !isExpanded
        ? widget.list.take(widget.showCount)
        : widget.list;
    final widgetList = [...showList.map((e) => _item(e))];
    if (widget.showCount < widget.list.length && !isExpanded) {
      // show expanded text
      widgetList.add(
        _item(
          'Expanded',
          text: widget.expandedText,
          bgColor:
              widget.expandedTextBgColor ??
              const Color.fromARGB(255, 12, 55, 90),
          onTap: (name) => setState(() {
            isExpanded = true;
          }),
        ),
      );
    }
    if (isExpanded) {
      widgetList.add(
        _item(
          'Collapsed',
          text: widget.collapsedText,
          bgColor:
              widget.collapsedTextBgColor ??
              const Color.fromARGB(255, 12, 55, 90),
          onTap: (name) => setState(() {
            isExpanded = false;
          }),
        ),
      );
    }
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: Wrap(
        key: ValueKey(isExpanded),
        runSpacing: 4,
        spacing: 4,
        children: widgetList,
      ),
    );
    // return AnimatedSize(
    //   duration: Duration(milliseconds: 300),
    //   curve: Curves.easeInOut,
    //   child: Wrap(runSpacing: 4, spacing: 4, children: widgetList),
    // );
  }

  Widget _item(
    String name, {
    Widget? text,
    Color? bgColor,
    Color? textColor,
    ExpandableTagsTagCallback? onTap,
  }) {
    return InkWell(
      onTap: () => onTap?.call(name),
      mouseCursor: SystemMouseCursors.click,
      child: Container(
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.black,
          borderRadius: BorderRadius.circular(5),
        ),
        child:
            text ??
            Text(
              name,
              style: TextStyle(fontSize: 13, color: textColor ?? Colors.white),
            ),
      ),
    );
  }
}
