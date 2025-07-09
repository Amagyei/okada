import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:okada/data/models/ride_model.dart';
import 'package:okada/notifiers/ride_notifier.dart';

class RideDetailState {
  final Ride? ride;
  final bool isLoading;
  final String? error;
  final bool isPolling;

  RideDetailState({
    this.ride,
    this.isLoading = false,
    this.error,
    this.isPolling = false,
  });

  RideDetailState copyWith({
    Ride? ride,
    bool? isLoading,
    String? error,
    bool? isPolling,
  }) {
    return RideDetailState(
      ride: ride ?? this.ride,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isPolling: isPolling ?? this.isPolling,
    );
  }
}

class RideDetailNotifier extends StateNotifier<RideDetailState> {
  final int rideId;
  Timer? _pollingTimer;
  final RideNotifier _rideNotifier;

  RideDetailNotifier(this.rideId, this._rideNotifier) : super(RideDetailState());

  Future<void> fetchRideDetails() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _rideNotifier.getRideDetails(rideId);
      final rideState = _rideNotifier.state;
      state = state.copyWith(
        ride: rideState.ride,
        isLoading: false,
        error: rideState.error,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    if (state.isPolling) return;
    state = state.copyWith(isPolling: true);
    fetchRideDetails(); // Initial fetch
    _pollingTimer = Timer.periodic(interval, (_) {
      fetchRideDetails();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    state = state.copyWith(isPolling: false);
  }

  Future<void> cancelRideAction(String reason) async {
    try {
      await _rideNotifier.cancelRide(rideId, reason);
      await fetchRideDetails();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}

final rideDetailProvider = StateNotifierProvider.family<RideDetailNotifier, RideDetailState, int>((ref, rideId) {
  final rideNotifier = ref.watch(rideNotifierProvider.notifier);
  return RideDetailNotifier(rideId, rideNotifier);
}); 