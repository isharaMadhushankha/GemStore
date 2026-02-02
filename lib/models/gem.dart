class Gem {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final double price;
  final String? color;
  final double? weight;
  final String? model;
  final String? location;
  final String? contactName;
  final String? contactPhone;
  final String? contactEmail;
  final List<String> images;
  final String status; 
  final DateTime createdAt;
  final DateTime updatedAt;
  
  String? sellerName;
  bool isFavorite;

  Gem({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.price,
    this.color,
    this.weight,
    this.model,
    this.location,
    this.contactName,
    this.contactPhone,
    this.contactEmail,
    required this.images,
    this.status = 'available',
    required this.createdAt,
    required this.updatedAt,
    this.sellerName,
    this.isFavorite = false,
  });

  factory Gem.fromJson(Map<String, dynamic> json) {
    return Gem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      color: json['color'] as String?,
      weight: json['weight'] != null ? (json['weight'] as num).toDouble() : null,
      model: json['model'] as String?,
      location: json['location'] as String?,
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      contactEmail: json['contact_email'] as String?,
      images: json['images'] != null 
          ? List<String>.from(json['images'] as List) 
          : [],
      status: json['status'] as String? ?? 'available',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sellerName: json['seller_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'price': price,
      'color': color,
      'weight': weight,
      'model': model,
      'location': location,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'images': images,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Gem copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    double? price,
    String? color,
    double? weight,
    String? model,
    String? location,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    List<String>? images,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? sellerName,
    bool? isFavorite,
  }) {
    return Gem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      model: model ?? this.model,
      location: location ?? this.location,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sellerName: sellerName ?? this.sellerName,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
