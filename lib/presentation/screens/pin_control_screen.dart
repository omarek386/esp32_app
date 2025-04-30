import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:esp32_app/core/constants/app_strings.dart';
import 'package:esp32_app/presentation/bloc/pin_controller.dart';
import 'package:esp32_app/presentation/widgets/pin_toggle_card.dart';

/// Screen for controlling ESP32 pins
class PinControlScreen extends StatefulWidget {
  const PinControlScreen({super.key});

  @override
  State<PinControlScreen> createState() => _PinControlScreenState();
}

class _PinControlScreenState extends State<PinControlScreen> {
  late TextEditingController _ipController;

  @override
  void initState() {
    super.initState();
    final controller = context.read<PinController>();
    _ipController = TextEditingController(text: controller.ipAddress);
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.appBarTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- IP Address Input ---
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: AppStrings.ipLabelText,
                hintText: AppStrings.ipHintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.url,
              onChanged: (value) {
                context.read<PinController>().updateIpAddress(value);
              },
            ),
            SizedBox(height: 16.0),

            // --- Status Display ---
            Consumer<PinController>(
              builder: (context, controller, child) {
                final isError = controller.statusMessage.startsWith(
                  AppStrings.errorPrefix,
                );
                return Text(
                  controller.statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isError ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            SizedBox(height: 16.0),

            // --- Pin Toggles ---
            Expanded(
              child: Consumer<PinController>(
                builder: (context, controller, child) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: controller.pinStates.length,
                    itemBuilder: (context, index) {
                      final pin = controller.pinStates[index];
                      return PinToggleCard(
                        pinNumber: pin.pinNumber,
                        isOn: pin.isOn,
                        onChanged: (value) {
                          controller.togglePin(index);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),

            // --- Send Button ---
            Consumer<PinController>(
              builder: (context, controller, child) {
                return ElevatedButton.icon(
                  icon:
                      controller.isSending
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Icon(Icons.send),
                  label: Text(
                    controller.isSending
                        ? AppStrings.sendingButtonText
                        : AppStrings.sendButtonText,
                  ),
                  onPressed:
                      controller.isSending ? null : controller.sendPinStates,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
