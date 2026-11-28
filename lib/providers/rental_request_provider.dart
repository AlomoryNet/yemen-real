import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_list_page.dart';
import '../models/rental_request.dart';
import '../repositories/rental_request_repository.dart';
import 'admin_paging_provider.dart';
import 'auth_provider.dart';

final rentalRequestRepositoryProvider = Provider<RentalRequestRepository>((
  ref,
) {
  return RentalRequestRepository();
});

final userRentalRequestsProvider =
    FutureProvider.autoDispose<List<RentalRequest>>((ref) async {
      final auth = ref.watch(authProvider);
      if (auth.user == null) return [];
      final repo = ref.watch(rentalRequestRepositoryProvider);
      return await repo.getUserRentalRequests(auth.user!.id);
    });

// Full list is kept for CSV/PDF export only; the admin tab uses the paginator.
final allRentalRequestsProvider = FutureProvider<List<RentalRequest>>((
  ref,
) async {
  final repo = ref.watch(rentalRequestRepositoryProvider);
  return await repo.getAllRentalRequests();
});

final allRentalRequestsPaginatorProvider =
    StateNotifierProvider<
      AdminListPaginator<RentalRequest>,
      AsyncValue<AdminListPage<RentalRequest>>
    >((ref) {
      final repo = ref.watch(rentalRequestRepositoryProvider);
      return AdminListPaginator<RentalRequest>(
        (offset, limit) =>
            repo.getRentalRequestsPage(offset: offset, limit: limit),
      );
    });
