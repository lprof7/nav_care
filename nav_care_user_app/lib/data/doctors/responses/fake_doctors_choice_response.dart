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
      'specialty': 'Cardiologist',
      'rating': 4.9,
      'bio_en':
          'Heart rhythm specialist with 12+ years in minimally invasive procedures.',
      'bio_fr':
          'Spécialiste du rythme cardiaque avec plus de 12 ans d’expérience en procédures mini-invasives.',
      'bio_ar':
          'أخصائي نظم قلب مع أكثر من 12 سنة خبرة في الإجراءات طفيفة التوغل.',
      'bio_sp':
          'Especialista en ritmo cardíaco con más de 12 años en procedimientos mínimamente invasivos.',
      'user': {
        'name': 'Dr. Amal Benyahia',
        'avatar': 'assets/images/fake/profile_pics/female1.jpg',
      },
    },
    {
      '_id': 'doc_2',
      'cover': 'assets/images/fake/hospitals/4.jpg',
      'specialty': 'Pediatrician',
      'rating': 4.8,
      'bio_en':
          'Creates friendly spaces for families and focuses on early care.',
      'bio_fr':
          'Crée des espaces conviviaux pour les familles avec un focus sur le suivi précoce.',
      'bio_ar': 'يخلق أجواء ودية للعائلات ويهتم بالرعاية المبكرة للأطفال.',
      'bio_sp':
          'Crea espacios amigables para las familias y se enfoca en la atención temprana.',
      'user': {
        'name': 'Dr. Samir Haddad',
        'avatar': 'assets/images/fake/profile_pics/male1.jpg',
      },
    },
    {
      '_id': 'doc_3',
      'cover': 'assets/images/fake/hospitals/6.jpg',
      'specialty': 'Physiotherapist',
      'rating': 4.7,
      'bio_en':
          'Rehabilitation expert blending motion therapy with mindful coaching.',
      'bio_fr':
          'Experte en rééducation mêlant thérapie du mouvement et coaching mental.',
      'bio_ar': 'خبيرة إعادة تأهيل تمزج بين العلاج الحركي والإرشاد الذهني.',
      'bio_sp':
          'Experta en rehabilitación que combina terapia de movimiento con coaching conscientes.',
      'user': {
        'name': 'Dr. Lina Cheriet',
        'avatar': 'assets/images/fake/profile_pics/female2.jpg',
      },
    },
  ];
}
