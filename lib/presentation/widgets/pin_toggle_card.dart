import 'package:flutter/material.dart';
import 'package:esp32_app/core/constants/app_strings.dart';

/// A widget for toggling a pin's state
class PinToggleCard extends StatelessWidget {
  final int pinNumber;
  final bool isOn;
  final void Function(bool) onChanged;

  const PinToggleCard({
    Key? key,
    required this.pinNumber,
    required this.isOn,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${AppStrings.pinPrefix} $pinNumber'),
            Switch(value: isOn, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
