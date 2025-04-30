import 'package:esp32_app/data/datasources/esp32_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([http.Client])
void main() {
  late ESP32DataSourceImpl dataSource;
  late MockClient mockHttpClient;
  const updatePath = '/update';

  setUp(() {
    mockHttpClient = MockClient((request) async {
      return http.Response('OK', 200);
    });
    dataSource = ESP32DataSourceImpl(
      client: mockHttpClient,
      updatePath: updatePath,
    );
  });

  const testPinStateString = '10110';
  const testIpAddress = '192.168.1.100';

  test(
    'should send pin state string to ESP32 and return true when successful',
    () async {
      // arrange
      final url = Uri.http(testIpAddress, updatePath);
      when(
        mockHttpClient.post(
          url,
          headers: {'Content-Type': 'text/plain'},
          body: testPinStateString,
        ),
      ).thenAnswer((_) async => http.Response('OK', 200));

      // act
      final result = await dataSource.sendPinStates(
        testPinStateString,
        testIpAddress,
      );

      // assert
      expect(result, true);
      verify(
        mockHttpClient.post(
          url,
          headers: {'Content-Type': 'text/plain'},
          body: testPinStateString,
        ),
      );
      verifyNoMoreInteractions(mockHttpClient);
    },
  );

  test('should return false when response is not 200', () async {
    // arrange
    final url = Uri.http(testIpAddress, updatePath);
    when(
      mockHttpClient.post(
        url,
        headers: {'Content-Type': 'text/plain'},
        body: testPinStateString,
      ),
    ).thenAnswer((_) async => http.Response('Not Found', 404));

    // act
    final result = await dataSource.sendPinStates(
      testPinStateString,
      testIpAddress,
    );

    // assert
    expect(result, false);
  });

  test('should return false when an exception occurs', () async {
    // arrange
    final url = Uri.http(testIpAddress, updatePath);
    when(
      mockHttpClient.post(
        url,
        headers: {'Content-Type': 'text/plain'},
        body: testPinStateString,
      ),
    ).thenThrow(Exception('Network error'));

    // act
    final result = await dataSource.sendPinStates(
      testPinStateString,
      testIpAddress,
    );

    // assert
    expect(result, false);
  });

  //   test('should return false when IP address is empty', () async {
  //     // act
  //     final result = await dataSource.sendPinStates(testPinStateString, '');

  //     // assert
  //     expect(result, false);
  //     verifyNever(
  //           mockHttpClient.post(
  //             any<Uri>(),
  //             headers: anyNamed('headers'),
  //             body: anyNamed('body'),
  //           ),
  //     );
  //   });
}
