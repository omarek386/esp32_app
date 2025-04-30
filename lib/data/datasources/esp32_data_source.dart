import 'package:http/http.dart' as http;

/// Data source for communicating with the ESP32
abstract class ESP32DataSource {
  /// Sends a string of pin states ('1's and '0's) to the ESP32
  ///
  /// [pinStateString] - String of '1's and '0's representing pin states
  /// [ipAddress] - IP address of the ESP32
  ///
  /// Returns true if successful, false otherwise
  Future<bool> sendPinStates(String pinStateString, String ipAddress);
}

/// HTTP implementation of the ESP32DataSource
class ESP32DataSourceImpl implements ESP32DataSource {
  final http.Client client;
  final String updatePath;

  ESP32DataSourceImpl({required this.client, this.updatePath = '/update'});

  @override
  Future<bool> sendPinStates(String pinStateString, String ipAddress) async {
    if (ipAddress.isEmpty) {
      return false;
    }

    final url = Uri.http(ipAddress, updatePath);

    try {
      final response = await client
          .post(
            url,
            headers: {'Content-Type': 'text/plain'},
            body: pinStateString,
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
