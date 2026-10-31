import 'dart:convert';
class UserProfile {
  final String id;
  final String fullName;
  final String businessName;
  final String accountEmail;
  final String selectedCurrencySymbol;
  const UserProfile({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.accountEmail,
    required this.selectedCurrencySymbol,
  });
  factory UserProfile.defaultProfile(String uid) {
    return UserProfile(
      id: uid,
      fullName: 'New Freelancer',
      businessName: 'Independent Studio',
      accountEmail: 'user@example.com',
      selectedCurrencySymbol: '\$',
    );
  }
  UserProfile copyWith({
    String? id,
    String? fullName,
    String? businessName,
    String? accountEmail,
    String? selectedCurrencySymbol,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      businessName: businessName ?? this.businessName,
      accountEmail: accountEmail ?? this.accountEmail,
      selectedCurrencySymbol:
          selectedCurrencySymbol ?? this.selectedCurrencySymbol,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'businessName': businessName,
      'accountEmail': accountEmail,
      'selectedCurrencySymbol': selectedCurrencySymbol,
    };
  }
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    String readString(String key, {String fallback = ''}) {
      final value = map[key];
      return value is String ? value : fallback;
    }
    final rawId = map['id'];
    return UserProfile(
      id: (rawId is String && rawId.isNotEmpty) ? rawId : '',
      fullName: readString('fullName', fallback: 'New Freelancer'),
      businessName: readString('businessName', fallback: 'Independent Studio'),
      accountEmail: readString('accountEmail', fallback: 'user@example.com'),
      selectedCurrencySymbol:
          readString('selectedCurrencySymbol', fallback: '\$'),
    );
  }
  String toJson() => json.encode(toMap());
  factory UserProfile.fromJson(String source) =>
      UserProfile.fromMap(json.decode(source) as Map<String, dynamic>);
  @override
  String toString() {
    return 'UserProfile(id: $id, name: $fullName, business: $businessName, currency: $selectedCurrencySymbol)';
  }
  @override
  bool operator ==(covariant UserProfile other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.fullName == fullName &&
        other.businessName == businessName &&
        other.accountEmail == accountEmail &&
        other.selectedCurrencySymbol == selectedCurrencySymbol;
  }
  @override
  int get hashCode {
    return id.hashCode ^
        fullName.hashCode ^
        businessName.hashCode ^
        accountEmail.hashCode ^
        selectedCurrencySymbol.hashCode;
  }
}