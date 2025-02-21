import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final String text;

  const CustomDivider({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Divider(color: Colors.grey.shade500, thickness: 1, endIndent: 10)),
        Text(text, style: const TextStyle(color: Colors.black45)),
        Expanded(child: Divider(color: Colors.grey.shade500, thickness: 1, indent: 10)),
      ],
    );
  }
}

