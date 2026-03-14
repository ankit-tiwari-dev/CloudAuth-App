class ApiService {
  // A stub for an external API service if needed outside of Firebase

  Future<dynamic> fetchData(String endpoint) async {
    // Stub implementation to mimic an API response
    await Future.delayed(const Duration(seconds: 1));
    return {"status": "success", "data": "Sample API response from $endpoint"};
  }
}
