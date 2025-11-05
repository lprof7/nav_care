enum ManageTarget { clinics, doctors }

extension ManageTargetLabel on ManageTarget {
  String translationKey() {
    switch (this) {
      case ManageTarget.clinics:
        return 'hospitals.manage.clinics_title';
      case ManageTarget.doctors:
        return 'hospitals.manage.doctors_title';
    }
  }

  String descriptionKey() {
    switch (this) {
      case ManageTarget.clinics:
        return 'hospitals.manage.clinics_description';
      case ManageTarget.doctors:
        return 'hospitals.manage.doctors_description';
    }
  }
}
