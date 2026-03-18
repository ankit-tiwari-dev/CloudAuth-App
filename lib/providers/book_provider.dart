import 'dart:async';

import 'package:flutter/material.dart';

import '../models/book_model.dart';
import '../services/books_firestore_service.dart';
import '../services/local_storage_service.dart';

class BookProvider extends ChangeNotifier {
  BookProvider({BooksFirestoreService? service})
      : _service = service ?? BooksFirestoreService();

  final BooksFirestoreService _service;
  StreamSubscription<List<BookModel>>? _subscription;

  String? _uid;
  List<BookModel> _books = <BookModel>[];
  bool _isLoading = false;
  Object? _lastError;

  List<BookModel> get books => _books;
  bool get isLoading => _isLoading;
  Object? get lastError => _lastError;

  Future<void> updateUser(String? uid) async {
    if (_uid == uid) return;

    _uid = uid;
    await _subscription?.cancel();
    _subscription = null;

    if (_uid == null) {
      _books = <BookModel>[];
      _isLoading = false;
      _lastError = null;
      Future.microtask(() => notifyListeners());
      return;
    }

    _isLoading = true;
    _lastError = null;
    _books = await LocalStorageService.getBooks(_uid!);
    Future.microtask(() => notifyListeners());

    _subscription = _service.watchBooks(uid: _uid!).listen(
      (items) async {
        _books = items;
        _lastError = null;
        _isLoading = false;
        await LocalStorageService.saveBooks(_uid!, items);
        notifyListeners();
      },
      onError: (error) async {
        _lastError = error;
        _books = await LocalStorageService.getBooks(_uid!);
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addBook(BookModel book) async {
    if (_uid == null) return;
    await _service.addBook(uid: _uid!, book: book);
  }

  Future<void> updateBook(BookModel book) async {
    if (_uid == null) return;
    await _service.updateBook(uid: _uid!, book: book);
  }

  Future<void> deleteBook(String id) async {
    if (_uid == null) return;
    await _service.deleteBook(uid: _uid!, id: id);
  }

  Future<void> toggleIssueStatus(BookModel book) async {
    if (_uid == null) return;
    if (!book.isIssued && book.quantity <= 0) return;

    await _service.toggleIssueStatus(
      uid: _uid!,
      id: book.id,
      currentIsIssued: book.isIssued,
      currentQuantity: book.quantity,
    );
  }

  Future<BookModel?> fetchBookById(String id) async {
    final localBook = getBookById(id);
    if (localBook != null || _uid == null) return localBook;
    return _service.getBookById(uid: _uid!, id: id);
  }

  BookModel? getBookById(String id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
