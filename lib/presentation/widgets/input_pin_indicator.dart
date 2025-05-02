import 'package:flutter/material.dart';

/// Widget for displaying the status of an input pin
class InputPinIndicator extends StatelessWidget {
  final int pinNumber;
  final bool isOn;

  const InputPinIndicator({
    super.key,
    required this.pinNumber,
    required this.isOn,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: isOn ? Colors.green.shade300 : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            // Pin indicator light
            Container(
              width: 24.0,
              height: 24.0,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOn ? Colors.green : Colors.grey.shade400,
                boxShadow:
                    isOn
                        ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                          ),
                        ]
                        : null,
              ),
            ),
            const SizedBox(width: 12.0),

            // Pin information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Input Pin $pinNumber',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    isOn ? 'HIGH (1)' : 'LOW (0)',
                    style: TextStyle(
                      color:
                          isOn ? Colors.green.shade700 : Colors.grey.shade700,
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
