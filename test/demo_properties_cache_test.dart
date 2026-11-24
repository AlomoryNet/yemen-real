import 'package:flutter_test/flutter_test.dart';
import 'package:yemen_real_estate_portal/data/demo_properties_generator.dart';

void main() {
  test('cachedDemoProperties reuses one 440-property snapshot', () {
    final first = DemoPropertiesGenerator.cachedDemoProperties;
    final second = DemoPropertiesGenerator.cachedDemoProperties;

    expect(first, same(second));
    expect(first, hasLength(440));
  });
}
