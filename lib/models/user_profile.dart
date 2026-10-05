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
      selectedCurrencySymbol: selectedCurrencySymbol ?? this.selectedCurrencySymbol,
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
    return UserProfile(
      id: map['id'] as String? ?? '',
      fullName: map['fullName'] as String? ?? 'New Freelancer',
      businessName: map['businessName'] as String? ?? 'Independent Studio',
      accountEmail: map['accountEmail'] as String? ?? 'user@example.com',
      selectedCurrencySymbol: map['selectedCurrencySymbol'] as String? ?? '\$',
    );
  }
}
