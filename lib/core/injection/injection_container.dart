import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:esp32_app/core/constants/app_strings.dart';
import 'package:esp32_app/data/datasources/esp32_data_source.dart';
import 'package:esp32_app/data/repositories/esp32_repository_impl.dart';
import 'package:esp32_app/domain/repositories/esp32_repository.dart';
import 'package:esp32_app/domain/usecases/send_pin_states.dart';
import 'package:esp32_app/domain/usecases/get_input_pin_states.dart';
import 'package:esp32_app/presentation/bloc/pin_controller.dart';

final GetIt sl = GetIt.instance;

/// Initializes dependency injection
Future<void> init() async {
  // Register services by layer

  // Cubits
  sl.registerFactory(
    () => PinCubit(
      sendPinStatesUseCase: sl<SendPinStatesUseCase>(),
      getInputPinStatesUseCase: sl<GetInputPinStatesUseCase>(),
      initialIpAddress: AppStrings.defaultIpAddress,
      numberOfOutputPins: 13, // Default number of output pins
      numberOfInputPins: 5, // Default number of input pins from ESP32
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendPinStatesUseCase(sl<ESP32Repository>()));
  sl.registerLazySingleton(
    () => GetInputPinStatesUseCase(sl<ESP32Repository>()),
  );

  // Repositories
  sl.registerLazySingleton<ESP32Repository>(
    () => ESP32RepositoryImpl(sl<ESP32DataSource>()),
  );

  // Data sources
  sl.registerLazySingleton<ESP32DataSource>(
    () => ESP32DataSourceImpl(
      client: sl<http.Client>(),
      updatePath: AppStrings.updatePath,
      getStatesPath:
          '/getStates', // Path for the new endpoint to read input pins
    ),
  );

  // External dependencies
  sl.registerLazySingleton(() => http.Client());
}
