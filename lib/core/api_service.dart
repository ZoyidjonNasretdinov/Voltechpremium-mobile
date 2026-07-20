import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class ApiService {
  static const String baseUrl = 'https://voltechpremiumbackend-api-production.up.railway.app/api';
  final _secureStorage = const FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'token');
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'token', value: token);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'token');
  }

  Future<bool> _hasConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) return false;
      return true;
    } catch (_) { return true; }
  }

  void _handle401() async {
    await logout();
    if (navigatorKey.currentContext != null) {
      Navigator.of(navigatorKey.currentContext!).pushNamedAndRemoveUntil('/login', (route) => false);
    }
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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phoneNumber': phone,
          'password': password,
        }),
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await http.post(
        Uri.parse('$baseUrl/auth/send-sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone}),
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }
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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'verificationCode': code}),
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }
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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/send-sms'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone}),
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }
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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password/reset'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phoneNumber': phone, 'verificationCode': code, 'newPassword': newPassword}),
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }
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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.get(
        Uri.parse('$baseUrl/v1/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

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
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

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
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

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

  Future<Map<String, dynamic>> submitComplaint(String qrCode, String message) async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.post(
        Uri.parse('$baseUrl/v1/complaints'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'qrCode': qrCode,
          'message': message,
        }),
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Shikoyat yuborildi'};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'Shikoyat yuborishda xatolik'};
        } catch (_) {
          return {'success': false, 'message': 'Shikoyat yuborishda xatolik (Status: ${response.statusCode})'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> activateQR(String qrCode) async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
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
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await http.get(
        Uri.parse('$baseUrl/public/qr/$qrCode'),
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }
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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.get(
        Uri.parse('$baseUrl/v1/purchase/history'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
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
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.post(
        Uri.parse('$baseUrl/v1/purchase/gift/$giftId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.get(
        Uri.parse('$baseUrl/v1/profile/transactions?page=$page&size=$size'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/v1/profile/image'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

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

  // DELETE /api/v1/profile
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      final response = await http.delete(
        Uri.parse('$baseUrl/v1/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        await logout(); // Delete token after account is deleted
        return {'success': true, 'message': 'Hisobingiz muvaffaqiyatli o\'chirildi'};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'Hisobni o\'chirishda xatolik'};
        } catch (_) {
          return {'success': false, 'message': 'Hisobni o\'chirishda xatolik'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  // GET /api/v1/admin/phone-numbers
  Future<Map<String, dynamic>> getAdminPhoneNumbers() async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      // We may or may not need a token depending on if it's public. Let's send it just in case.
      final token = await getToken();
      final headers = {'Content-Type': 'application/json'};
      if (token != null) headers['Authorization'] = 'Bearer $token';

      final response = await http.get(
        Uri.parse('$baseUrl/v1/admin/phone-numbers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = _safeDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Raqamlarni yuklashda xatolik'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }
}
