import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl = 'http://localhost:8080/api';

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));

    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),

      headers: {'Content-Type': 'application/json'},

      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final decodedBody = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decodedBody;
    }

    throw Exception(decodedBody['message'] ?? 'Unknown API Error');
  }
}
