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
      'facility_type': 'Specialty Hospital',
      'address': '12 Boulevard des Jasmins, Algiers',
      'images': [
        'assets/images/fake/hospitals/1.jpg',
        'assets/images/fake/hospitals/2.jpg',
      ],
      'videos': [],
      'description_en':
          'Cardiology flagship with a 24 hour catheterization lab and rapid recovery suites.',
      'description_fr':
          'Centre de cardiologie avec plateau technique ouvert 24h et suites de convalescence.',
      'description_ar':
          'Cardiology hub offering fast diagnostics and guided recovery plans.',
      'description_sp':
          'Centro cardiologico con laboratorio 24h y suites de recuperacion rapida.',
      'rating': 4.9,
    },
    {
      '_id': 'hosp_2',
      'name': 'NavCare Children Clinic',
      'field': 'Pediatrics',
      'facility_type': 'Clinic',
      'address': '3 Rue Emir Abdelkader, Oran',
      'images': [
        'assets/images/fake/hospitals/3.jpg',
        'assets/images/fake/hospitals/4.jpg',
      ],
      'videos': [],
      'description_en':
          'Colorful pediatric spaces with weekend checkup programs for families.',
      'description_fr':
          'Clinique pediatrique conviviale avec programmes de controle le week end.',
      'description_ar':
          'Family focused pediatric clinic with flexible appointment blocks.',
      'description_sp':
          'Clinica pediatrica con espacios de juego y consultas de fin de semana.',
      'rating': 4.7,
    },
    {
      '_id': 'hosp_3',
      'name': 'NavCare Wellness Pavilion',
      'field': 'Rehabilitation',
      'facility_type': 'Rehab Center',
      'address': '45 Route de Chrea, Blida',
      'images': [
        'assets/images/fake/hospitals/5.jpg',
        'assets/images/fake/hospitals/6.jpg',
      ],
      'videos': [],
      'description_en':
          'Rehabilitation suites blending hydrotherapy pools and strength studios.',
      'description_fr':
          'Plateau de reeducation avec balneotherapie et salles de renforcement.',
      'description_ar':
          'Rehab plans combining water therapy sessions and mobility coaching.',
      'description_sp':
          'Centro de rehabilitacion con piscinas terapeuticas y estudios de fuerza.',
      'rating': 4.8,
    },
    {
      '_id': 'hosp_4',
      'name': 'NavCare Maternity House',
      'field': 'Obstetrics',
      'facility_type': 'Maternity Center',
      'address': '8 Avenue de la Republique, Constantine',
      'images': [
        'assets/images/fake/hospitals/2.jpg',
        'assets/images/fake/hospitals/1.jpg',
      ],
      'videos': [],
      'description_en':
          'Personalized birth plans with on site lactation and neonatal support.',
      'description_fr':
          'Maison de maternite avec accompagnement personnalise et unite neonatale.',
      'description_ar':
          'Maternity center offering tailored birth journeys and family coaching.',
      'description_sp':
          'Centro de maternidad con planes de parto personalizados y apoyo neonatal.',
      'rating': 4.9,
    },
    {
      '_id': 'hosp_5',
      'name': 'NavCare Orthopedic Institute',
      'field': 'Orthopedics',
      'facility_type': 'Specialty Hospital',
      'address': '22 Boulevard Belouizdad, Algiers',
      'images': [
        'assets/images/fake/hospitals/4.jpg',
        'assets/images/fake/hospitals/3.jpg',
      ],
      'videos': [],
      'description_en':
          'Sports medicine facility with motion labs and same day surgery suites.',
      'description_fr':
          'Institut d orthopedie avec laboratoires de mouvement et blocs en ambulatoire.',
      'description_ar':
          'Orthopedic specialists delivering sports rehab and day surgery care.',
      'description_sp':
          'Instituto ortopedico con laboratorios de movimiento y cirugia ambulatoria.',
      'rating': 4.8,
    },
    {
      '_id': 'hosp_6',
      'name': 'NavCare Community Health Hub',
      'field': 'Primary Care',
      'facility_type': 'Outpatient Center',
      'address': '5 Rue Mohammed V, Setif',
      'images': [
        'assets/images/fake/hospitals/6.jpg',
        'assets/images/fake/hospitals/5.jpg',
      ],
      'videos': [],
      'description_en':
          'Neighborhood hub for preventive screenings and chronic care coaching.',
      'description_fr':
          'Centre de proximite pour depistages preventifs et suivi des maladies chroniques.',
      'description_ar':
          'Primary care team supporting prevention plans and long term monitoring.',
      'description_sp':
          'Centro comunitario dedicado a chequeos preventivos y gestion cronica.',
      'rating': 4.6,
    },
  ];
}
