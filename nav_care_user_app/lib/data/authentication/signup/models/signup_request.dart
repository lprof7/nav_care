class SignupRequest {
  SignupRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.address,
    required this.city,
    required this.state,
    required this.country,
    this.birthDate,
    this.file,
  });

  final String name;
  final String email;
  final String phone;
  final String password;
  final String address;
  final String city;
  final String state;
  final String country;
  final String? birthDate;
  final Object? file;

  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
    };

    if (birthDate != null && birthDate!.isNotEmpty) {
      map['birthDate'] = birthDate;
    }

    if (file != null) {
      map['file'] = file;
    }

    return map;
  }
}
