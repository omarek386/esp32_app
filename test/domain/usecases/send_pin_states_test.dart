// import 'package:esp32_app/domain/entities/pin_state.dart';
// import 'package:esp32_app/domain/repositories/esp32_repository.dart';
// import 'package:esp32_app/domain/usecases/send_pin_states.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';

// import 'send_pin_states_test.mocks.dart';

// @GenerateMocks([ESP32Repository])
// void main() {
//   late SendPinStatesUseCase usecase;
//   late MockESP32Repository mockRepository;

//   setUp(() {
//     mockRepository = MockESP32Repository();
//     usecase = SendPinStatesUseCase(mockRepository);
//   });

//   final testPinStates = [
//     PinState(pinNumber: 1, isOn: true),
//     PinState(pinNumber: 2, isOn: false),
//   ];
//   const testIpAddress = '192.168.1.100';

//   test('should send pin states to the repository', () async {
//     // arrange
//     when(
//       mockRepository.sendPinStates(testPinStates, testIpAddress),
//     ).thenAnswer((_) async => true);

//     // act
//     final result = await usecase.execute(testPinStates, testIpAddress);

//     // assert
//     expect(result, true);
//     verify(mockRepository.sendPinStates(testPinStates, testIpAddress));
//     verifyNoMoreInteractions(mockRepository);
//   });
// }
