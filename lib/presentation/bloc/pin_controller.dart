import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:esp32_app/domain/entities/pin_state.dart';
import 'package:esp32_app/domain/usecases/send_pin_states.dart';

/// Pin controller state type
enum PinControlStatus { idle, sending, success, error }

/// State class for PinCubit
class PinCubitState extends Equatable {
  final List<PinState> pinStates;
  final String ipAddress;
  final PinControlStatus status;
  final String statusMessage;

  const PinCubitState({
    required this.pinStates,
    required this.ipAddress,
    required this.status,
    required this.statusMessage,
  });

  // Create initial state
  factory PinCubitState.initial({
    required String initialIpAddress,
    required int numberOfPins,
  }) {
    return PinCubitState(
      pinStates: List.generate(
        numberOfPins,
        (index) => PinState(pinNumber: index + 1, isOn: false),
      ),
      ipAddress: initialIpAddress,
      status: PinControlStatus.idle,
      statusMessage: '',
    );
  }

  // Create a copy of the state with new values
  PinCubitState copyWith({
    List<PinState>? pinStates,
    String? ipAddress,
    PinControlStatus? status,
    String? statusMessage,
  }) {
    return PinCubitState(
      pinStates: pinStates ?? this.pinStates,
      ipAddress: ipAddress ?? this.ipAddress,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [pinStates, ipAddress, status, statusMessage];

  bool get isSending => status == PinControlStatus.sending;
}

/// Cubit for managing pin states and communication with ESP32
class PinCubit extends Cubit<PinCubitState> {
  final SendPinStatesUseCase _sendPinStatesUseCase;
  Timer? _debounce;
  Timer? _resetStateTimer;

  PinCubit({
    required SendPinStatesUseCase sendPinStatesUseCase,
    required String initialIpAddress,
    required int numberOfPins,
  }) : _sendPinStatesUseCase = sendPinStatesUseCase,
       super(
         PinCubitState.initial(
           initialIpAddress: initialIpAddress,
           numberOfPins: numberOfPins,
         ),
       );

  /// Update the IP address
  void updateIpAddress(String ipAddress) {
    emit(state.copyWith(ipAddress: ipAddress));
  }

  /// Toggle the state of a pin
  void togglePin(int index) {
    if (index >= 0 && index < state.pinStates.length) {
      final updatedPinStates = List<PinState>.from(state.pinStates);
      final currentState = updatedPinStates[index];
      updatedPinStates[index] = PinState(
        pinNumber: currentState.pinNumber,
        isOn: !currentState.isOn,
      );

      emit(state.copyWith(pinStates: updatedPinStates));

      // Debounce sending
      _debounceAndSend();
    }
  }

  /// Send the current pin states
  Future<void> sendPinStates() async {
    if (state.status == PinControlStatus.sending) return;

    emit(
      state.copyWith(
        status: PinControlStatus.sending,
        statusMessage: 'Sending data...',
      ),
    );

    try {
      final result = await _sendPinStatesUseCase.execute(
        state.pinStates,
        state.ipAddress,
      );

      if (result) {
        emit(
          state.copyWith(
            status: PinControlStatus.success,
            statusMessage:
                'Data sent successfully! (${DateTime.now().toIso8601String().substring(11, 19)})',
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: PinControlStatus.error,
            statusMessage: 'Error: Failed to send data to ESP32.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: PinControlStatus.error,
          statusMessage: 'Error sending data: $e',
        ),
      );
    }

    // Reset state after a delay
    _resetStateTimer?.cancel();
    _resetStateTimer = Timer(const Duration(seconds: 5), () {
      if (state.status != PinControlStatus.sending) {
        emit(state.copyWith(status: PinControlStatus.idle));
      }
    });
  }

  /// Debounce and send data
  void _debounceAndSend() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), sendPinStates);
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    _resetStateTimer?.cancel();
    return super.close();
  }
}
