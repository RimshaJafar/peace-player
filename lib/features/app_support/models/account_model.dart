class AccountModel {
  final String method;
  final String displayName;
  final String accountNumber;
  final String? iban;
  final String accountTitle;
  final bool isActive;
  final String? updatedAt;

  const AccountModel({
    required this.method,
    required this.displayName,
    required this.accountNumber,
    this.iban,
    required this.accountTitle,
    this.isActive = true,
    this.updatedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      method: json['method']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? '',
      iban: json['iban']?.toString(),
      accountTitle: json['account_title']?.toString() ?? '',
      isActive: json['is_active'] == true,
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'display_name': displayName,
      'account_number': accountNumber,
      'iban': iban,
      'account_title': accountTitle,
      'is_active': isActive,
    };
  }
}

class AccountNumbersResponse {
  final List<AccountModel> accounts;

  const AccountNumbersResponse({required this.accounts});

  factory AccountNumbersResponse.fromJson(Map<String, dynamic> json) {
    final list = json['accounts'] as List? ?? [];
    return AccountNumbersResponse(
      accounts: list
          .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
