import 'package:flutter/material.dart';

class WrapMoreLess extends StatefulWidget {
  final String title;
  final List<String> names;
  final void Function(String name)? onClicked;
  // 2 line ခန့်မှန်း Chip count
  final int maxVisibleCount;
  final Color? moreLessColor;
  const WrapMoreLess({
    super.key,
    required this.title,
    required this.names,
    this.onClicked,
    this.maxVisibleCount = 6,
    this.moreLessColor,
  });

  @override
  State<WrapMoreLess> createState() => _WrapMoreLessState();
}

class _WrapMoreLessState extends State<WrapMoreLess> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final hasMore = widget.names.length > widget.maxVisibleCount;

    final visibleItems = expanded || !hasMore
        ? widget.names
        : widget.names.take(widget.maxVisibleCount).toList();

    final hiddenCount = widget.names.length - widget.maxVisibleCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 5),

            Wrap(
              spacing: 3,
              runSpacing: 3,
              children: [
                ...visibleItems.map(
                  (e) => GestureDetector(
                    onTap: () => widget.onClicked?.call(e),
                    child: Chip(
                      mouseCursor: SystemMouseCursors.click,
                      label: Text(e),
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                    ),
                  ),
                ),

                if (hasMore && !expanded)
                  ActionChip(
                    label: Text(
                      '+$hiddenCount More',
                      style: TextStyle(
                        color: widget.moreLessColor ?? Colors.blue,
                      ),
                    ),
                    onPressed: () {
                      setState(() => expanded = true);
                    },
                  ),

                if (expanded && hasMore)
                  ActionChip(
                    label: Text(
                      'Less',
                      style: TextStyle(
                        color: widget.moreLessColor ?? Colors.blue,
                      ),
                    ),
                    onPressed: () {
                      setState(() => expanded = false);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
