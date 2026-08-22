import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/debug/debug_simulation_service.dart';
import 'app_providers.dart';

class DebugState {
  final bool isOffline;
  final bool simulateTimeout;
  final bool simulateNotFound;
  final bool simulateValidationError;
  final int artificialDelayMs;

  const DebugState({
    this.isOffline = false,
    this.simulateTimeout = false,
    this.simulateNotFound = false,
    this.simulateValidationError = false,
    this.artificialDelayMs = 400,
  });

  DebugState copyWith({
    bool? isOffline,
    bool? simulateTimeout,
    bool? simulateNotFound,
    bool? simulateValidationError,
    int? artificialDelayMs,
  }) {
    return DebugState(
      isOffline: isOffline ?? this.isOffline,
      simulateTimeout: simulateTimeout ?? this.simulateTimeout,
      simulateNotFound: simulateNotFound ?? this.simulateNotFound,
      simulateValidationError:
          simulateValidationError ?? this.simulateValidationError,
      artificialDelayMs: artificialDelayMs ?? this.artificialDelayMs,
    );
  }
}

class DebugNotifier extends StateNotifier<DebugState> {
  final DebugSimulationService _service;

  DebugNotifier(this._service) : super(const DebugState()) {
    _syncFromService();
  }

  void _syncFromService() {
    state = DebugState(
      isOffline: _service.isOffline,
      simulateTimeout: _service.simulateTimeout,
      simulateNotFound: _service.simulateNotFound,
      simulateValidationError: _service.simulateValidationError,
      artificialDelayMs: _service.artificialDelayMs,
    );
  }

  void toggleOffline(bool value) {
    _service.isOffline = value;
    state = state.copyWith(isOffline: value);
  }

  void toggleTimeout(bool value) {
    _service.simulateTimeout = value;
    state = state.copyWith(simulateTimeout: value);
  }

  void toggleNotFound(bool value) {
    _service.simulateNotFound = value;
    state = state.copyWith(simulateNotFound: value);
  }

  void toggleValidationError(bool value) {
    _service.simulateValidationError = value;
    state = state.copyWith(simulateValidationError: value);
  }

  void setArtificialDelay(int ms) {
    _service.artificialDelayMs = ms;
    state = state.copyWith(artificialDelayMs: ms);
  }

  void reset() {
    _service.reset();
    _syncFromService();
  }
}

final debugNotifierProvider = StateNotifierProvider<DebugNotifier, DebugState>((ref) {
  final service = ref.watch(debugSimulationServiceProvider);
  return DebugNotifier(service);
});
