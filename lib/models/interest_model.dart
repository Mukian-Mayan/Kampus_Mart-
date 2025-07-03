class Interest {
  final String id;
  final String name;
  final bool isSelected;

  const Interest({
    required this.id,
    required this.name,
    this.isSelected = false,
  });

  Interest copyWith({
    String? id,
    String? name,
    bool? isSelected,
  }) {
    return Interest(
      id: id ?? this.id,
      name: name ?? this.name,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Interest &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Interest(id: $id, name: $name, isSelected: $isSelected)';
}