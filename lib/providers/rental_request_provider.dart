import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/rental_request.dart';
import '../repositories/rental_request_repository.dart';
import 'auth_provider.dart';

final rentalRequestRepositoryProvider = Provider<RentalRequestRepository>((
  ref,
) {
  return RentalRequestRepository();
});

final userRentalRequestsProvider = FutureProvider<List<RentalRequest>>((
  ref,
) async {
  final auth = ref.watch(authProvider);
  if (auth.user == null) return [];
  final repo = ref.watch(rentalRequestRepositoryProvider);
  return await repo.getUserRentalRequests(auth.user!.id);
});

final allRentalRequestsProvider = FutureProvider<List<RentalRequest>>((
  ref,
) async {
  final repo = ref.watch(rentalRequestRepositoryProvider);
  return await repo.getAllRentalRequests();
});
