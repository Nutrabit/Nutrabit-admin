import 'file_type.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FileModel {
  final String id;
  final String title;
  final FileType type;
  final String url;
  final String userId;
  final DateTime? createdAt;

  FileModel({
    required this.id,
    required this.title,
    required this.type,
    required this.url,
    required this.userId,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'url': url,
      'userId': userId,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(), // Fecha generada por el servidor
    };
  }

  factory FileModel.fromJson(Map<String, dynamic> json, {String id = ''}) {
    return FileModel(
      id: json['id'] ?? id,
      title: json['title'] ?? '',
      type: FileType.values.firstWhere((e) => e.name == json['type']),
      url: json['url'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}