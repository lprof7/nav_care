import 'package:flutter/material.dart';

import '../../doctors_choice/view/doctors_choice_section.dart';

class RecentDoctorsSection extends StatelessWidget {
  const RecentDoctorsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoctorsChoiceSection(
      translationPrefix: 'home.recent_doctors',
    );
  }
}
