import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location_item.dart';
import '../models/property_type.dart';
import '../repositories/location_repository.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepository();
});

final propertyTypesProvider = FutureProvider<List<PropertyType>>((ref) async {
  final repo = ref.watch(locationRepositoryProvider);
  return await repo.getPropertyTypes();
});

final locationsProvider = FutureProvider<List<LocationItem>>((ref) async {
  final repo = ref.watch(locationRepositoryProvider);
  return await repo.getLocations();
});
