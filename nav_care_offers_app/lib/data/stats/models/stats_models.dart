class StatsAppointments {
  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> byType;

  const StatsAppointments({
    required this.total,
    required this.byStatus,
    required this.byType,
  });

  factory StatsAppointments.fromJson(Map<String, dynamic> json) {
    return StatsAppointments(
      total: _asInt(json['total']),
      byStatus: _mapToInt(json['byStatus']),
      byType: _mapToInt(json['byType']),
    );
  }

  int status(String key) => byStatus[key] ?? 0;
  int type(String key) => byType[key] ?? 0;

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Map<String, int> _mapToInt(dynamic raw) {
    if (raw is! Map) return const {};
    final mapped = <String, int>{};
    raw.forEach((key, value) {
      mapped[key.toString()] = _asInt(value);
    });
    return mapped;
  }
}

class DoctorStats {
  final StatsAppointments appointments;
  final int serviceOfferingsTotal;

  const DoctorStats({
    required this.appointments,
    required this.serviceOfferingsTotal,
  });

  factory DoctorStats.fromJson(Map<String, dynamic> json) {
    final appointmentsJson =
        json['appointments'] is Map<String, dynamic> ? json['appointments'] : {};
    final offeringsJson =
        json['serviceOfferings'] is Map<String, dynamic> ? json['serviceOfferings'] : {};

    return DoctorStats(
      appointments: StatsAppointments.fromJson(
          appointmentsJson.cast<String, dynamic>()),
      serviceOfferingsTotal: StatsAppointments._asInt(offeringsJson['total']),
    );
  }
}

class HospitalStats {
  final StatsAppointments appointments;
  final int serviceOfferingsTotal;
  final int clinicsTotal;
  final int doctorsTotal;

  const HospitalStats({
    required this.appointments,
    required this.serviceOfferingsTotal,
    required this.clinicsTotal,
    required this.doctorsTotal,
  });

  factory HospitalStats.fromJson(Map<String, dynamic> json) {
    final appointmentsJson =
        json['appointments'] is Map<String, dynamic> ? json['appointments'] : {};
    final offeringsJson =
        json['serviceOfferings'] is Map<String, dynamic> ? json['serviceOfferings'] : {};
    final clinicsJson = json['clinics'] is Map<String, dynamic> ? json['clinics'] : {};
    final doctorsJson = json['doctors'] is Map<String, dynamic> ? json['doctors'] : {};

    return HospitalStats(
      appointments: StatsAppointments.fromJson(
          appointmentsJson.cast<String, dynamic>()),
      serviceOfferingsTotal: StatsAppointments._asInt(offeringsJson['total']),
      clinicsTotal: StatsAppointments._asInt(clinicsJson['total']),
      doctorsTotal: StatsAppointments._asInt(doctorsJson['total']),
    );
  }
}
