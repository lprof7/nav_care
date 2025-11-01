import '../models/doctor_model.dart';

class FakeFeaturedDoctorsResponse {
  static List<DoctorModel> getFakeFeaturedDoctors() {
    return _data
        .map((entry) => DoctorModel.fromJson(entry))
        .toList(growable: false);
  }

  static const List<Map<String, dynamic>> _data = [
    {
      '_id': 'fdoc_1',
      'cover': 'assets/images/fake/profile_pics/female1.jpg',
      'specialty': 'Cardiology',
      'rating': 4.9,
      'bio_en':
          'Leads preventative cardiology programs focused on lifestyle coaching.',
      'bio_fr':
          'Dirige des programmes de cardiologie préventive axés sur le coaching de vie.',
      'bio_ar': 'تقود برامج الوقاية القلبية مع إرشاد شخصي لنمط الحياة.',
      'bio_sp':
          'Dirige programas de cardiología preventiva centrados en cambios de estilo de vida.',
      'affiliations': [
        'NavCare Heart Center',
        'Aurora Cardio Lab',
      ],
      'user': {
        'name': 'Dr. Amal Benyahia',
        'avatar': 'assets/images/fake/profile_pics/female1.jpg',
        'email': 'amal.benyahia@navcare.com',
      },
    },
    {
      '_id': 'fdoc_2',
      'cover': 'assets/images/fake/profile_pics/male1.jpg',
      'specialty': 'Pediatrics',
      'rating': 4.8,
      'bio_en':
          'Creates playful pediatric visits with extended family education blocks.',
      'bio_fr':
          'Organise des consultations pédiatriques ludiques avec ateliers familiaux renforcés.',
      'bio_ar': 'يقدّم زيارات أطفال ممتعة مع حصص تثقيفية موسعة للعائلة.',
      'bio_sp':
          'Diseña consultas pediátricas dinámicas con espacios de formación familiar ampliados.',
      'affiliations': [
        'BrightStart Kids Clinic',
      ],
      'user': {
        'name': 'Dr. Samir Haddad',
        'avatar': 'assets/images/fake/profile_pics/male1.jpg',
        'email': 'samir.haddad@navcare.com',
      },
    },
    {
      '_id': 'fdoc_3',
      'cover': 'assets/images/fake/profile_pics/female2.jpg',
      'specialty': 'Physiotherapy',
      'rating': 4.7,
      'bio_en':
          'Blends movement labs with digital dashboards to visualise recovery milestones.',
      'bio_fr':
          'Allie laboratoires de mouvement et tableaux de bord numériques pour suivre la progression.',
      'bio_ar': 'تدمج مختبرات الحركة مع لوحات متابعة رقمية لمراحل التعافي.',
      'bio_sp':
          'Combina laboratorios de movimiento con tableros digitales para visualizar la recuperación.',
      'affiliations': [
        'MotionLab Rehab Pavilion',
      ],
      'user': {
        'name': 'Dr. Lina Cheriet',
        'avatar': 'assets/images/fake/profile_pics/female2.jpg',
        'email': 'lina.cheriet@navcare.com',
      },
    },
    {
      '_id': 'fdoc_4',
      'cover': 'assets/images/fake/profile_pics/female3.webp',
      'specialty': 'Dermatology',
      'rating': 4.6,
      'bio_en':
          'Builds restorative skin plans that pair gentle lasers with home rituals.',
      'bio_fr':
          'Élabore des protocoles cutanés régénérants mêlant laser doux et rituels à domicile.',
      'bio_ar': 'تضع خططاً علاجية للبشرة تجمع بين تقنيات الليزر والروتين المنزلي.',
      'bio_sp':
          'Crea planes cutáneos restaurativos que combinan láser suave y rutinas en casa.',
      'affiliations': [
        'ClearSkin Laser Institute',
      ],
      'user': {
        'name': 'Dr. Nadia Belkacem',
        'avatar': 'assets/images/fake/profile_pics/female3.webp',
        'email': 'nadia.belkacem@navcare.com',
      },
    },
    {
      '_id': 'fdoc_5',
      'cover': 'assets/images/fake/profile_pics/male2.webp',
      'specialty': 'Orthopedics',
      'rating': 4.85,
      'bio_en':
          'Guides athletes through minimally invasive joint recovery protocols.',
      'bio_fr':
          'Accompagne les sportifs avec des protocoles articulaires mini-invasifs.',
      'bio_ar': 'يرافق الرياضيين عبر بروتوكولات تعافٍ مفصلية طفيفة التوغل.',
      'bio_sp':
          'Guía a los atletas mediante protocolos articulares mínimamente invasivos.',
      'affiliations': [
        'OrthoPlus Sports Hub',
      ],
      'user': {
        'name': 'Dr. Yacine Khellaf',
        'avatar': 'assets/images/fake/profile_pics/male2.webp',
        'email': 'yacine.khellaf@navcare.com',
      },
    },
    {
      '_id': 'fdoc_6',
      'cover': 'assets/images/fake/profile_pics/female4.jpg',
      'specialty': 'Obstetrics & Gynecology',
      'rating': 4.92,
      'bio_en':
          'Designs gentle prenatal journeys with immersive birth-prep workshops.',
      'bio_fr':
          'Conçoit des parcours prénataux doux avec ateliers immersifs de préparation à la naissance.',
      'bio_ar': 'تصمم مسارات ولادة لطيفة مع ورش تحضير غامرة للحوامل.',
      'bio_sp':
          'Diseña recorridos prenatales suaves con talleres inmersivos de preparación al parto.',
      'affiliations': [
        'Aurora Women Wellness',
      ],
      'user': {
        'name': 'Dr. Rania Meziane',
        'avatar': 'assets/images/fake/profile_pics/female4.jpg',
        'email': 'rania.meziane@navcare.com',
      },
    },
  ];
}
