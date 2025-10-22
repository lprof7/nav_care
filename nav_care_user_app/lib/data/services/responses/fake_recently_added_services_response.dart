import '../models/service_model.dart';

class FakeRecentlyAddedServicesResponse {
  static List<ServiceModel> getFakeRecentlyAddedServices() {
    return _data
        .map((item) => ServiceModel.fromJson(item))
        .toList(growable: false);
  }

  static const List<Map<String, dynamic>> _data = [
    {
      '_id': 'srv_new_1',
      'name_en': 'On-demand Telemedicine',
      'name_fr': 'Télémédecine à la demande',
      'name_ar': 'الطب عن بعد عند الطلب',
      'name_sp': 'Telemedicina a demanda',
      'description_en':
          'Instant access to certified specialists for remote consultations.',
      'description_fr':
          'Accès instantané à des spécialistes certifiés pour des consultations à distance.',
      'description_ar': 'وصول فوري لأطباء مختصين للاستشارات عن بعد.',
      'description_sp':
          'Acceso instantáneo a especialistas certificados para consultas remotas.',
      'image': 'assets/images/fake/services/2.jpg',
    },
    {
      '_id': 'srv_new_2',
      'name_en': 'Premium Maternity Support',
      'name_fr': 'Programme maternité premium',
      'name_ar': 'برنامج دعم الأمومة المميز',
      'name_sp': 'Programa premium de maternidad',
      'description_en':
          'Personalized maternity planning with home visits and 24/7 support.',
      'description_fr':
          'Accompagnement maternité personnalisé avec visites à domicile et assistance 24/7.',
      'description_ar': 'تخطيط أمومة شخصي مع زيارات منزلية ودعم على مدار الساعة.',
      'description_sp':
          'Planificación de maternidad personalizada con visitas a domicilio y soporte 24/7.',
      'image': 'assets/images/fake/services/3.jpg',
    },
    {
      '_id': 'srv_new_3',
      'name_en': 'Executive Health Screening',
      'name_fr': 'Bilan de santé exécutif',
      'name_ar': 'فحص صحي تنفيذي',
      'name_sp': 'Chequeo ejecutivo de salud',
      'description_en':
          'A comprehensive check-up tailored for high-performance lifestyles.',
      'description_fr':
          'Un bilan complet taillé pour les rythmes de vie intensifs.',
      'description_ar': 'فحص شامل مصمم لأسلوب حياة عالي الأداء.',
      'description_sp':
          'Un chequeo integral diseñado para estilos de vida de alto rendimiento.',
      'image': 'assets/images/fake/services/4.jpg',
    },
  ];
}
