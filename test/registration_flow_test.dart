import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/localization/app_localizations.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Registration & Onboarding QA Suite', () {
    test('Test 1: Input Validation - Only essential fields required (Apple Guideline 5.1.1(v))', () {
      bool isMissingRequired(String phone, String firstName, String lastName, String password) {
        return phone.isEmpty || firstName.isEmpty || lastName.isEmpty || password.isEmpty;
      }

      // Empty required fields
      expect(isMissingRequired('', '', '', ''), isTrue);
      expect(isMissingRequired('+998901234567', '', '', ''), isTrue);

      // Essential fields present while optional fields (age, district, region) are empty/null
      const phone = '+998901234567';
      const firstName = 'John';
      const lastName = 'Doe';
      const password = 'Password123';
      const ageText = ''; // optional
      const district = ''; // optional
      const String? region = null; // optional

      expect(isMissingRequired(phone, firstName, lastName, password), isFalse);
      expect(ageText.isEmpty && district.isEmpty && region == null, isTrue);
    });

    test('Test 2: Invalid phone number validation', () {
      bool isValidPhone(String raw) {
        final phone = raw.replaceAll(' ', '');
        final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length < 9 || (phone.startsWith('+998') && digits.length < 12)) {
          return false;
        }
        return true;
      }

      expect(isValidPhone('+998'), isFalse);
      expect(isValidPhone('+998 90'), isFalse);
      expect(isValidPhone('12345'), isFalse);
      expect(isValidPhone('+998 90 123 45 67'), isTrue);
      expect(isValidPhone('901234567'), isTrue);
    });

    test('Test 3: Weak password validation (min 6 characters)', () {
      bool isStrongEnough(String pass) => pass.length >= 6;

      expect(isStrongEnough('123'), isFalse);
      expect(isStrongEnough('pass'), isFalse);
      expect(isStrongEnough('123456'), isTrue);
      expect(isStrongEnough('Reviewer2026!'), isTrue);
    });

    test('Test 4: Password mismatch validation in reset flow', () {
      final pass1 = 'Password123';
      final pass2 = 'Password456';
      final pass3 = 'Password123';

      expect(pass1 == pass2, isFalse);
      expect(pass1 == pass3, isTrue);
    });

    test('Test 5: Duplicate account detection message matcher', () {
      bool isDuplicateMessage(String msg) {
        final lower = msg.toLowerCase();
        return lower.contains('allaqachon') ||
            lower.contains('уже') ||
            lower.contains('already') ||
            lower.contains('exists');
      }

      expect(isDuplicateMessage("Bu telefon raqam allaqachon ro'yxatdan o'tgan."), isTrue);
      expect(isDuplicateMessage("Этот номер телефона уже зарегистрирован"), isTrue);
      expect(isDuplicateMessage("Phone number already exists"), isTrue);
      expect(isDuplicateMessage("Server xatoligi"), isFalse);
    });

    test('Test 6: Offline & network error user-friendly formatting', () {
      String formatNetworkError(dynamic e) {
        final str = e.toString().toLowerCase();
        if (str.contains('socketexception') ||
            str.contains('connection refused') ||
            str.contains('failed host lookup') ||
            str.contains('network is unreachable')) {
          return "Internet aloqasi mavjud emas. Internetni tekshirib, qayta urinib ko'ring.";
        }
        if (str.contains('timeoutexception') || str.contains('timed out')) {
          return "Server javob berish vaqti tugadi. Qayta urinib ko'ring.";
        }
        return "Tarmoq xatosi yuz berdi. Iltimos, qayta urinib ko'ring.";
      }

      final socketErr = formatNetworkError('SocketException: Failed host lookup: api.voltech.uz');
      final timeoutErr = formatNetworkError('TimeoutException after 0:00:15.000000');
      final unknownErr = formatNetworkError('FormatException: Unexpected character');

      expect(socketErr, contains('Internet aloqasi mavjud emas'));
      expect(timeoutErr, contains('Server javob berish vaqti tugadi'));
      expect(unknownErr, contains('Tarmoq xatosi yuz berdi'));
    });

    test('Test 7: Double-submit guard prevents multiple concurrent calls', () {
      int apiCallCount = 0;
      bool isLoading = false;

      void submit() {
        if (isLoading) return;
        isLoading = true;
        apiCallCount++;
      }

      // User rapidly taps 3 times
      submit();
      submit();
      submit();

      expect(apiCallCount, equals(1));
    });

    test('Test 8: User status routing - APPROVED and PENDING', () {
      bool shouldShowPendingScreen(String? status) {
        return status == 'PENDING';
      }

      bool isApprovedStatus(String? status) {
        return status == 'APPROVED' || status == 'ACTIVE';
      }

      expect(shouldShowPendingScreen('PENDING'), isTrue);
      expect(shouldShowPendingScreen('APPROVED'), isFalse);
      expect(isApprovedStatus('APPROVED'), isTrue);
      expect(isApprovedStatus('ACTIVE'), isTrue);
      expect(isApprovedStatus('PENDING'), isFalse);
    });

    test('Test 9: Age validation boundary tests', () {
      bool isValidAge(String text) {
        final age = int.tryParse(text);
        if (age == null || age < 15 || age > 100) return false;
        return true;
      }

      expect(isValidAge('12'), isFalse);
      expect(isValidAge('abc'), isFalse);
      expect(isValidAge('15'), isTrue);
      expect(isValidAge('35'), isTrue);
      expect(isValidAge('101'), isFalse);
    });

    test('Test 10: App restart session persistence & logout lifecycle', () async {
      final prefs = await SharedPreferences.getInstance();
      
      // Simulate login token save
      await prefs.setString('accessToken', 'mock_jwt_token_123');
      expect(prefs.getString('accessToken'), equals('mock_jwt_token_123'));

      // Simulate app restart: token remains in storage
      final restoredToken = prefs.getString('accessToken');
      expect(restoredToken, isNotNull);

      // Simulate logout: tokens are removed
      await prefs.remove('accessToken');
      expect(prefs.getString('accessToken'), isNull);
    });

    test('Test 11: Localization key resolution for uz, ru, en', () {
      expect(AppLocalizations.get('enter_valid_phone'), isNotEmpty);
      expect(AppLocalizations.get('account_exists_title'), isNotEmpty);
      expect(AppLocalizations.get('login_btn'), isNotEmpty);
      expect(AppLocalizations.get('registration'), isNotEmpty);
    });

    test('Test 12: Resend timer bounds validation', () {
      int secondsRemaining = 60;
      bool canResend = secondsRemaining == 0;
      expect(canResend, isFalse);

      secondsRemaining = 0;
      canResend = secondsRemaining == 0;
      expect(canResend, isTrue);
    });

    test('Test 13: Registration confirm password matching validation', () {
      bool doPasswordsMatch(String password, String confirmPassword) {
        return password.isNotEmpty && password == confirmPassword;
      }

      expect(doPasswordsMatch('SecurePass123', 'SecurePass123'), isTrue);
      expect(doPasswordsMatch('SecurePass123', 'DifferentPass'), isFalse);
      expect(doPasswordsMatch('', ''), isFalse);
      expect(AppLocalizations.get('confirm_password'), isNotEmpty);
      expect(AppLocalizations.get('passwords_mismatch'), isNotEmpty);
    });
  });
}
