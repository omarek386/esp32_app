# ESP32 Flutter Control Application

A Flutter application designed to communicate with and control an ESP32 microcontroller over WiFi.

## Project Overview

This application provides a user interface to send control commands to an ESP32 device and monitor input pin states. It establishes communication over WiFi, sending data to the ESP32 web server to control GPIO pins and receiving real-time updates from connected sensors or switches.

## Features

- WiFi-based communication with ESP32
- Control multiple GPIO pins from the Flutter app
- Monitor status of 5 input pins in real-time
- Read sensor data or switch states from the ESP32
- Clean, responsive UI for mobile devices
- Cross-platform support (iOS, Android)

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (v3.0.0 or higher)
- An ESP32 development board
- Arduino IDE with ESP32 board support

### Setup Instructions

1. **Flutter App Setup**

   - Clone this repository
   - Run `flutter pub get` to install dependencies
   - Configure the ESP32 IP address in the app configuration

2. **ESP32 Setup**
   - Flash the ESP32 with the code provided below
   - Update WiFi credentials in the ESP32 code

## ESP32 Implementation

Upload the following code to your ESP32 using Arduino IDE:

```cpp
#include <WiFi.h>
#include <WebServer.h> // Use the standard WebServer library

// --- Wi-Fi Credentials ---
const char* ssid = "YOUR_WIFI_SSID";       // Replace with your Wi-Fi network name
const char* password = "YOUR_WIFI_PASSWORD"; // Replace with your Wi-Fi password

// --- Web Server Setup ---
WebServer server(80); // Create a web server object on port 80

// --- GPIO Pins for Output Control ---
// Make sure these pins are safe to use as outputs on your specific ESP32 board
const int outputPins[] = {2, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22}; // Example GPIOs for output
const int numOutputPins = sizeof(outputPins) / sizeof(outputPins[0]); // Should match Flutter app (13)

// --- GPIO Pins for Input Reading ---
// Pins 34-39 are input-only pins and recommended for input purposes
const int inputPins[] = {34, 35, 36, 39, 23}; // 4 input-only pins + GPIO23
const int numInputPins = sizeof(inputPins) / sizeof(inputPins[0]); // Should be 5

// --- Handler for incoming data to CONTROL outputs ---
void handleUpdate() {
  // Check if the request method is POST and if there's plain text data
  if (server.method() == HTTP_POST && server.hasArg("plain")) {
    String receivedData = server.arg("plain"); // Get the plain text body
    Serial.print("Received data for output control: ");
    Serial.println(receivedData);

    // --- Data Validation ---
    if (receivedData.length() == numOutputPins) { // Check if the length matches expected (13)
      bool validData = true;
      for (int i = 0; i < receivedData.length(); i++) {
        if (receivedData[i] != '0' && receivedData[i] != '1') {
          validData = false;
          break;
        }
      }

      if (validData) {
        // --- Process the received data ---
        // Control GPIO pins based on the received string
        for (int i = 0; i < numOutputPins; i++) {
          // Ensure index is within bounds for outputPins array
          if (i < (sizeof(outputPins) / sizeof(outputPins[0]))) {
             int pinState = (receivedData[i] == '1') ? HIGH : LOW;
             digitalWrite(outputPins[i], pinState);
             Serial.printf("Set Output Pin %d (%d) to %s\n", i + 1, outputPins[i], (pinState == HIGH) ? "HIGH" : "LOW");
          }
        }
        server.send(200, "text/plain", "Output data received successfully!");

      } else {
         Serial.println("Error: Invalid characters in output data.");
         server.send(400, "text/plain", "Invalid output data format: Only '0' or '1' allowed.");
      }
    } else {
      Serial.print("Error: Invalid output data length. Expected ");
      Serial.print(numOutputPins);
      Serial.print(", Got ");
      Serial.println(receivedData.length());
      server.send(400, "text/plain", "Invalid output data length. Expected 13 characters.");
    }
  } else {
    Serial.println("Error: Invalid request format for /update.");
    server.send(400, "text/plain", "Invalid request for /update. Use POST with plain text body.");
  }
}

// --- Handler to GET input pin states ---
void handleGetStates() {
  if (server.method() != HTTP_GET) {
     server.send(405, "text/plain", "Method Not Allowed");
     return;
  }

  String pinStates = ""; // String to hold the pin states (e.g., "10110")

  Serial.print("Reading input pins: ");
  for (int i = 0; i < numInputPins; i++) {
    int state = digitalRead(inputPins[i]); // Read the state of the current input pin
    pinStates += (state == HIGH) ? '1' : '0'; // Append '1' for HIGH, '0' for LOW
    Serial.printf("Pin %d (%d) = %d; ", i + 1, inputPins[i], state);
  }
  Serial.println(); // New line after printing states

  Serial.print("Sending states: ");
  Serial.println(pinStates);

  // Send the combined state string back to the client (Flutter app)
  server.send(200, "text/plain", pinStates);
}


// --- Handler for root URL (Optional) ---
void handleRoot() {
  String html = "<html><body><h1>ESP32 Server Running</h1>";
  html += "<p>Send POST requests to /update (expects ";
  html += String(numOutputPins);
  html += " '0' or '1' chars) to control outputs.</p>";
  html += "<p>Send GET requests to /getStates to read ";
  html += String(numInputPins);
  html += " input pin states.</p>";
  html += "</body></html>";
  server.send(200, "text/html", html);
}

// --- Handler for Not Found ---
void handleNotFound() {
  server.send(404, "text/plain", "Not Found");
}

void setup() {
  Serial.begin(115200); // Start serial communication for debugging
  Serial.println("\nESP32 Web Server Starting...");

  // --- Configure OUTPUT Pins ---
  Serial.println("Configuring output pins...");
  for (int i = 0; i < numOutputPins; i++) {
    pinMode(outputPins[i], OUTPUT);
    digitalWrite(outputPins[i], LOW); // Start with all pins LOW
  }
  Serial.println("Output pins configured.");

  // --- Configure INPUT Pins ---
  Serial.println("Configuring input pins...");
  for (int i = 0; i < numInputPins; i++) {
    // Use INPUT_PULLUP if your switches connect the pin to GND when active.
    // Use INPUT if you have external pull-up/pull-down resistors or the sensor actively drives the pin high/low.
    pinMode(inputPins[i], INPUT_PULLUP);
    // pinMode(inputPins[i], INPUT); // Alternative if using external resistors or active sensors
    Serial.printf("Input Pin %d (%d) configured.\n", i + 1, inputPins[i]);
  }
  Serial.println("Input pins configured.");


  // --- Connect to Wi-Fi ---
  Serial.printf("Connecting to %s ", ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP()); // Print the ESP32's IP address

  // --- Setup Web Server Routes ---
  server.on("/", HTTP_GET, handleRoot);           // Handler for the root path
  server.on("/update", HTTP_POST, handleUpdate); // Handler for controlling outputs
  server.on("/getStates", HTTP_GET, handleGetStates); // Handler for reading inputs
  server.onNotFound(handleNotFound);             // Handler for 404 errors

  // --- Start Server ---
  server.begin();
  Serial.println("HTTP server started. Listening for requests...");
}

void loop() {
  // Handle incoming client requests
  server.handleClient();

  // You can add other non-blocking tasks here if needed
  // delay(10); // Small delay can sometimes help stability, but avoid long delays
}
```

## Communication Protocol

The application supports bidirectional communication with the ESP32:

1. **Output Control**: The Flutter app sends a string of '0's and '1's to the ESP32's `/update` endpoint via HTTP POST request. Each character corresponds to an output GPIO pin state (0 = OFF, 1 = ON).

2. **Input Monitoring**: The app can send GET requests to `/getStates` endpoint to retrieve the current states of the 5 input pins. The ESP32 returns a 5-character string where each character represents an input pin state (0 = LOW, 1 = HIGH).

For reliable operation:
- Ensure proper external circuits for input pins (pull-up/pull-down resistors as needed)
- The ESP32 code uses INPUT_PULLUP mode by default for switch/button inputs
- For sensors that actively drive pins high/low, modify the code to use INPUT mode

## Project Architecture

This project follows clean architecture principles with:

- **Data layer**: Handles API communication with the ESP32
- **Domain layer**: Contains business logic and entities
- **Presentation layer**: Manages UI components and user interactions

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [ESP32 Documentation](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/)
- [WebServer Library for ESP32](https://github.com/espressif/arduino-esp32/tree/master/libraries/WebServer)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
