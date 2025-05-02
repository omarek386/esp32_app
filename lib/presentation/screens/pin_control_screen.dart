import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:esp32_app/core/constants/app_strings.dart';
import 'package:esp32_app/presentation/bloc/pin_controller.dart';
import 'package:esp32_app/presentation/widgets/pin_toggle_card.dart';
import 'package:esp32_app/presentation/widgets/input_pin_indicator.dart';

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
    final int outputGridColumns =
        isTablet ? (isLandscape ? 4 : 3) : (isLandscape ? 3 : 2);
    final int inputGridColumns =
        isTablet ? (isLandscape ? 5 : 3) : (isLandscape ? 2 : 1);

    // Adjust aspect ratio based on screen size
    final double outputAspectRatio = isTablet ? 3.0 : 2.5;

    // Responsive padding
    final double horizontalPadding = isTablet ? 24.0 : 16.0;
    final double verticalSpacing = isTablet ? 20.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.appBarTitle),
        actions: <Widget>[
          Image.asset('assets/small-logo.png', height: 40, width: 40),
          SizedBox(width: 16.0), // Add some space before the logo
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 16.0,
          ),
          // Make the entire screen content scrollable to prevent overflow
          child: SingleChildScrollView(
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
                SizedBox(height: verticalSpacing * 0.5),

                // --- Input Pin Status Section ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        'Input Pin Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: BlocBuilder<PinCubit, PinCubitState>(
                        builder: (context, state) {
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: inputGridColumns,
                                  childAspectRatio: 3.5,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: state.inputPinStates.length,
                            itemBuilder: (context, index) {
                              final pin = state.inputPinStates[index];
                              return InputPinIndicator(
                                pinNumber: pin.pinNumber,
                                isOn: pin.isOn,
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: verticalSpacing),

                // --- Output Pin Controls Section ---
                const Padding(
                  padding: EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    'Output Pin Controls',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                ),

                // --- Output Pin Toggles ---
                // Remove the Expanded widget to avoid overflow
                BlocBuilder<PinCubit, PinCubitState>(
                  builder: (context, state) {
                    return GridView.builder(
                      shrinkWrap: true, // This makes it fit its content
                      physics:
                          const NeverScrollableScrollPhysics(), // Disable scrolling in the GridView
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: outputGridColumns,
                        childAspectRatio: outputAspectRatio,
                        crossAxisSpacing: isTablet ? 16 : 10,
                        mainAxisSpacing: isTablet ? 16 : 10,
                      ),
                      itemCount: state.outputPinStates.length,
                      itemBuilder: (context, index) {
                        final pin = state.outputPinStates[index];
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
                SizedBox(height: verticalSpacing),

                // --- Send Button ---
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: isTablet ? 300 : 250),
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
                                  : const Icon(Icons.send),
                          label: Text(
                            state.isSending
                                ? AppStrings.sendingButtonText
                                : AppStrings.sendButtonText,
                            style: TextStyle(fontSize: isTablet ? 16.0 : 14.0),
                          ),
                          onPressed:
                              state.isSending
                                  ? null
                                  : () =>
                                      context.read<PinCubit>().sendPinStates(),
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
                // Add bottom padding for better appearance when scrolling
                SizedBox(height: verticalSpacing),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
