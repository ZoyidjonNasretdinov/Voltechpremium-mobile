import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://voltechpremiumbackend-api-production.up.railway.app/api';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  dynamic _safeDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return body; // return plain text if not JSON
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _safeDecode(response.body);
        if (data is Map && data['accessToken'] != null) {
          await saveToken(data['accessToken']);
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Telefon raqam yoki parol noto\'g\'ri'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> sendSms(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': _safeDecode(response.body)};
      } else {
        return {'success': false, 'message': 'SMS yuborishda xatolik'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> verifySms(String phone, String code) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'verificationCode': code}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _safeDecode(response.body);
        if (data is Map && data['accessToken'] != null) {
          await saveToken(data['accessToken']);
        }
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Noto\'g\'ri kod'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPasswordSendSms(String phone) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/send-sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': _safeDecode(response.body)};
      } else {
        return {'success': false, 'message': 'SMS yuborishda xatolik'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPasswordReset(String phone, String code, String newPassword) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'verificationCode': code, 'newPassword': newPassword}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': _safeDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Parolni tiklashda xatolik'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.get(
        Uri.parse('$baseUrl/v1/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': _safeDecode(response.body)};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'Profilni yuklashda xatolik'};
        } catch (_) {
          return {'success': false, 'message': 'Profilni yuklashda xatolik'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    String firstName, 
    String lastName, 
    int age, 
    String region, 
    String district
  ) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.put(
        Uri.parse('$baseUrl/v1/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'age': age,
          'region': region,
          'district': district,
        }),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': _safeDecode(response.body)};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'Profilni yangilashda xatolik yuz berdi'};
        } catch (_) {
          return {'success': false, 'message': 'Profilni yangilashda xatolik (Status: ${response.statusCode})'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }


  Future<Map<String, dynamic>> register(
    String phone, 
    String password, 
    String firstName, 
    String lastName, 
    int age, 
    String region, 
    String district
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phone,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'age': age,
          'region': region,
          'district': district,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _safeDecode(response.body);
        if (data is Map && data['accessToken'] != null) {
          await saveToken(data['accessToken']);
        }
        return {'success': true, 'data': data};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'Ro\'yxatdan o\'tishda xatolik yuz berdi'};
        } catch (_) {
          return {'success': false, 'message': response.body.isNotEmpty ? response.body : 'Ro\'yxatdan o\'tishda xatolik (Status: ${response.statusCode})'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> activateQR(String qrCode) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.post(
        Uri.parse('$baseUrl/v1/activate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'qrCode': qrCode}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'Xatolik yuz berdi'};
        } catch (_) {
          return {'success': false, 'message': 'QR kodni faollashtirishda xatolik'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> checkPublicQR(String qrCode) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/public/qr/$qrCode'),
      );
      if (response.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(response.body)};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'QR kod haqida ma\'lumot topilmadi'};
        } catch (_) {
          return {'success': false, 'message': 'QR kod topilmadi yoki yaroqsiz'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> getPurchaseHistory() async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.get(
        Uri.parse('$baseUrl/v1/purchase/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': _safeDecode(response.body)};
      } else {
        return {'success': false, 'message': 'Xaridlar tarixini yuklashda xatolik'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> getAllGifts({int page = 0, int size = 50}) async {
    try {
      final token = await getToken();
      // Sovg'alar ro'yxatini olish uchun token kerak bo'lsa
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/v1/purchase/gifts?page=$page&size=$size'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': _safeDecode(response.body)};
      } else {
        return {'success': false, 'message': "Sovg'alarni yuklashda xatolik"};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> purchaseGift(int giftId) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.post(
        Uri.parse('$baseUrl/v1/purchase/gift/$giftId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? "Sovg'ani xarid qilishda xatolik"};
        } catch (_) {
          return {'success': false, 'message': "Sovg'ani xarid qilishda xatolik"};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  // GET /api/v1/profile/transactions?page=0&size=20
  // Response: PageTransactionHistoryDto
  // TransactionHistoryDto: { type: "EARNED"|"SPENT", description: string, points: int, date: datetime }
  Future<Map<String, dynamic>> getTransactionHistory({int page = 0, int size = 20}) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.get(
        Uri.parse('$baseUrl/v1/profile/transactions?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = _safeDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'Tranzaksiyalar tarixini yuklashda xatolik'};
        } catch (_) {
          return {'success': false, 'message': 'Tranzaksiyalar tarixini yuklashda xatolik'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  // POST /api/v1/profile/image
  Future<Map<String, dynamic>> uploadProfileImage(String filePath) async {
    try {
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/v1/profile/image'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = _safeDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'Rasm yuklashda xatolik'};
        } catch (_) {
          return {'success': false, 'message': 'Rasm yuklashda xatolik'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }
}

