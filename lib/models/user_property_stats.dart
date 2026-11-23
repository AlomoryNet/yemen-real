/// Lightweight counts for the signed-in owner's listings.
///
/// Kept separate from the paged property list so the My Properties tab can
/// render accurate totals without downloading every full property record.
class UserPropertyStats {
  const UserPropertyStats({
    this.total = 0,
    this.published = 0,
    this.pending = 0,
  });

  final int total;
  final int published;
  final int pending;
}
