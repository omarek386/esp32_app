import 'dart:async';
import 'package:flutter/material.dart';
import 'package:esp32_app/domain/entities/pin_state.dart';
import 'package:esp32_app/domain/usecases/send_pin_states.dart';

/// Pin controller state
enum PinControlState { idle, sending, success, error }

/// Controller for managing pin states and communication with ESP32
class PinController extends ChangeNotifier {
  final SendPinStatesUseCase _sendPinStatesUseCase;

  // State variables
  final List<PinState> _pinStates;
  String _ipAddress;
  PinControlState _state = PinControlState.idle;
  String _statusMessage = '';
  Timer? _debounce;

  // Getters
  List<PinState> get pinStates => List.unmodifiable(_pinStates);
  String get ipAddress => _ipAddress;
  PinControlState get state => _state;
  String get statusMessage => _statusMessage;
  bool get isSending => _state == PinControlState.sending;

  PinController({
    required SendPinStatesUseCase sendPinStatesUseCase,
    required String initialIpAddress,
    required int numberOfPins,
  }) : _sendPinStatesUseCase = sendPinStatesUseCase,
       _ipAddress = initialIpAddress,
       _pinStates = List.generate(
         numberOfPins,
         (index) => PinState(pinNumber: index + 1, isOn: false),
       );

  /// Update the IP address
  void updateIpAddress(String ipAddress) {
    _ipAddress = ipAddress;
    notifyListeners();
  }

  /// Toggle the state of a pin
  void togglePin(int index) {
    if (index >= 0 && index < _pinStates.length) {
      final currentState = _pinStates[index];
      _pinStates[index] = PinState(
        pinNumber: currentState.pinNumber,
        isOn: !currentState.isOn,
      );
      notifyListeners();

      // Debounce sending
      _debounceAndSend();
    }
  }

  /// Send the current pin states
  Future<void> sendPinStates() async {
    if (_state == PinControlState.sending) return;

    _state = PinControlState.sending;
    _statusMessage = 'Sending data...';
    notifyListeners();

    try {
      final result = await _sendPinStatesUseCase.execute(
        _pinStates,
        _ipAddress,
      );

      if (result) {
        _state = PinControlState.success;
        _statusMessage =
            'Data sent successfully! (${DateTime.now().toIso8601String().substring(11, 19)})';
      } else {
        _state = PinControlState.error;
        _statusMessage = 'Error: Failed to send data to ESP32.';
      }
    } catch (e) {
      _state = PinControlState.error;
      _statusMessage = 'Error sending data: $e';
    }

    notifyListeners();

    // Reset state after a delay
    Timer(const Duration(seconds: 5), () {
      if (_state != PinControlState.sending) {
        _state = PinControlState.idle;
        notifyListeners();
      }
    });
  }

  /// Debounce and send data
  void _debounceAndSend() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), sendPinStates);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
