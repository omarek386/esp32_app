import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:esp32_app/core/constants/app_strings.dart';
import 'package:esp32_app/core/injection/injection_container.dart' as di;
import 'package:esp32_app/presentation/bloc/pin_controller.dart';
import 'package:esp32_app/presentation/screens/pin_control_screen.dart';
import 'dart:async';
import 'dart:developer' as developer;

void main() async {
  // Catch any errors that might occur during initialization
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await di.init();
      runApp(const MyApp());
    },
    (error, stackTrace) {
      // Log errors in both debug and release mode
      developer.log(
        'Error in runZonedGuarded: $error',
        error: error,
        stackTrace: stackTrace,
        name: 'ESP32App',
      );

      // Also print to console in debug mode for easier development
      if (kDebugMode) {
        print('Error in runZonedGuarded: $error');
        print('Stack trace: $stackTrace');
      }

      // You might want to show an error dialog or notification in release mode
      // This ensures users know something went wrong
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<PinCubit>(),
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const PinControlScreen(),
      ),
    );
  }
}
