import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    _ipController = TextEditingController(
      text: context.read<PinCubit>().state.ipAddress,
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size information for responsive layout
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;
    final bool isTablet = screenSize.shortestSide >= 600;

    // Dynamically calculate grid columns based on screen size and orientation
    final int gridColumns =
        isTablet ? (isLandscape ? 4 : 3) : (isLandscape ? 3 : 2);

    // Adjust aspect ratio based on screen size
    final double aspectRatio = isTablet ? 3.0 : 2.5;

    // Responsive padding
    final double horizontalPadding = isTablet ? 24.0 : 16.0;
    final double verticalSpacing = isTablet ? 20.0 : 16.0;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.appBarTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- IP Address Input ---
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : double.infinity,
                    ),
                    child: TextField(
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
                        context.read<PinCubit>().updateIpAddress(value);
                      },
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // --- Status Display ---
                  BlocBuilder<PinCubit, PinCubitState>(
                    builder: (context, state) {
                      final isError = state.statusMessage.startsWith(
                        AppStrings.errorPrefix,
                      );
                      return Text(
                        state.statusMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isError ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 16.0 : 14.0,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: verticalSpacing),

                  // --- Pin Toggles ---
                  Expanded(
                    child: BlocBuilder<PinCubit, PinCubitState>(
                      builder: (context, state) {
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridColumns,
                                childAspectRatio: aspectRatio,
                                crossAxisSpacing: isTablet ? 16 : 10,
                                mainAxisSpacing: isTablet ? 16 : 10,
                              ),
                          itemCount: state.pinStates.length,
                          itemBuilder: (context, index) {
                            final pin = state.pinStates[index];
                            return PinToggleCard(
                              pinNumber: pin.pinNumber,
                              isOn: pin.isOn,
                              onChanged: (value) {
                                context.read<PinCubit>().togglePin(index);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(height: verticalSpacing),

                  // --- Send Button ---
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 300 : 250,
                      ),
                      child: BlocBuilder<PinCubit, PinCubitState>(
                        builder: (context, state) {
                          return ElevatedButton.icon(
                            icon:
                                state.isSending
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
                              state.isSending
                                  ? AppStrings.sendingButtonText
                                  : AppStrings.sendButtonText,
                              style: TextStyle(
                                fontSize: isTablet ? 16.0 : 14.0,
                              ),
                            ),
                            onPressed:
                                state.isSending
                                    ? null
                                    : () =>
                                        context
                                            .read<PinCubit>()
                                            .sendPinStates(),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 16.0 : 12.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
