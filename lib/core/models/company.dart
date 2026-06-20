class Company {
  final int companyId;
  final String name;
  final String? code;
  final String? businessType;

  Company({
    required this.companyId,
    required this.name,
    this.code,
    this.businessType,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      companyId: json['companyid'] ?? json['CompanyId'] ?? 0,
      name: json['name'] ?? json['Name'] ?? '',
      code: json['code'] ?? json['Code'],
      businessType: json['businesstype'] ?? json['BusinessType'],
    );
  }
}
