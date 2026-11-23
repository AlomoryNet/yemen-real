/// English labels for enum-like values returned by `AppConstants`.
///
/// Arabic labels stay in `AppConstants` (they are also used as stable demo
/// data); these maps let the same getters return English when the user
/// switches language, without threading `BuildContext` through the data layer.
class AppLabelsEn {
  static const Map<String, String> currency = {
    'YER': 'Yemeni rial',
    'SAR': 'Saudi riyal',
    'USD': 'US dollar',
  };

  static const Map<String, String> dealType = {
    'sale': 'For sale',
    'rent': 'For rent',
  };

  static const Map<String, String> propertyStatus = {
    'draft': 'Draft',
    'pending': 'Under review',
    'published': 'Published',
    'hidden': 'Hidden',
    'archived': 'Archived',
    'rejected': 'Rejected',
  };

  static const Map<String, String> rentalRequestStatus = {
    'new': 'New',
    'under_review': 'Under review',
    'contacted': 'Contacted',
    'provisionally_accepted': 'Provisionally accepted',
    'rejected': 'Rejected',
    'cancelled': 'Cancelled',
    'completed': 'Completed',
  };

  static const Map<String, String> liableParty = {
    'seller': 'Seller',
    'buyer': 'Buyer / tenant',
    'both': 'Both (seller and buyer)',
  };

  static const Map<String, String> commissionStatus = {
    'due': 'Due',
    'paid': 'Paid',
    'cancelled': 'Cancelled',
  };
}
