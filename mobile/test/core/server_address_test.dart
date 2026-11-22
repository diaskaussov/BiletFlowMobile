import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/config/server_address.dart';

void main() {
  test('server address is normalized', () {
    expect(ServerAddress.normalize('10.70.62.248'), 'http://10.70.62.248:8080');
    expect(ServerAddress.normalize(' 10.70.62.248:9000 '), 'http://10.70.62.248:9000');
    expect(ServerAddress.normalize('http://192.168.1.10:8080/'), 'http://192.168.1.10:8080');
    expect(ServerAddress.normalize('https://api.biletflow.kz'), 'https://api.biletflow.kz');
    expect(ServerAddress.normalize(''), isNull);
    expect(ServerAddress.normalize('ftp://x'), isNull);
  });
}
