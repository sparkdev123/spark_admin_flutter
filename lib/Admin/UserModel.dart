class UserModel {
  String id;
  String name;
  String dobDay;
  String dobMonth;
  String dobYear;
  String bankAccountNumber;
  String routingNumber;
  String address;
  String city;
  String state;
  String postalCode;

  UserModel({
    required this.id,
    required this.name,
    required this.dobDay,
    required this.dobMonth,
    required this.dobYear,
    required this.bankAccountNumber,
    required this.routingNumber,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dobDay': dobDay,
      'dobMonth': dobMonth,
      'dobYear': dobYear,
      'bankAccountNumber': bankAccountNumber,
      'routingNumber': routingNumber,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      dobDay: json['dobDay'],
      dobMonth: json['dobMonth'],
      dobYear: json['dobYear'],
      bankAccountNumber: json['bankAccountNumber'],
      routingNumber: json['routingNumber'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
    );
  }
}