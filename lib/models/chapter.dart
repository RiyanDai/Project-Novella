class Chapter {
  final int? id;
  final int novelId;
  final String title;
  final String content;
  final int chapterNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chapter({
    this.id,
    required this.novelId,
    required this.title,
    required this.content,
    required this.chapterNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'novel_id': novelId,
      'title': title,
      'content': content,
      'chapter_number': chapterNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      id: map['id'],
      novelId: map['novel_id'],
      title: map['title'],
      content: map['content'],
      chapterNumber: map['chapter_number'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  Chapter copyWith({
    int? id,
    int? novelId,
    String? title,
    String? content,
    int? chapterNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Chapter(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      title: title ?? this.title,
      content: content ?? this.content,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
} 