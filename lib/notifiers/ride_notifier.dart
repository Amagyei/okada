import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:okada/data/models/ride_model.dart';
import 'package:okada/core/services/ride_service.dart';

class RideState {
  final Ride? ride;
  final bool isLoading;
  final String? error;

  RideState({
    this.ride,
    this.isLoading = false,
    this.error,
  });

  RideState copyWith({
    Ride? ride,
    bool? isLoading,
    String? error,
  }) {
    return RideState(
      ride: ride ?? this.ride,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RideNotifier extends StateNotifier<RideState> {
  final RideService rideService;

  RideNotifier(this.rideService) : super(RideState());

  Future<void> getRideDetails(int rideId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await rideService.getRideDetails(rideId);
      state = state.copyWith(ride: response, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> cancelRide(int rideId, String reason) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await rideService.cancelRide(rideId, reason);
      await getRideDetails(rideId); // Refresh ride details
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final rideNotifierProvider = StateNotifierProvider<RideNotifier, RideState>((ref) {
  final rideService = ref.watch(rideServiceProvider);
  return RideNotifier(rideService);
}); 