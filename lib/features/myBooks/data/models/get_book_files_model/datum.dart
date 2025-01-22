import 'package:equatable/equatable.dart';

class DatumBook extends Equatable {
  final int? id;
  final String? name;
  final int? groupsId;
  final int? userId;
  final String? path;
  final String? status;
  final String? downloadUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DatumBook({
    this.id,
    this.name,
    this.groupsId,
    this.userId,
    this.path,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.downloadUrl
  });

  factory DatumBook.fromJson(Map<String, dynamic> json) => DatumBook(
        id: json['id'] as int?,
        name: json['name'] as String?,
        groupsId: json['groups_id'] as int?,
        userId: json['user_id'] as int?,
        path: json['path'] as String?,
        status: json['status'] as String?,
        downloadUrl: json['download_url'] as String?,
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'groups_id': groupsId,
        'user_id': userId,
        'path': path,
        'status': status,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  @override
  List<Object?> get props {
    return [
      id,
      name,
      groupsId,
      userId,
      path,
      status,
      createdAt,
      updatedAt,
    ];
  }
}
