class Example {
  final String id;
  final String title;
  final String? description;

  Example({required this.id, required this.title, this.description});

  factory Example.fromJson(Map<String, dynamic> json) => Example(
        id: json['id'].toString(),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
      };
}
