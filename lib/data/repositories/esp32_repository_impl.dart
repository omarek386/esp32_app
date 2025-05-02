import 'package:esp32_app/data/datasources/esp32_data_source.dart';
import 'package:esp32_app/domain/entities/pin_state.dart';
import 'package:esp32_app/domain/repositories/esp32_repository.dart';

/// Implementation of ESP32Repository
class ESP32RepositoryImpl implements ESP32Repository {
  final ESP32DataSource dataSource;

  ESP32RepositoryImpl(this.dataSource);

  @override
  Future<bool> sendPinStates(List<PinState> pinStates, String ipAddress) async {
    // Convert the list of PinState entities to a string of '1's and '0's
    final String pinStateString = pinStates
        .map((state) => state.isOn ? '1' : '0')
        .join('');

    // Call the data source to send the pin states
    return dataSource.sendPinStates(pinStateString, ipAddress);
  }

  @override
  Future<List<PinState>?> getInputPinStates(String ipAddress) async {
    // Call the data source to get the input pin states
    final String? pinStateString = await dataSource.getInputPinStates(
      ipAddress,
    );

    if (pinStateString == null) {
      return null;
    }

    // Convert the string of '1's and '0's to a list of PinState entities
    // The string format is e.g., "10110" where each character represents a pin state
    final List<PinState> pinStates = [];
    for (int i = 0; i < pinStateString.length; i++) {
      pinStates.add(
        PinState(
          pinNumber: i + 1, // Input pins are 1-indexed for user display
          isOn: pinStateString[i] == '1',
        ),
      );
    }

    return pinStates;
  }
}
