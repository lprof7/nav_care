import '../models/hospital_model.dart';

class FakeFeaturedHospitalsResponse {
  static List<HospitalModel> getFakeFeaturedHospitals() {
    return _data
        .map((entry) => HospitalModel.fromJson(entry))
        .toList(growable: false);
  }

  static const List<Map<String, dynamic>> _data = [
    {
      '_id': 'fh_1',
      'name': 'NavCare Heart Center',
      'field': 'Cardiology',
      'facility_type': 'Specialty Hospital',
      'address': 'Algiers, Algeria',
      'images': ['assets/images/fake/hospitals/1.jpg'],
      'videos': <String>[],
      'description_en':
          'A boutique cardiac hospital pairing preventive care with minimally invasive procedures.',
      'description_fr':
          'Un centre cardiaque spécialisé qui associe prévention et procédures mini-invasives.',
      'description_ar':
          'مركز قلبي متخصص يجمع بين الرعاية الوقائية والإجراءات طفيفة التوغل.',
      'description_sp':
          'Hospital cardiaco especializado que combina prevención y procedimientos mínimamente invasivos.',
      'rating': 4.9,
    },
    {
      '_id': 'fh_2',
      'name': 'Aurora Women Wellness',
      'field': 'Women\'s Health',
      'facility_type': 'Women Clinic',
      'address': 'Oran, Algeria',
      'images': ['assets/images/fake/hospitals/2.jpg'],
      'videos': <String>[],
      'description_en':
          'Integrated maternity suites with on-site neonatal support and gentle recovery rooms.',
      'description_fr':
          'Suites maternité intégrées avec soutien néonatal et espaces de récupération apaisants.',
      'description_ar':
          'أجنحة أمومة متكاملة بدعم حديثي الولادة وغرف تعافٍ هادئة.',
      'description_sp':
          'Suites de maternidad integradas con soporte neonatal y salas de recuperación acogedoras.',
      'rating': 4.8,
    },
    {
      '_id': 'fh_3',
      'name': 'MotionLab Rehab Pavilion',
      'field': 'Physiotherapy',
      'facility_type': 'Rehabilitation Hospital',
      'address': 'Constantine, Algeria',
      'images': ['assets/images/fake/hospitals/3.jpg'],
      'videos': <String>[],
      'description_en':
          'A daylight-filled rehab wing focused on mobility labs and functional recovery coaching.',
      'description_fr':
          'Un pavillon baigné de lumière dédié à la réadaptation fonctionnelle et aux laboratoires de mobilité.',
      'description_ar':
          'جناح إعادة تأهيل مضاء بالنهار يركز على مختبرات الحركة وإرشاد التعافي الوظيفي.',
      'description_sp':
          'Pabellón de rehabilitación con luz natural dedicado a laboratorios de movilidad y recuperación funcional.',
      'rating': 4.7,
    },
    {
      '_id': 'fh_4',
      'name': 'ClearSkin Laser Institute',
      'field': 'Dermatology',
      'facility_type': 'Aesthetic Hospital',
      'address': 'Annaba, Algeria',
      'images': ['assets/images/fake/hospitals/4.jpg'],
      'videos': <String>[],
      'description_en':
          'Hybrid dermatology suites offering clinical care, laser therapies, and recovery lounges.',
      'description_fr':
          'Suites dermatologiques hybrides mêlant soins cliniques, laser et salons de repos.',
      'description_ar':
          'أجنحة جلدية هجينة تقدم رعاية طبية وعلاجات ليزر ومساحات استرخاء.',
      'description_sp':
          'Suites dermatológicas híbridas con cuidado clínico, terapias láser y salones de recuperación.',
      'rating': 4.6,
    },
    {
      '_id': 'fh_5',
      'name': 'OrthoPlus Sports Hub',
      'field': 'Orthopedics',
      'facility_type': 'Sports Medicine Center',
      'address': 'Blida, Algeria',
      'images': ['assets/images/fake/hospitals/5.jpg'],
      'videos': <String>[],
      'description_en':
          'Combines surgical theaters with hydrotherapy pools for athlete-first recovery.',
      'description_fr':
          'Allie blocs opératoires et bassins d’hydrothérapie pour une récupération centrée sur les sportifs.',
      'description_ar':
          'يجمع بين غرف العمليات وأحواض العلاج المائي لتعافي الرياضيين أولاً.',
      'description_sp':
          'Combina quirófanos con piscinas de hidroterapia para una recuperación centrada en atletas.',
      'rating': 4.8,
    },
    {
      '_id': 'fh_6',
      'name': 'BrightStart Kids Clinic',
      'field': 'Pediatrics',
      'facility_type': 'Children Hospital',
      'address': 'Tlemcen, Algeria',
      'images': ['assets/images/fake/hospitals/6.jpg'],
      'videos': <String>[],
      'description_en':
          'Child-friendly wards with sensory play zones and round-the-clock pediatric coverage.',
      'description_fr':
          'Services pédiatriques ludiques avec zones sensorielles et équipe disponible 24h/24.',
      'description_ar':
          'أجنحة صديقة للأطفال مع مناطق لعب حسية ورعاية أطفال على مدار الساعة.',
      'description_sp':
          'Salas pediátricas amigables con zonas sensoriales y cobertura continua.',
      'rating': 4.9,
    },
  ];
}
