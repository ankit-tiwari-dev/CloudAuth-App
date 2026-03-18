import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'https://openlibrary.org/api/books';

  /// Fetches book details from Open Library API using ISBN.
  /// Returns a Map with 'title' and 'author' if found, otherwise null.
  static Future<Map<String, String>?> fetchBookByIsbn(String isbn) async {
    if (isbn.isEmpty) return null;
    
    // Clean ISBN (remove hyphens and spaces)
    final cleanedIsbn = isbn.replaceAll(RegExp(r'[\-\s]'), '');
    
    try {
      final url = Uri.parse('$_baseUrl?bibkeys=ISBN:$cleanedIsbn&format=json&jscmd=data');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final key = 'ISBN:$cleanedIsbn';
        
        if (data.containsKey(key)) {
          final bookData = data[key] as Map<String, dynamic>;
          
          final title = bookData['title'] as String? ?? '';
          final authors = bookData['authors'] as List? ?? [];
          final authorName = authors.isNotEmpty 
              ? (authors.first as Map<String, dynamic>)['name'] as String? ?? 'Unknown'
              : 'Unknown';

          return {
            'title': title,
            'author': authorName,
          };
        }
      }
      return null;
    } catch (e) {
      // In a real app, you might want to log this or notify the user
      return null;
    }
  }
}
