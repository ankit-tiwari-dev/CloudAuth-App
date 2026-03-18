import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/api_service.dart';

class AddEditBookScreen extends StatefulWidget {
  const AddEditBookScreen({super.key, this.bookId});

  final String? bookId;

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _isbnController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isLoading = false;
  bool _didPopulate = false;
  bool _isIssued = false;
  bool _isFetchingIsbn = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPopulate || widget.bookId == null) return;
    _loadBook();
  }

  Future<void> _loadBook() async {
    setState(() => _isLoading = true);
    final book = await context.read<BookProvider>().fetchBookById(widget.bookId!);
    if (book != null && mounted) {
      _titleController.text = book.title;
      _authorController.text = book.author;
      _isbnController.text = book.isbn;
      _quantityController.text = book.quantity.toString();
      _isIssued = book.isIssued;
    }
    _didPopulate = true;
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchBookDetails() async {
    final isbn = _isbnController.text.trim();
    if (isbn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an ISBN first')),
      );
      return;
    }

    setState(() => _isFetchingIsbn = true);
    
    final details = await ApiService.fetchBookByIsbn(isbn);
    
    if (mounted) {
      if (details != null) {
        _titleController.text = details['title'] ?? _titleController.text;
        _authorController.text = details['author'] ?? _authorController.text;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book details found!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No details found for this ISBN')),
        );
      }
      setState(() => _isFetchingIsbn = false);
    }
  }

  Future<void> _save() async {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isAuthenticated) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final bookProvider = context.read<BookProvider>();
    final isEditing = widget.bookId != null;
    final book = BookModel(
      id: widget.bookId ?? '',
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      isbn: _isbnController.text.trim(),
      quantity: int.parse(_quantityController.text.trim()),
      isIssued: _isIssued,
    );

    try {
      if (isEditing) {
        await bookProvider.updateBook(book);
      } else {
        await bookProvider.addBook(book);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing ? 'Book updated successfully!' : 'Book added successfully!',
          ),
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.books);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Save failed: ${e.toString()}'),
          backgroundColor: Colors.red.shade400,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bookId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Add Book'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.books),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter book title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _authorController,
                    decoration: const InputDecoration(
                      labelText: 'Author',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter author name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _isbnController,
                    decoration: InputDecoration(
                      labelText: 'ISBN',
                      prefixIcon: const Icon(Icons.numbers),
                      suffixIcon: _isFetchingIsbn
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : IconButton(
                              icon: const Icon(Icons.search),
                              tooltip: 'Fetch book details',
                              onPressed: _fetchBookDetails,
                            ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter ISBN';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter quantity';
                      }
                      final parsed = int.tryParse(value.trim());
                      if (parsed == null || parsed < 0) {
                        return 'Please enter a valid positive number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isEditing ? 'Save Changes' : 'Add Book'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _quantityController.dispose();
    super.dispose();
  }
}
