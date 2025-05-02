import 'package:esp32_app/domain/entities/pin_state.dart';
import 'package:esp32_app/domain/repositories/esp32_repository.dart';

/// Use case for getting input pin states from an ESP32 device
class GetInputPinStatesUseCase {
  final ESP32Repository repository;

  GetInputPinStatesUseCase(this.repository);

  /// Execute the use case to get input pin states from the ESP32
  ///
  /// [ipAddress] - The IP address of the ESP32
  ///
  /// Returns a list of pin states if successful, null otherwise
  Future<List<PinState>?> execute(String ipAddress) {
    return repository.getInputPinStates(ipAddress);
  }
}
