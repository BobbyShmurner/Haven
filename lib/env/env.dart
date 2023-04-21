import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'MAPS_API_KEY', obfuscate: true)
  static final mapsApiKey = _Env.mapsApiKey;
}
