class Novel {
  final int? id;
  final String title;
  final String author;
  final DateTime createdAt;
  final DateTime updatedAt;

  Novel({
    this.id,
    required this.title,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Novel.fromMap(Map<String, dynamic> map) {
    return Novel(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Novel copyWith({
    int? id,
    String? title,
    String? author,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 