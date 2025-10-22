import '../models/hospital_model.dart';

class FakeHospitalsChoiceResponse {
  static List<HospitalModel> getFakeHospitalsChoice() {
    return _data
        .map((entry) => HospitalModel.fromJson(entry))
        .toList(growable: false);
  }

  static const List<Map<String, dynamic>> _data = [
    {
      '_id': 'hosp_1',
      'name': 'NavCare Heart Center',
      'field': 'Cardiology',
      'images': [
        'assets/images/fake/hospitals/1.jpg',
        'assets/images/fake/hospitals/2.jpg',
      ],
      'description_en':
          'World-class cardiac care with advanced diagnostics and recovery suites.',
      'description_fr':
          'Soins cardiaques de classe mondiale avec diagnostics avancés et suites de récupération.',
      'description_ar': 'رعاية قلبية عالمية مع تشخيص متقدم وأجنحة تعافي مريحة.',
      'description_sp':
          'Atención cardíaca de primer nivel con diagnósticos avanzados y suites de recuperación.',
      'facility_type': 'Hospital',
      'rating': 4.9,
    },
    {
      '_id': 'hosp_2',
      'name': 'NavCare Children Clinic',
      'field': 'Pediatrics',
      'images': [
        'assets/images/fake/hospitals/3.jpg',
        'assets/images/fake/hospitals/4.jpg',
      ],
      'description_en':
          'A colorful, family-friendly clinic designed to keep little ones comfortable.',
      'description_fr':
          'Une clinique familiale et colorée conçue pour rassurer les enfants.',
      'description_ar': 'عيادة عائلية ملونة مصممة لراحة الأطفال وطمأنتهم.',
      'description_sp':
          'Una clínica acogedora pensada para mantener cómodos a los niños.',
      'facility_type': 'Clinic',
      'rating': 4.7,
    },
    {
      '_id': 'hosp_3',
      'name': 'NavCare Wellness Spa',
      'field': 'Rehabilitation',
      'images': [
        'assets/images/fake/hospitals/5.jpg',
        'assets/images/fake/hospitals/6.jpg',
      ],
      'description_en':
          'Holistic rehabilitation with spa-inspired therapies and private suites.',
      'description_fr':
          'Rééducation holistique avec des thérapies inspirées du spa et suites privées.',
      'description_ar': 'تأهيل شامل مع علاجات مستوحاة من السبا وأجنحة خاصة.',
      'description_sp':
          'Rehabilitación holística con terapias tipo spa y suites privadas.',
      'facility_type': 'Hospital',
      'rating': 4.8,
    },
  ];
}
