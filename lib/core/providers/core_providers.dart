import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/network_info.dart';

// Connectivity provider
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

// Network info provider
final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.read(connectivityProvider));
});

// Shared preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main()');
});

// Network status stream provider
final networkStatusProvider = StreamProvider<bool>((ref) {
  final networkInfo = ref.read(networkInfoProvider);
  return networkInfo.onConnectivityChanged;
});

// Current network status provider
final currentNetworkStatusProvider = FutureProvider<bool>((ref) {
  final networkInfo = ref.read(networkInfoProvider);
  return networkInfo.isConnected;
});
