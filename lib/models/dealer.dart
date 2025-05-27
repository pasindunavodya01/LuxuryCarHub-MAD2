class Dealer {
  final int id;
  final String name;
  final String email;
  final String role;
  final String phoneNumber;
  final String profilePhotoUrl;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  Dealer({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phoneNumber,
    required this.profilePhotoUrl,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory Dealer.fromJson(Map<String, dynamic> json) {
    return Dealer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      profilePhotoUrl: json['profile_photo_url'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
