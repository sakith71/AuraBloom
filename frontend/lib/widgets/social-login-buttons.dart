import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {},
          icon: Image.asset('assets/google.png', height: 40, width: 40),
        ),
        const SizedBox(width: 20),
        IconButton(
          onPressed: () {},
          icon: Image.asset('assets/apple.png', height: 40, width: 40),
        ),
      ],
    );
  }
}
