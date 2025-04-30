# ESP32 Flutter Control Application

A Flutter application designed to communicate with and control an ESP32 microcontroller over WiFi.

## Project Overview

This application provides a user interface to send control commands to an ESP32 device. It establishes communication over WiFi, sending data to the ESP32 web server to control GPIO pins or perform other functions.

## Features

- WiFi-based communication with ESP32
- Control multiple GPIO pins from the Flutter app
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

// --- GPIO Pins (Optional Example) ---
// Define an array of GPIO pins you might want to control based on received data
// Make sure these pins are safe to use as outputs on your specific ESP32 board
const int outputPins[] = {2, 4, 5, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22}; // Example GPIOs
const int numPins = sizeof(outputPins) / sizeof(outputPins[0]); // Should match Flutter app (13)

// --- Handler for incoming data ---
void handleUpdate() {
  // Check if the request method is POST and if there's plain text data
  if (server.method() == HTTP_POST && server.hasArg("plain")) {
    String receivedData = server.arg("plain"); // Get the plain text body
    Serial.print("Received data: ");
    Serial.println(receivedData);

    // --- Data Validation ---
    if (receivedData.length() == numPins) { // Check if the length matches expected (13)
      bool validData = true;
      for (int i = 0; i < receivedData.length(); i++) {
        if (receivedData[i] != '0' && receivedData[i] != '1') {
          validData = false;
          break;
        }
      }

      if (validData) {
        // --- Process the received data ---
        // Example: Control GPIO pins based on the received string
        for (int i = 0; i < numPins; i++) {
          int pinState = (receivedData[i] == '1') ? HIGH : LOW;
          digitalWrite(outputPins[i], pinState);
          Serial.printf("Set Pin %d (%d) to %s\n", i + 1, outputPins[i], (pinState == HIGH) ? "HIGH" : "LOW");
        }

        // Send a success response back to the Flutter app
        server.send(200, "text/plain", "Data received successfully!");

      } else {
         Serial.println("Error: Invalid characters in data.");
         server.send(400, "text/plain", "Invalid data format: Only '0' or '1' allowed.");
      }
    } else {
      Serial.print("Error: Invalid data length. Expected ");
      Serial.print(numPins);
      Serial.print(", Got ");
      Serial.println(receivedData.length());
      // Send an error response back to the Flutter app
      server.send(400, "text/plain", "Invalid data length. Expected 13 characters.");
    }
  } else {
    // Handle cases where the request is not POST or doesn't have the expected data
    Serial.println("Error: Invalid request format.");
    server.send(400, "text/plain", "Invalid request. Use POST with plain text body.");
  }
}

// --- Handler for root URL (Optional) ---
void handleRoot() {
  String html = "<html><body><h1>ESP32 Server Running</h1><p>Send POST requests to /update</p></body></html>";
  server.send(200, "text/html", html);
}

// --- Handler for Not Found ---
void handleNotFound() {
  server.send(404, "text/plain", "Not Found");
}

void setup() {
  Serial.begin(115200); // Start serial communication for debugging
  Serial.println("\nESP32 Web Server Starting...");

  // --- Configure GPIO Pins as Outputs (Example) ---
  Serial.println("Configuring GPIO pins as outputs...");
  for (int i = 0; i < numPins; i++) {
    pinMode(outputPins[i], OUTPUT);
    digitalWrite(outputPins[i], LOW); // Start with all pins LOW
  }
  Serial.println("GPIO pins configured.");


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
  server.on("/", HTTP_GET, handleRoot);           // Handler for the root path (optional)
  server.on("/update", HTTP_POST, handleUpdate); // Handler for the data update path
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

The Flutter app sends a string of '0's and '1's to the ESP32's `/update` endpoint via HTTP POST request. Each character corresponds to a GPIO pin state (0 = OFF, 1 = ON).

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
