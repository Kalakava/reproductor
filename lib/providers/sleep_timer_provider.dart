import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'player_provider.dart';

class SleepTimerState {
  final Duration? remainingTime;
  final bool isActive;

  const SleepTimerState({
    this.remainingTime,
    this.isActive = false,
  });

  SleepTimerState copyWith({
    Duration? remainingTime,
    bool? isActive,
    bool clearTimer = false,
  }) =>
      SleepTimerState(
        remainingTime: clearTimer ? null : (remainingTime ?? this.remainingTime),
        isActive: isActive ?? this.isActive,
      );
}

class SleepTimerNotifier extends StateNotifier<SleepTimerState> {
  final Ref _ref;
  Timer? _timer;

  SleepTimerNotifier(this._ref) : super(const SleepTimerState());

  void setTimer(Duration duration) {
    _timer?.cancel();
    state = SleepTimerState(
      remainingTime: duration,
      isActive: true,
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = state.remainingTime;
      if (remaining == null || remaining.inSeconds <= 0) {
        _triggerShutdown();
      } else {
        state = state.copyWith(remainingTime: remaining - const Duration(seconds: 1));
      }
    });
  }

  void cancelTimer() {
    _timer?.cancel();
    state = const SleepTimerState(remainingTime: null, isActive: false);
  }

  void _triggerShutdown() {
    _timer?.cancel();
    state = const SleepTimerState(remainingTime: null, isActive: false);
    // Pausar la reproducción
    _ref.read(playerProvider.notifier).pause();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final sleepTimerProvider =
    StateNotifierProvider<SleepTimerNotifier, SleepTimerState>((ref) {
  return SleepTimerNotifier(ref);
});
