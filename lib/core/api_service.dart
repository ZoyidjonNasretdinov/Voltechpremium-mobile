import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import '../main.dart';

class ApiService {
  static const String baseUrl = 'https://voltechpremiumbackend-api-production.up.railway.app/api';
  final _secureStorage = const FlutterSecureStorage();

  Future<String?> getToken() async => await _secureStorage.read(key: 'accessToken');
  Future<String?> getRefreshToken() async => await _secureStorage.read(key: 'refreshToken');

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _secureStorage.write(key: 'accessToken', value: accessToken);
    await _secureStorage.write(key: 'refreshToken', value: refreshToken);
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'accessToken', value: token);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    await _secureStorage.delete(key: 'token'); // for legacy compatibility
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

  Future<bool>? _refreshFuture;

  Future<bool> _refreshTokens() async {
    if (_refreshFuture != null) return await _refreshFuture!;
    _refreshFuture = _doRefresh();
    final result = await _refreshFuture!;
    _refreshFuture = null;
    return result;
  }

  Future<bool> _doRefresh() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['accessToken'] != null && data['refreshToken'] != null) {
          await saveTokens(data['accessToken'], data['refreshToken']);
          return true;
        }
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> _sendWithRetry(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = true,
  }) async {
    headers ??= {'Content-Type': 'application/json'};
    
    if (requiresAuth) {
      final token = await getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    http.Response response = await _sendInternal(method, url, headers: headers, body: body);

    if (requiresAuth && (response.statusCode == 401 || response.statusCode == 403)) {
      bool refreshed = await _refreshTokens();
      if (refreshed) {
        final newToken = await getToken();
        if (newToken != null) {
          headers['Authorization'] = 'Bearer $newToken';
        }
        response = await _sendInternal(method, url, headers: headers, body: body);
      } else {
        _handle401();
      }
    } else if (!requiresAuth && (response.statusCode == 401 || response.statusCode == 403)) {
       // Only strictly call _handle401 if it's 401 and was explicitly handling it before
       // Auth endpoints usually return 401/403 for bad credentials, we should pass it to the caller
       // but in original code, they called _handle401() for almost everything.
       // We'll let the caller handle it.
    }
    return response;
  }

  Future<http.Response> _sendInternal(String method, Uri url, {Map<String, String>? headers, Object? body}) async {
    switch (method) {
      case 'GET': return await http.get(url, headers: headers);
      case 'POST': return await http.post(url, headers: headers, body: body);
      case 'PUT': return await http.put(url, headers: headers, body: body);
      case 'DELETE': return await http.delete(url, headers: headers, body: body);
      default: throw UnimplementedError();
    }
  }

  void _saveAuthData(dynamic data) async {
    if (data is Map) {
      if (data['accessToken'] != null && data['refreshToken'] != null) {
        await saveTokens(data['accessToken'], data['refreshToken']);
      } else if (data['accessToken'] != null) {
        await saveToken(data['accessToken']);
      }
    }
  }

  Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await _sendWithRetry('POST', Uri.parse('$baseUrl/auth/login'), body: jsonEncode({
        'phoneNumber': phone,
        'password': password,
      }), requiresAuth: false);

      if (response.statusCode == 401 || response.statusCode == 403) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _safeDecode(response.body);
        _saveAuthData(data);
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
      final response = await _sendWithRetry('POST', Uri.parse('$baseUrl/auth/send-sms'), body: jsonEncode({'phoneNumber': phone}), requiresAuth: false);
      if (response.statusCode == 401 || response.statusCode == 403) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': _safeDecode(response.body)};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'SMS yuborishda xatolik'};
        } catch (_) {
          return {'success': false, 'message': 'SMS yuborishda xatolik'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> verifySms(String phone, String code) async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await _sendWithRetry('POST', Uri.parse('$baseUrl/auth/verify-sms'), body: jsonEncode({'phoneNumber': phone, 'verificationCode': code}), requiresAuth: false);
      if (response.statusCode == 401 || response.statusCode == 403) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _safeDecode(response.body);
        _saveAuthData(data);
        return {'success': true, 'data': data};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'Noto\'g\'ri kod'};
        } catch (_) {
          return {'success': false, 'message': 'Noto\'g\'ri kod'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPasswordSendSms(String phone) async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await _sendWithRetry('POST', Uri.parse('$baseUrl/auth/forgot-password/send-sms'), body: jsonEncode({'phoneNumber': phone}), requiresAuth: false);
      if (response.statusCode == 401 || response.statusCode == 403) {
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
      final response = await _sendWithRetry('POST', Uri.parse('$baseUrl/auth/forgot-password/reset'), body: jsonEncode({'phoneNumber': phone, 'verificationCode': code, 'newPassword': newPassword}), requiresAuth: false);
      if (response.statusCode == 401 || response.statusCode == 403) {
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
      final response = await _sendWithRetry('GET', Uri.parse('$baseUrl/v1/profile'), requiresAuth: true);
      
      if (response.statusCode == 401 || response.statusCode == 403) return {"success": false, "message": "Sessiya tugadi"};

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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await _sendWithRetry('PUT', Uri.parse('$baseUrl/v1/profile'), body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'region': region,
        'district': district,
      }), requiresAuth: true);
      
      if (response.statusCode == 401 || response.statusCode == 403) return {"success": false, "message": "Sessiya tugadi"};

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
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await _sendWithRetry('POST', Uri.parse('$baseUrl/auth/register'), body: jsonEncode({
        'phoneNumber': phone,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'region': region,
        'district': district,
      }), requiresAuth: false);

      if (response.statusCode == 401 || response.statusCode == 403) {
        _handle401();
        return {"success": false, "message": "Sessiya tugadi"};
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = _safeDecode(response.body);
        _saveAuthData(data);
        return {'success': true, 'data': data};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {'success': false, 'message': errorData['message'] ?? 'Ro\'yxatdan o\'tishda xatolik yuz berdi'};
        } catch (_) {
          return {'success': false, 'message': 'Ro\'yxatdan o\'tishda xatolik yuz berdi'};
        }
      }
    } catch (e) {
      return {'success': false, 'message': 'Tarmoq xatosi: $e'};
    }
  }

  Future<Map<String, dynamic>> submitComplaint(String qrCode, String message) async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await _sendWithRetry('POST', Uri.parse('$baseUrl/v1/complaints'), body: jsonEncode({
        'qrCode': qrCode,
        'message': message,
      }), requiresAuth: true);

      if (response.statusCode == 401 || response.statusCode == 403) return {"success": false, "message": "Sessiya tugadi"};

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
      final response = await _sendWithRetry('POST', Uri.parse('$baseUrl/v1/activate'), body: jsonEncode({'qrCode': qrCode}), requiresAuth: true);
      
      if (response.statusCode == 401 || response.statusCode == 403) return {"success": false, "message": "Sessiya tugadi"};

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'success': false, 
            'message': errorData['message'] ?? 'Xatolik yuz berdi',
            'scannedBySelf': errorData['scannedBySelf']
          };
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
      final response = await _sendWithRetry('GET', Uri.parse('$baseUrl/public/qr/$qrCode'), requiresAuth: false);
      
      if (response.statusCode == 401 || response.statusCode == 403) {
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
      final response = await _sendWithRetry('GET', Uri.parse('$baseUrl/v1/purchase/history'), requiresAuth: true);
      
      if (response.statusCode == 401 || response.statusCode == 403) return {"success": false, "message": "Sessiya tugadi"};

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
      final response = await _sendWithRetry('GET', Uri.parse('$baseUrl/v1/purchase/gifts?page=$page&size=$size'), requiresAuth: true);
      
      if (response.statusCode == 401 || response.statusCode == 403) return {"success": false, "message": "Sessiya tugadi"};

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
      final response = await _sendWithRetry('POST', Uri.parse('$baseUrl/v1/purchase/gift/$giftId'), requiresAuth: true);
      
      if (response.statusCode == 401 || response.statusCode == 403) return {"success": false, "message": "Sessiya tugadi"};

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

  Future<Map<String, dynamic>> getTransactionHistory({int page = 0, int size = 20}) async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await _sendWithRetry('GET', Uri.parse('$baseUrl/v1/profile/transactions?page=$page&size=$size'), requiresAuth: true);
      
      if (response.statusCode == 401 || response.statusCode == 403) return {"success": false, "message": "Sessiya tugadi"};

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

  Future<Map<String, dynamic>> uploadProfileImage(String filePath) async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      var token = await getToken();
      if (token == null) return {'success': false, 'message': 'Token topilmadi'};

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/v1/profile/image'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401 || response.statusCode == 403) {
        bool refreshed = await _refreshTokens();
        if (refreshed) {
          token = await getToken();
          var newRequest = http.MultipartRequest('POST', Uri.parse('$baseUrl/v1/profile/image'));
          newRequest.headers['Authorization'] = 'Bearer $token!';
          newRequest.files.add(await http.MultipartFile.fromPath('file', filePath));
          streamedResponse = await newRequest.send();
          response = await http.Response.fromStream(streamedResponse);
        } else {
          _handle401();
          return {"success": false, "message": "Sessiya tugadi"};
        }
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

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await _sendWithRetry('DELETE', Uri.parse('$baseUrl/v1/profile'), requiresAuth: true);

      if (response.statusCode == 401 || response.statusCode == 403) return {"success": false, "message": "Sessiya tugadi"};

      if (response.statusCode == 200 || response.statusCode == 204) {
        await logout(); 
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
  }

  Future<Map<String, dynamic>> getAdminPhoneNumbers() async {
    try {
      if (!await _hasConnection()) return {"success": false, "message": "Internet tarmog'iga ulaning"};
      final response = await _sendWithRetry('GET', Uri.parse('$baseUrl/v1/admin/phone-numbers'), requiresAuth: true);

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
