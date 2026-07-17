import 'package:flutter_test/flutter_test.dart';
import 'package:uniget_app/flavors/flavor_config.dart';

void main() {
  test('FlavorConfig.instance reflects the initialized flavor', () {
    FlavorConfig.initialize(const FlavorConfig(flavor: Flavor.dev, appTitle: 'UNIGET (Dev)'));
    expect(FlavorConfig.instance.flavor, Flavor.dev);
    expect(FlavorConfig.instance.appTitle, 'UNIGET (Dev)');
  });
}
