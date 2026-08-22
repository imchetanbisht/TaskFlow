import 'dart:async';
import '../errors/app_exception.dart';

class DebugSimulationService {
  bool isOffline = false;
  bool simulateTimeout = false;
  bool simulateNotFound = false;
  bool simulateValidationError = false;
  int artificialDelayMs = 400;

  void reset() {
    isOffline = false;
    simulateTimeout = false;
    simulateNotFound = false;
    simulateValidationError = false;
    artificialDelayMs = 400;
  }

  Future<void> applySimulation({String? entityId}) async {
    if (artificialDelayMs > 0) {
      await Future.delayed(Duration(milliseconds: artificialDelayMs));
    }

    if (isOffline) {
      throw const OfflineException(
        'You are currently offline. Showing cached data where available.',
      );
    }

    if (simulateTimeout) {
      throw const NetworkException(
        'Simulated network request timed out. Please try again.',
        code: 'TIMEOUT',
      );
    }

    if (simulateNotFound || entityId == 'not_found_test_id') {
      throw const NotFoundException(
        'The requested resource could not be found (Simulated 404).',
      );
    }

    if (simulateValidationError) {
      throw const ValidationException(
        'Simulated server-side validation error occurred.',
        fieldErrors: {'general': 'Validation constraint violated in simulation mode.'},
      );
    }
  }
}
