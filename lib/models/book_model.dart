import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

class BookModel {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final int quantity;
  final bool isIssued;

  const BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.quantity,
    required this.isIssued,
  });

  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    int? quantity,
    bool? isIssued,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      quantity: quantity ?? this.quantity,
      isIssued: isIssued ?? this.isIssued,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'quantity': quantity,
      'isIssued': isIssued,
    };
  }

  factory BookModel.fromMap(Map<String, dynamic> map) {
    return BookModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      author: map['author'] as String? ?? '',
      isbn: map['isbn'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      isIssued: map['isIssued'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory BookModel.fromJson(String source) =>
      BookModel.fromMap(json.decode(source) as Map<String, dynamic>);

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'isbn': isbn,
      'quantity': quantity,
      'isIssued': isIssued,
    };
  }

  factory BookModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const <String, dynamic>{};
    return BookModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      isbn: data['isbn'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      isIssued: data['isIssued'] as bool? ?? false,
    );
  }
}
