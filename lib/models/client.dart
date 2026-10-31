import 'dart:convert';
class Client {
  final String id;
  final String name;
  final String phoneNumber;
  final String email;
  final String? companyName;

  const Client({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    this.companyName,
  });

  
  Client copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? companyName,
    bool clearCompanyName = false,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      companyName: clearCompanyName
          ? null
          : companyName ?? this.companyName,
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'companyName': companyName,
    };
  }

  
  factory Client.fromMap(Map<String, dynamic> map) {
    final rawId = map['id'];

    if (rawId is! String || rawId.trim().isEmpty) {
      throw const FormatException(
        'Client data is missing a valid ID.',
      );
    }

    String readString(String key) {
      final value = map[key];
      return value is String ? value : '';
    }

    final name = readString('name').trim();

    final rawCompany = map['companyName'];

    return Client(
      id: rawId,
      name: name.isEmpty ? 'Unnamed Client' : name,
      phoneNumber: readString('phoneNumber'),
      email: readString('email'),
      companyName:
          rawCompany is String ? rawCompany : null,
    );
  }


  String toJson() => json.encode(toMap());

  factory Client.fromJson(String source) =>
      Client.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Client(id: $id, name: $name, phoneNumber: $phoneNumber, email: $email, companyName: $companyName)';
  }

  @override
  bool operator ==(covariant Client other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.companyName == companyName;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        companyName.hashCode;
  }
}
