class Organization {
  final String id;
  final String name;
  final DateTime? createdAt;

  const Organization({
    required this.id,
    required this.name,
    this.createdAt,
  });

  Organization copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
  }) {
    return Organization(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
