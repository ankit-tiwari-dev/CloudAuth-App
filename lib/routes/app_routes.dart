import 'package:flutter/material.dart';

import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/library/add_edit_book_screen.dart';
import '../screens/library/book_list_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String books = '/books';
  static const String addBook = '/books/add';
  static const String editBook = '/books/edit';

  static Map<String, WidgetBuilder> get routes {
    return {
      login: (_) => const LoginScreen(),
      register: (_) => const RegisterScreen(),
      home: (_) => const HomeScreen(),
      books: (_) => const BookListScreen(),
      addBook: (_) => const AddEditBookScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == editBook) {
      final bookId = settings.arguments as String?;
      return MaterialPageRoute(
        builder: (_) => AddEditBookScreen(bookId: bookId),
        settings: settings,
      );
    }
    return null;
  }
}
