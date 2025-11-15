import 'package:flutter/material.dart';

import '../../hospitals_choice/view/hospitals_choice_section.dart';

class RecentHospitalsSection extends StatelessWidget {
  const RecentHospitalsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const HospitalsChoiceSection(
      translationPrefix: 'home.recent_hospitals',
    );
  }
}
