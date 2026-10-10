import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/api_service.dart';

void main() {
  group('ApiService.resolveImageUrl tests', () {
    test('null and empty paths return null', () {
      expect(ApiService.resolveImageUrl(null), isNull);
      expect(ApiService.resolveImageUrl(''), isNull);
      expect(ApiService.resolveImageUrl('   '), isNull);
    });

    test('Google Cloud Storage URL is redirected through backend proxy', () {
      const gcsUrl =
          'https://storage.googleapis.com/moreeduce/0c1c630f-4477-444d-8264-5abbdb496437-ingco_shrupavyort_1791655342776.jpg';
      final resolved = ApiService.resolveImageUrl(gcsUrl);

      expect(resolved, isNotNull);
      expect(
        resolved,
        '${ApiService.baseUrl}/files/download/0c1c630f-4477-444d-8264-5abbdb496437-ingco_shrupavyort_1791655342776.jpg',
      );
    });

    test('GCS URL with query params extracts clean filename', () {
      const gcsUrlWithParams =
          'https://storage.googleapis.com/moreeduce/ef37d185-3d23-4eb0.jpg?alt=media&token=123';
      final resolved = ApiService.resolveImageUrl(gcsUrlWithParams);

      expect(resolved, isNotNull);
      expect(
        resolved,
        '${ApiService.baseUrl}/files/download/ef37d185-3d23-4eb0.jpg',
      );
    });

    test('Relative filename is directed to backend download proxy', () {
      const relative = 'avatar_user_123.jpg';
      final resolved = ApiService.resolveImageUrl(relative);

      expect(resolved, isNotNull);
      expect(
        resolved,
        '${ApiService.baseUrl}/files/download/avatar_user_123.jpg',
      );
    });

    test('External non-GCS URL is left unchanged', () {
      const externalUrl = 'https://images.unsplash.com/photo-1542291026';
      final resolved = ApiService.resolveImageUrl(externalUrl);

      expect(resolved, externalUrl);
    });
  });
}
