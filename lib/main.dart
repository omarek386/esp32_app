import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async'; // For Timer

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Pin Sender',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: PinControlScreen(),
    );
  }
}

class PinControlScreen extends StatefulWidget {
  const PinControlScreen({super.key});

  @override
  PinControlScreenState createState() => PinControlScreenState();
}

class PinControlScreenState extends State<PinControlScreen> {
  // List to hold the state of 13 pins (true = ON, false = OFF)
  List<bool> pinStates = List.generate(13, (_) => false);
  // Controller for the ESP32 IP address input
  final TextEditingController _ipController = TextEditingController(
    text: '192.168.1.100',
  ); // Default IP
  // Status message
  String _statusMessage = 'Enter ESP32 IP and toggle pins.';
  bool _isSending = false;
  Timer? _debounce;

  // --- Function to send data to ESP32 ---
  Future<void> _sendPinStates() async {
    if (_isSending) return; // Prevent multiple rapid sends

    setState(() {
      _isSending = true;
      _statusMessage = 'Sending data...';
    });

    // Construct the data string (e.g., "1011001101010")
    String dataString = pinStates.map((state) => state ? '1' : '0').join('');
    String esp32Ip = _ipController.text.trim();

    if (esp32Ip.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter the ESP32 IP address.';
        _isSending = false;
      });
      return;
    }

    // Construct the URL for the ESP32 endpoint
    // Make sure the ESP32 code listens on port 80 and path /update
    final url = Uri.http(esp32Ip, '/update'); // Assumes port 80

    try {
      // Send POST request
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'text/plain'}, // Send as plain text
            body: dataString,
          )
          .timeout(const Duration(seconds: 5)); // Add a timeout

      if (response.statusCode == 200) {
        setState(() {
          _statusMessage =
              'Data sent successfully! (${DateTime.now().toIso8601String().substring(11, 19)})';
        });
      } else {
        setState(() {
          _statusMessage = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error sending data: $e';
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  // Debounce sending data when a switch is toggled
  void _onSwitchChanged(int index, bool value) {
    setState(() {
      pinStates[index] = value;
    });
    // Cancel any existing timer
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Start a new timer to send data after a short delay (e.g., 500ms)
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _sendPinStates();
    });
  }

  @override
  void dispose() {
    _ipController.dispose();
    _debounce?.cancel(); // Clean up timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('ESP32 Pin Control')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- IP Address Input ---
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'ESP32 IP Address',
                hintText: 'e.g., 192.168.1.100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              keyboardType: TextInputType.url,
            ),
            SizedBox(height: 16.0),

            // --- Status Display ---
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color:
                    _statusMessage.startsWith('Error')
                        ? Colors.red
                        : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),

            // --- Pin Toggles ---
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Adjust columns as needed
                  childAspectRatio: 2, // Adjust aspect ratio for toggle size
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: pinStates.length, // 13 pins
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pin ${index + 1}',
                          ), // Display pin number (1-based)
                          Switch(
                            value: pinStates[index],
                            onChanged: (value) {
                              _onSwitchChanged(index, value);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16.0),

            // --- Manual Send Button (Optional, as it sends on toggle now) ---
            ElevatedButton.icon(
              icon:
                  _isSending
                      ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(Icons.send),
              label: Text(_isSending ? 'Sending...' : 'Send Pin States'),
              onPressed:
                  _isSending
                      ? null
                      : _sendPinStates, // Disable button while sending
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
