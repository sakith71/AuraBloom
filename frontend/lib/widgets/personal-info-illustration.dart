import 'package:flutter/material.dart';

class PersonalInfoIllustration extends StatelessWidget {
  const PersonalInfoIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset('assets/personal_info.png', fit: BoxFit.contain),
      ),
    );
  }
}
