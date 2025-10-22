import '../models/service_model.dart';

class FakeFeaturedServicesResponse {
  static List<ServiceModel> getFakeFeaturedServices() {
    return _data
        .map((item) => ServiceModel.fromJson(item))
        .toList(growable: false);
  }

  static const List<Map<String, dynamic>> _data = [
    {
      '_id': 'srv_1',
      'name_en': 'Cardiology Consultation',
      'name_fr': 'Consultation de cardiologie',
      'name_ar': 'استشارة أمراض القلب',
      'name_sp': 'Consulta de cardiología',
      'description_en': 'Comprehensive cardiac screening with top specialists.',
      'description_fr':
          'Un dépistage cardiaque complet avec des spécialistes renommés.',
      'description_ar': 'فحص قلبي شامل مع نخبة من الأخصائيين.',
      'description_sp':
          'Examen cardíaco integral con especialistas de primer nivel.',
      'image': 'assets/images/fake/services/1.jpg',
    },
    {
      '_id': 'srv_2',
      'name_en': 'Dental Care Package',
      'name_fr': 'Forfait de soins dentaires',
      'name_ar': 'حزمة العناية بالأسنان',
      'name_sp': 'Paquete de cuidados dentales',
      'description_en':
          'Routine cleaning, whitening, and dental check-up bundle.',
      'description_fr':
          'Nettoyage, blanchiment et contrôle dentaire regroupés.',
      'description_ar': 'تنظيف دوري وتبييض وفحص للأسنان في حزمة متكاملة.',
      'description_sp': 'Limpieza rutinaria, blanqueamiento y revisión dental.',
      'image': 'assets/images/fake/services/3.jpg',
    },
    {
      '_id': 'srv_3',
      'name_en': 'Wellness & Spa Retreat',
      'name_fr': 'Retraite bien-être & spa',
      'name_ar': 'رحلة استجمام وعافية',
      'name_sp': 'Retiro de bienestar y spa',
      'description_en':
          'Relaxing therapies and wellness sessions tailored for you.',
      'description_fr':
          'Thérapies relaxantes et séances de bien-être sur mesure.',
      'description_ar': 'جلسات استرخاء وعافية مصممة خصيصاً لك.',
      'description_sp':
          'Terapias relajantes y sesiones de bienestar a tu medida.',
      'image': 'assets/images/fake/services/2.jpg',
    },
    {
      '_id': 'srv_4',
      'name_en': 'Home Nursing Support',
      'name_fr': 'Soutien infirmier à domicile',
      'name_ar': 'رعاية تمريضية منزلية',
      'name_sp': 'Soporte de enfermería a domicilio',
      'description_en': 'Professional nurses available 24/7 at your home.',
      'description_fr':
          'Des infirmières professionnelles disponibles 24h/24 chez vous.',
      'description_ar': 'ممرضون محترفون متاحون على مدار الساعة في منزلك.',
      'description_sp':
          'Enfermeros profesionales disponibles 24/7 en tu hogar.',
      'image': 'assets/images/fake/services/4.jpg',
    },
  ];
}
