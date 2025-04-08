class AccountModel {
  final String accountHolderName;
  final String accountRoutingNumber;
  final String accountNumber;
  final String accountHolderdateOfBirth;
  final String accountHolderAddress;
  final String accountHolderCity;
  final String accountHolderState;
  final String accountHolderPostalCode;
  final String accountHolderCreatedAt;

  AccountModel({
    required this.accountHolderName,
    required this.accountRoutingNumber,
    required this.accountNumber, 
    required this.accountHolderdateOfBirth, 
    required this.accountHolderAddress, 
    required this.accountHolderCity,
    required this.accountHolderState, 
    required this.accountHolderPostalCode, 
    required this.accountHolderCreatedAt
    });
  // Convert from JSON (useful for Firestore/API responses)
  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      accountHolderName: json['accountHolderName'],
      accountRoutingNumber: json['accountRoutingNumber'],
      accountNumber: json['accountNumber'],
      accountHolderdateOfBirth: json['accountHolderdateOfBirth'],
      accountHolderAddress: json['accountHolderAddress'],
      accountHolderCity: json['accountHolderCity'],
      accountHolderState: json['accountHolderState'],
      accountHolderPostalCode: json['accountHolderPostalCode'],
      accountHolderCreatedAt: json['accountHolderCreatedAt']
    );
  }

  // Convert to JSON (useful for Firestore/API requests)
  Map<String, dynamic> toJson() {
    return {
      'accountHolderName': accountHolderName,
      'accountRoutingNumber': accountRoutingNumber,
      'accountNumber': accountNumber,
      'accountHolderdateOfBirth': accountHolderdateOfBirth,
      'accountHolderAddress': accountHolderAddress,
      'accountHolderCity': accountHolderCity,
      'accountHolderState': accountHolderState,
      'accountHolderPostalCode': accountHolderPostalCode,
      'accountHolderCreatedAt': accountHolderCreatedAt
    };
  }

  // Update method (copyWith pattern)
  AccountModel copyWith({String? accountHolderName, String? accountRoutingNumber, String? accountNumber, String? accountHolderdateOfBirth, String? accountHolderAddress, String? accountHolderCity, String? accountHolderState, String? accountHolderPostalCode, String
  ? accountHolderCreatedAt}) {
    return AccountModel(
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountRoutingNumber: accountRoutingNumber ?? this.accountRoutingNumber,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderdateOfBirth: accountHolderdateOfBirth ?? this.accountHolderdateOfBirth,
      accountHolderAddress: accountHolderAddress ?? this.accountHolderAddress,
      accountHolderCity: accountHolderCity ?? this.accountHolderCity,
      accountHolderState: accountHolderState ?? this.accountHolderState,
      accountHolderPostalCode: accountHolderPostalCode ?? this.accountHolderPostalCode,
      accountHolderCreatedAt: accountHolderCreatedAt ?? this.accountHolderCreatedAt
    );
  }
}






