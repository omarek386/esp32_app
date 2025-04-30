// import 'package:esp32_app/data/datasources/esp32_data_source.dart';
// import 'package:esp32_app/data/repositories/esp32_repository_impl.dart';
// import 'package:esp32_app/domain/entities/pin_state.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';

// @GenerateMocks([ESP32DataSource])
// void main() {
//   late ESP32RepositoryImpl repository;
//   late MockESP32DataSource mockDataSource;

//   setUp(() {
//     mockDataSource = MockESP32DataSource();
//     repository = ESP32RepositoryImpl(mockDataSource);
//   });

//   final testPinStates = [
//     PinState(pinNumber: 1, isOn: true),
//     PinState(pinNumber: 2, isOn: false),
//     PinState(pinNumber: 3, isOn: true),
//   ];
//   const testIpAddress = '192.168.1.100';
//   const testPinStateString = '101'; // Represents [true, false, true]

//   test('should convert pin states to string and call data source', () async {
//     // arrange
//     when(
//       mockDataSource.sendPinStates(testPinStateString, testIpAddress),
//     ).thenAnswer((_) async => true);

//     // act
//     final result = await repository.sendPinStates(testPinStates, testIpAddress);

//     // assert
//     expect(result, true);
//     verify(mockDataSource.sendPinStates(testPinStateString, testIpAddress));
//     verifyNoMoreInteractions(mockDataSource);
//   });
// }
