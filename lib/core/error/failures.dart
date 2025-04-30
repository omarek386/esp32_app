/// Base class for failures in the application
abstract class Failure {
  final String message;

  const Failure(this.message);
}

/// Failure when sending data to the ESP32
class ESP32CommunicationFailure extends Failure {
  const ESP32CommunicationFailure(super.message);
}

/// Failure when the IP address is invalid
class InvalidIpAddressFailure extends Failure {
  const InvalidIpAddressFailure(super.message);
}
