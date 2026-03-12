import 'package:flutter/material.dart';

class CircleButton extends StatefulWidget {
  final Icon icon;
  final Color defaultBgColor;
  final Color activeBgColor;
  final Function()? onTap;
  const CircleButton({
    super.key,
    required this.icon,
    this.defaultBgColor = Colors.black,
    this.activeBgColor = Colors.blue,
    this.onTap,
  });

  @override
  State<CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<CircleButton> {
  bool isHovered = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (value) {
        setState(() {
          isHovered = value;
        });
      },
      hoverColor: Colors.blue,
      customBorder: CircleBorder(),
      mouseCursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isHovered ? widget.activeBgColor : widget.defaultBgColor,
          shape: BoxShape.circle,
        ),
        child: FittedBox(child: widget.icon),
      ),
    );
  }
}
