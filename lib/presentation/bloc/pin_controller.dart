import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:esp32_app/domain/entities/pin_state.dart';
import 'package:esp32_app/domain/usecases/send_pin_states.dart';
import 'package:esp32_app/domain/usecases/get_input_pin_states.dart';

/// Pin controller state type
enum PinControlStatus { idle, sending, loading, success, error }

/// State class for PinCubit
class PinCubitState extends Equatable {
  final List<PinState> outputPinStates;
  final List<PinState> inputPinStates;
  final String ipAddress;
  final PinControlStatus status;
  final String statusMessage;

  const PinCubitState({
    required this.outputPinStates,
    required this.inputPinStates,
    required this.ipAddress,
    required this.status,
    required this.statusMessage,
  });

  // Create initial state
  factory PinCubitState.initial({
    required String initialIpAddress,
    required int numberOfOutputPins,
    required int numberOfInputPins,
  }) {
    return PinCubitState(
      outputPinStates: List.generate(
        numberOfOutputPins,
        (index) => PinState(pinNumber: index + 1, isOn: false),
      ),
      inputPinStates: List.generate(
        numberOfInputPins,
        (index) => PinState(pinNumber: index + 1, isOn: false),
      ),
      ipAddress: initialIpAddress,
      status: PinControlStatus.idle,
      statusMessage: '',
    );
  }

  // Create a copy of the state with new values
  PinCubitState copyWith({
    List<PinState>? outputPinStates,
    List<PinState>? inputPinStates,
    String? ipAddress,
    PinControlStatus? status,
    String? statusMessage,
  }) {
    return PinCubitState(
      outputPinStates: outputPinStates ?? this.outputPinStates,
      inputPinStates: inputPinStates ?? this.inputPinStates,
      ipAddress: ipAddress ?? this.ipAddress,
      status: status ?? this.status,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [
    outputPinStates,
    inputPinStates,
    ipAddress,
    status,
    statusMessage,
  ];

  bool get isSending => status == PinControlStatus.sending;
  bool get isLoading => status == PinControlStatus.loading;
}

/// Cubit for managing pin states and communication with ESP32
class PinCubit extends Cubit<PinCubitState> {
  final SendPinStatesUseCase _sendPinStatesUseCase;
  final GetInputPinStatesUseCase _getInputPinStatesUseCase;
  Timer? _debounce;
  Timer? _resetStateTimer;
  Timer? _inputPollingTimer;

  PinCubit({
    required SendPinStatesUseCase sendPinStatesUseCase,
    required GetInputPinStatesUseCase getInputPinStatesUseCase,
    required String initialIpAddress,
    required int numberOfOutputPins,
    required int numberOfInputPins,
  }) : _sendPinStatesUseCase = sendPinStatesUseCase,
       _getInputPinStatesUseCase = getInputPinStatesUseCase,
       super(
         PinCubitState.initial(
           initialIpAddress: initialIpAddress,
           numberOfOutputPins: numberOfOutputPins,
           numberOfInputPins: numberOfInputPins,
         ),
       ) {
    // Start polling for input pin states
    startInputPolling();
  }

  /// Update the IP address
  void updateIpAddress(String ipAddress) {
    emit(state.copyWith(ipAddress: ipAddress));

    // Restart polling with new IP address
    restartInputPolling();
  }

  /// Toggle the state of an output pin
  void togglePin(int index) {
    if (index >= 0 && index < state.outputPinStates.length) {
      final updatedPinStates = List<PinState>.from(state.outputPinStates);
      final currentState = updatedPinStates[index];
      updatedPinStates[index] = PinState(
        pinNumber: currentState.pinNumber,
        isOn: !currentState.isOn,
      );

      emit(state.copyWith(outputPinStates: updatedPinStates));

      // Debounce sending
      _debounceAndSend();
    }
  }

  /// Send the current output pin states
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
        state.outputPinStates,
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

  /// Start polling for input pin states
  void startInputPolling() {
    stopInputPolling();
    _inputPollingTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => fetchInputPinStates(),
    );
  }

  /// Stop polling for input pin states
  void stopInputPolling() {
    _inputPollingTimer?.cancel();
    _inputPollingTimer = null;
  }

  /// Restart input polling (e.g., after IP address change)
  void restartInputPolling() {
    stopInputPolling();
    startInputPolling();
  }

  /// Fetch input pin states from the ESP32
  Future<void> fetchInputPinStates() async {
    try {
      final inputStates = await _getInputPinStatesUseCase.execute(
        state.ipAddress,
      );
      if (inputStates != null) {
        emit(
          state.copyWith(
            inputPinStates: inputStates,
            // Don't change the status if we're sending data or showing an error
            status:
                state.status == PinControlStatus.idle
                    ? PinControlStatus.idle
                    : state.status,
          ),
        );
      }
    } catch (e) {
      // Don't show errors for polling - they'll be too frequent and disruptive
      // Just leave the existing input states as they are
    }
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
    stopInputPolling();
    return super.close();
  }
}
