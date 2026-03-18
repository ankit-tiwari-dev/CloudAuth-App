import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/book_model.dart';

class BooksFirestoreService {
  BooksFirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _booksCol(String uid) {
    return _firestore.collection('users').doc(uid).collection('books');
  }

  Stream<List<BookModel>> watchBooks({required String uid}) {
    return _booksCol(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(BookModel.fromFirestore).toList());
  }

  Future<BookModel?> getBookById({
    required String uid,
    required String id,
  }) async {
    final doc = await _booksCol(uid).doc(id).get();
    if (!doc.exists) return null;
    return BookModel.fromFirestore(doc);
  }

  Future<String> addBook({required String uid, required BookModel book}) async {
    final doc = _booksCol(uid).doc();
    await doc.set({
      ...book.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  Future<void> updateBook({
    required String uid,
    required BookModel book,
  }) async {
    await _booksCol(uid).doc(book.id).update({
      ...book.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBook({required String uid, required String id}) async {
    await _booksCol(uid).doc(id).delete();
  }

  Future<void> toggleIssueStatus({
    required String uid,
    required String id,
    required bool currentIsIssued,
    required int currentQuantity,
  }) async {
    final willBeIssued = !currentIsIssued;
    final nextQty = willBeIssued ? currentQuantity - 1 : currentQuantity + 1;

    await _booksCol(uid).doc(id).update({
      'isIssued': willBeIssued,
      'quantity': nextQty.clamp(0, 1 << 31),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
