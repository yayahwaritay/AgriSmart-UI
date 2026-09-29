import 'package:agrismart/core/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiException.fromResponseBody', () {
    test('old { "message" } shape still works, with no errors', () {
      final e = ApiException.fromResponseBody(404, '{"message": "Crop not found."}');
      expect(e.message, 'Crop not found.');
      expect(e.statusCode, 404);
      expect(e.errors, isEmpty);
      expect(e.toString(), 'Crop not found.');
    });

    test('the positional constructor is unchanged for existing callers', () {
      const e = ApiException('Nope', 400);
      expect(e.message, 'Nope');
      expect(e.errors, isEmpty);
    });

    test('parses field errors keyed by request path', () {
      final e = ApiException.fromResponseBody(400, '''
        {
          "message": "Validation failed: area must be greater than 0.",
          "errors": {
            "area": ["area must be greater than 0."],
            "soil.fertility": ["fertility is required in simple mode.", "second"],
            "customPrices[0].pricePerBag": ["pricePerBag must be 0 or more."]
          }
        }
      ''');
      expect(e.message, 'Validation failed: area must be greater than 0.');
      expect(e.errors['area'], ['area must be greater than 0.']);
      expect(e.errors['soil.fertility'], hasLength(2));
      expect(e.errors['customPrices[0].pricePerBag'], ['pricePerBag must be 0 or more.']);
    });

    test('ASP.NET ValidationProblemDetails falls back to title', () {
      final e = ApiException.fromResponseBody(400, '''
        {
          "type": "https://tools.ietf.org/html/rfc9110#section-15.5.1",
          "title": "One or more validation errors occurred.",
          "status": 400,
          "errors": { "\$.areaUnit": ["The JSON value could not be converted."] }
        }
      ''');
      expect(e.message, 'One or more validation errors occurred.');
      expect(e.errors.keys, ['\$.areaUnit']);
    });

    test('non-JSON or empty bodies use the generic message', () {
      expect(ApiException.fromResponseBody(401, '').message, 'Something went wrong (401).');
      expect(ApiException.fromResponseBody(500, '<html>').message, 'Something went wrong (500).');
      expect(ApiException.fromResponseBody(500, '<html>').errors, isEmpty);
    });

    test('ignores a malformed errors value', () {
      final e = ApiException.fromResponseBody(400, '{"message": "x", "errors": ["not", "a", "map"]}');
      expect(e.errors, isEmpty);
    });
  });
}
