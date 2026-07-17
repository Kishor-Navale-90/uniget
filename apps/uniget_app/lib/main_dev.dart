import 'bootstrap.dart';
import 'flavors/flavor_config.dart';

Future<void> main() async {
  FlavorConfig.initialize(const FlavorConfig(flavor: Flavor.dev, appTitle: 'UNIGET (Dev)'));
  await bootstrap();
}
