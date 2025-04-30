import 'package:esp32_app/domain/entities/pin_state.dart';
import 'package:esp32_app/domain/repositories/esp32_repository.dart';

/// Use case for sending pin states to an ESP32 device
class SendPinStatesUseCase {
  final ESP32Repository repository;

  SendPinStatesUseCase(this.repository);

  /// Execute the use case to send pin states to the ESP32
  ///
  /// [pinStates] - The list of pin states to send
  /// [ipAddress] - The IP address of the ESP32
  ///
  /// Returns true if successful, false otherwise
  Future<bool> execute(List<PinState> pinStates, String ipAddress) {
    return repository.sendPinStates(pinStates, ipAddress);
  }
}
