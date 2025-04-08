class Account {
  final String id;
  final String name;
  final String email;
  final double balance;

  Account({
    required this.id,
    required this.name,
    required this.email,
    required this.balance,
  });

  // Convert Firestore Document to Account Object
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      balance: (json['balance'] as num).toDouble(),
    );
  }

  // Convert Account Object to Firestore JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'balance': balance,
    };
  }

  // CopyWith Method for Updating Fields
  Account copyWith({String? name, String? email, double? balance}) {
    return Account(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      balance: balance ?? this.balance,
    );
  }
}