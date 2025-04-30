import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esp32_app/core/constants/app_strings.dart';
import 'package:esp32_app/core/injection/injection_container.dart' as di;
import 'package:esp32_app/presentation/bloc/pin_controller.dart';
import 'package:esp32_app/presentation/screens/pin_control_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => di.sl<PinController>(),
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
