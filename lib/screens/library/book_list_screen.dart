import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../routes/app_routes.dart';

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  void _showDeleteDialog(BuildContext context, BookModel book) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<BookProvider>().deleteBook(book.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final bookProvider = context.watch<BookProvider>();

    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Directory'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.pushReplacementNamed(context, AppRoutes.home),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              }
            },
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (bookProvider.isLoading && bookProvider.books.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (bookProvider.books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.menu_book, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No books available',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a new book',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              var crossAxisCount = 1;
              if (constraints.maxWidth > 900) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth > 600) {
                crossAxisCount = 2;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisExtent: 170,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: bookProvider.books.length,
                itemBuilder: (context, index) {
                  final book = bookProvider.books[index];
                  return _BookCard(
                    book: book,
                    onEdit: () => Navigator.pushNamed(
                      context,
                      AppRoutes.editBook,
                      arguments: book.id,
                    ),
                    onDelete: () => _showDeleteDialog(context, book),
                    onToggleIssue: () =>
                        context.read<BookProvider>().toggleIssueStatus(book),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addBook),
        backgroundColor: const Color(0xFF6C63FF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleIssue,
  });

  final BookModel book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleIssue;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Author: ${book.author}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            Text(
              'ISBN: ${book.isbn}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Qty: ${book.quantity}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                ElevatedButton(
                  onPressed:
                      book.quantity == 0 && !book.isIssued ? null : onToggleIssue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: book.isIssued
                        ? Colors.orange.shade600
                        : (book.quantity > 0
                            ? const Color(0xFF3F3D99)
                            : Colors.grey),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (book.isIssued) ...[
                        const Icon(Icons.chevron_left,
                            size: 18, color: Colors.white),
                        const SizedBox(width: 4),
                        const Text(
                          'Return',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ] else if (book.quantity > 0) ...[
                        const Text(
                          'Issue',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right,
                            size: 18, color: Colors.white),
                      ] else ...[
                        const Text(
                          'Out of Stock',
                          style: TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
