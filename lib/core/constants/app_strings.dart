/// Contains all string constants used in the application
class AppStrings {
  // Default values
  static const defaultIpAddress = '192.168.1.100';
  static const initialStatusMessage = 'Enter ESP32 IP and toggle pins.';

  // Status messages
  static const sendingDataMessage = 'Sending data...';
  static const enterIpMessage = 'Please enter the ESP32 IP address.';
  static const errorPrefix = 'Error';
  static const errorMessage = 'Error:';
  static const errorSendingMessage = 'Error sending data:';
  static const successMessage = 'Data sent successfully!';

  // App titles
  static const appTitle = 'ESP32 Pin Sender';
  static const appBarTitle = 'ESP32 Pin Control';

  // Input field labels

  static const ipLabelText = 'ESP32 IP Address';
  static const ipHintText = 'e.g., 192.168.1.100';

  // Button labels

  static const sendButtonText = 'Send Pin States';
  static const sendingButtonText = 'Sending...';

  // Pin label
  static const pinPrefix = 'Pin';

  // Endpoints
  static const updatePath = '/update';
}
