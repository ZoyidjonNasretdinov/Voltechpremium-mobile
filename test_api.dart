// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final baseUrl = 'https://voltechpremiumbackend-api-production.up.railway.app/api';
  
  // Test login with a dummy user or just check register response format
  // We can't register a real one easily because of SMS verify, but maybe we can just try to login with some dummy credentials to see the error.
  final response = await http.post(
    Uri.parse('$baseUrl/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'phoneNumber': '998991234567', 'password': 'password123'}),
  );
  print('Login status: ${response.statusCode}');
  print('Login body: ${response.body}');
}
