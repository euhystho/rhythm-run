import 'package:flutter/material.dart';

class SizedIconButton extends StatelessWidget {
  final double width;
  final IconData icon;
  final VoidCallback? onPressed;

  const SizedIconButton({
    super.key,
    required this.width,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
      ),
    );
  }
}