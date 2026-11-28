import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/core/utils/property_links.dart';

void main() {
  test('builds custom-scheme property links', () {
    expect(propertyAppUri('abc').toString(), 'yemenreal://property/abc');
    expect(propertyShareUrl('abc'), 'yemenreal://property/abc');
  });

  test('builds web property links from an explicit origin', () {
    expect(propertyPath('a/b'), '/property/a%2Fb');
    expect(
      propertyShareUrl('a b', webOrigin: 'https://example.com/app/'),
      'https://example.com/property/a%20b',
    );
  });

  test('parses custom-scheme and web property links', () {
    expect(
      propertyIdFromLink(Uri.parse('yemenreal://property/abc')),
      'abc',
    );
    expect(
      propertyIdFromLink(Uri.parse('yemenreal:///property/abc')),
      'abc',
    );
    expect(
      propertyIdFromLink(
        Uri.parse('https://example.com/property/abc?ref=share'),
      ),
      'abc',
    );
    expect(
      propertyIdFromLink(Uri.parse('yemenreal://property/?id=abc')),
      'abc',
    );
  });

  test('ignores auth callbacks and unrelated links', () {
    expect(
      propertyIdFromLink(
        Uri.parse('yemenreal://login-callback#access_token=token'),
      ),
      isNull,
    );
    expect(
      propertyIdFromLink(Uri.parse('https://example.com/about')),
      isNull,
    );
  });
}
