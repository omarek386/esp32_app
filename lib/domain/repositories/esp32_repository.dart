import 'package:esp32_app/domain/entities/pin_state.dart';

/// Repository interface for ESP32 operations
abstract class ESP32Repository {
  /// Sends pin states to the ESP32 device
  ///
  /// [pinStates] - List of pin states to send
  /// [ipAddress] - IP address of the ESP32 device
  ///
  /// Returns true if successful, false otherwise
  Future<bool> sendPinStates(List<PinState> pinStates, String ipAddress);

  /// Gets the current states of input pins from the ESP32 device
  ///
  /// [ipAddress] - IP address of the ESP32 device
  ///
  /// Returns a list of input pin states if successful, null otherwise
  Future<List<PinState>?> getInputPinStates(String ipAddress);
}
