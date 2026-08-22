class OrganizationMemberModel {
  final String orgId;
  final String userId;
  final String role; // "org_admin" | "member"

  const OrganizationMemberModel({
    required this.orgId,
    required this.userId,
    required this.role,
  });

  factory OrganizationMemberModel.fromJson(Map<String, dynamic> json) {
    return OrganizationMemberModel(
      orgId: json['org_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org_id': orgId,
      'user_id': userId,
      'role': role,
    };
  }
}
