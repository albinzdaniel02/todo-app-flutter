import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 2)
class Category extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String colorHex;

  @HiveField(3)
  final int? iconCodePoint;

  const Category({
    required this.id,
    required this.name,
    required this.colorHex,
    this.iconCodePoint,
  });

  Category copyWith({
    String? id,
    String? name,
    String? colorHex,
    Object? iconCodePoint = const Object(),
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconCodePoint: iconCodePoint == const Object()
          ? this.iconCodePoint
          : iconCodePoint as int?,
    );
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      colorHex: json['colorHex'] as String,
      iconCodePoint: json['iconCodePoint'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'colorHex': colorHex,
      'iconCodePoint': iconCodePoint,
    };
  }

  @override
  List<Object?> get props => [id, name, colorHex, iconCodePoint];
}
