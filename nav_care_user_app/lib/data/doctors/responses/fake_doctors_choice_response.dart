import '../models/doctor_model.dart';

class FakeDoctorsChoiceResponse {
  static List<DoctorModel> getFakeDoctorsChoice() {
    return _data
        .map((entry) => DoctorModel.fromJson(entry))
        .toList(growable: false);
  }

  static const List<Map<String, dynamic>> _data = [
    {
      '_id': 'doc_1',
      'cover': 'assets/images/fake/hospitals/2.jpg',
      'specialty': 'Cardiology',
      'rating': 4.9,
      'bio_en':
          'Leads the preventive heart program and focuses on day-case procedures.',
      'bio_fr':
          'Specialiste en prevention cardiaque avec 10 ans d experience.',
      'bio_ar':
          'Cardiology expert supporting heart health awareness programs.',
      'bio_sp':
          'Cardiologa centrada en prevencion y rehabilitacion cardiaca.',
      'affiliations': [
        'NavCare Heart Center',
        'Algiers Community Hospital',
      ],
      'user': {
        'name': 'Dr. Amal Benyahia',
        'avatar': 'assets/images/fake/profile_pics/female1.jpg',
      },
    },
    {
      '_id': 'doc_2',
      'cover': 'assets/images/fake/hospitals/4.jpg',
      'specialty': 'Pediatrics',
      'rating': 4.8,
      'bio_en':
          'Builds trusted relationships with families and champions early checkups.',
      'bio_fr':
          'Pediatre oriente sur l accompagnement familial et le suivi precoce.',
      'bio_ar':
          'Provides family centered pediatric care with flexible clinic hours.',
      'bio_sp':
          'Pediatra dedicada a la prevencion y acompanamiento de familias.',
      'affiliations': [
        'NavCare Kids Clinic',
      ],
      'user': {
        'name': 'Dr. Samir Haddad',
        'avatar': 'assets/images/fake/profile_pics/male1.jpg',
      },
    },
    {
      '_id': 'doc_3',
      'cover': 'assets/images/fake/hospitals/6.jpg',
      'specialty': 'Physiotherapy',
      'rating': 4.7,
      'bio_en':
          'Combines movement therapy with goal based recovery plans.',
      'bio_fr':
          'Physiotherapeute specialisee en reeducation fonctionnelle.',
      'bio_ar':
          'Guides patients through progressive mobility and strength routines.',
      'bio_sp':
          'Fisioterapeuta enfocada en planes de recuperacion personalizados.',
      'affiliations': [
        'MotionLab Rehab Studio',
      ],
      'user': {
        'name': 'Dr. Lina Cheriet',
        'avatar': 'assets/images/fake/profile_pics/female2.jpg',
      },
    },
    {
      '_id': 'doc_4',
      'cover': 'assets/images/fake/hospitals/1.jpg',
      'specialty': 'Dermatology',
      'rating': 4.6,
      'bio_en':
          'Supports skin health with evidence based cosmetic treatments.',
      'bio_fr':
          'Dermatologue specialiste en soins cutanes et laser doux.',
      'bio_ar':
          'Offers practical plans for long term skin wellness.',
      'bio_sp':
          'Dermatologa que equilibra tratamientos clinicos y cosmeticos.',
      'affiliations': [
        'ClearSkin Laser Center',
      ],
      'user': {
        'name': 'Dr. Nadia Belkacem',
        'avatar': 'assets/images/fake/profile_pics/female3.jpg',
      },
    },
    {
      '_id': 'doc_5',
      'cover': 'assets/images/fake/hospitals/3.jpg',
      'specialty': 'Orthopedics',
      'rating': 4.8,
      'bio_en':
          'Experienced in sports medicine and minimally invasive surgery.',
      'bio_fr':
          'Chirurgien orthopedique specialise en medecine du sport.',
      'bio_ar':
          'Helps athletes return to performance with clear recovery plans.',
      'bio_sp':
          'Ortopedista con enfasis en medicina deportiva y rehabilitacion.',
      'affiliations': [
        'NavCare Sports Clinic',
        'OrthoPlus Center',
      ],
      'user': {
        'name': 'Dr. Yacine Khellaf',
        'avatar': 'assets/images/fake/profile_pics/male2.jpg',
      },
    },
    {
      '_id': 'doc_6',
      'cover': 'assets/images/fake/hospitals/5.jpg',
      'specialty': 'Obstetrics & Gynecology',
      'rating': 4.9,
      'bio_en':
          'Advocates for personalized prenatal journeys and postnatal support.',
      'bio_fr':
          'Gynecologue accompagnee sur mesure des parcours maternite.',
      'bio_ar':
          'Creates supportive plans for prenatal and postnatal care.',
      'bio_sp':
          'Ginecologa que prioriza planes de cuidado prenatal personalizados.',
      'affiliations': [
        'NavCare Women Wellness',
      ],
      'user': {
        'name': 'Dr. Rania Meziane',
        'avatar': 'assets/images/fake/profile_pics/female4.jpg',
      },
    },
  ];
}
