class GoogleAccount {
  GoogleAccount({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.isNewUser = false,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool isNewUser;
}
