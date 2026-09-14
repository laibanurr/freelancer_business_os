class Client {
  final String name;
  final String id;
  final String phoneNumber;
  final String email;
  final String companyName;

  Client({
    required this.name,
    required this.id,
    required this.phoneNumber,
    required this.email,
    required this.companyName,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'companyName': companyName,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      name: map['name'] as String,
      id: map['id'] as String,
      phoneNumber: map['phoneNumber'] as String,
      email: map['email'] as String,
      companyName: map['companyName'] as String,
    );
  }
}
