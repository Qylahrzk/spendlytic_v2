class UserModel {
  final String id; // Matches 'id' (uuid)
  final String email; // ✅ Added this field
  final String fullName; // Matches 'full_name'
  final String? avatarUrl; // Matches 'avatar_url'
  final String defaultCurrency; // Matches 'default_currency'

  UserModel({
    required this.id,
    required this.email, // ✅ Added to constructor
    required this.fullName,
    this.avatarUrl,
    this.defaultCurrency = 'MYR (RM)',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '', // ✅ Read from Supabase JSON
      fullName: json['full_name'] ?? 'Student',
      avatarUrl: json['avatar_url'],
      defaultCurrency: json['default_currency'] ?? 'MYR (RM)',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email, // ✅ Save to Supabase JSON
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'default_currency': defaultCurrency,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
