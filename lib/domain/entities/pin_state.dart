/// Entity representing the state of an ESP32 pin
class PinState {
  final int pinNumber;
  final bool isOn;

  PinState({required this.pinNumber, required this.isOn});

  PinState copyWith({int? pinNumber, bool? isOn}) {
    return PinState(
      pinNumber: pinNumber ?? this.pinNumber,
      isOn: isOn ?? this.isOn,
    );
  }
}
