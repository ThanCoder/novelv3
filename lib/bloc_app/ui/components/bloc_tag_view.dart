import 'package:flutter/material.dart';

class BlocTagView extends StatefulWidget {
  final List<String> values;
  final Text? title;
  final void Function()? onAdd;
  final void Function(String value)? onDelete;
  final void Function(String value)? onClick;
  const BlocTagView({
    super.key,
    required this.values,
    this.title,
    this.onAdd,
    this.onDelete,
    this.onClick,
  });

  @override
  State<BlocTagView> createState() => _BlocTagViewState();
}

class _BlocTagViewState extends State<BlocTagView> {
  @override
  void didUpdateWidget(covariant BlocTagView oldWidget) {
    if (oldWidget.values.length != widget.values.length) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // if (widget.values.isEmpty) {
    //   return SizedBox.shrink();
    // }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        _header(),
        Wrap(
          spacing: 3,
          runSpacing: 3,
          children: [...widget.values.map((e) => _item(e)), _addBtn()],
        ),
      ],
    );
  }

  Widget _header() {
    if (widget.title == null) return SizedBox.shrink();
    return Text(
      widget.title!.data!,
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _addBtn() {
    if (widget.onAdd == null) {
      return SizedBox.shrink();
    }
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () => widget.onAdd?.call(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(Icons.add, color: Colors.green),
      ),
    );
  }

  Widget _item(String value) {
    final dynWidth = MediaQuery.of(context).size.width * 0.5;
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: dynWidth),
            child: GestureDetector(
              onTap: () => widget.onClick?.call(value),
              child: Text(
                value,
                style: TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (widget.onDelete != null)
            InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () => widget.onDelete?.call(value),
              child: Icon(Icons.remove_circle_outline, color: Colors.red),
            ),
        ],
      ),
    );
  }
}
