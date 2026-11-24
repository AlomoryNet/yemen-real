// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Yemen Real Estate Portal';

  @override
  String get app_name_english => 'Yemen Real Estate Portal';

  @override
  String get title_dashboard => 'Dashboard';

  @override
  String get title_my_properties => 'My Properties';

  @override
  String get title_settings => 'Settings';

  @override
  String get title_add_property => 'Add Property';

  @override
  String get header_add_property => 'Add Your Property';

  @override
  String get header_add_property_free => 'Add Your Property Free';

  @override
  String get header_settings => 'Settings';

  @override
  String get bottom_home => 'Home';

  @override
  String get bottom_my_properties => 'My Properties';

  @override
  String get dashboard_search_hint => 'Search by address, neighborhood, or keywords...';

  @override
  String get search_button => 'Search';

  @override
  String get filter_button => 'Filters';

  @override
  String get filter_save => 'Save';

  @override
  String get filter_reset => 'Reset';

  @override
  String get city_dropdown => 'Select City';

  @override
  String get district_dropdown => 'Select District';

  @override
  String get deal_type => 'Deal Type';

  @override
  String get deal_sale => 'For Sale';

  @override
  String get deal_rent => 'For Rent';

  @override
  String get deal_all => 'All (Sale/Rent)';

  @override
  String get property_type => 'Property Type';

  @override
  String get property_type_all => 'All Types';

  @override
  String get draw_area => 'Draw Area';

  @override
  String get satellite => 'Satellite';

  @override
  String get map => 'Map';

  @override
  String get list_view => 'List View';

  @override
  String get asset_count => 'Property';

  @override
  String get asset_count_plural => 'Properties';

  @override
  String get asset_zero => 'No properties found';

  @override
  String get asset_count_always => 'Always show property count';

  @override
  String get add_property_style_outline => 'Outline button on Home';

  @override
  String get add_property_style_fab => 'FAB above map FAB';

  @override
  String get location_permission_title => 'Allow Location';

  @override
  String get location_permission_message => 'We want to find properties near you. Please allow access to your location.';

  @override
  String get location_allow => 'Allow';

  @override
  String get location_deny => 'Not Now';

  @override
  String location_city(Object city) {
    return 'City: $city';
  }

  @override
  String get language => 'Language';

  @override
  String get language_ar => 'العربية';

  @override
  String get language_en => 'English';

  @override
  String get theme => 'Theme';

  @override
  String get theme_system => 'System';

  @override
  String get theme_light => 'Light';

  @override
  String get theme_dark => 'Dark';

  @override
  String get notifications => 'Notifications';

  @override
  String get notifications_on => 'Enable Notifications';

  @override
  String get about => 'About';

  @override
  String about_version(Object version) {
    return 'Version: $version';
  }

  @override
  String get about_privacy => 'Privacy Policy';

  @override
  String get about_privacy_body => 'We respect your privacy and do not share your personal data with any third party without your consent. Your data is used only to provide and improve the platform services.';

  @override
  String get about_terms => 'Terms of Service';

  @override
  String get about_terms_body => 'By using the platform you agree to the terms and conditions governing the service, including the accuracy of listing data and the advertiser\'s responsibility for its content.';

  @override
  String get about_contact => 'Contact Us';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Sign Up';

  @override
  String get profile => 'Profile';

  @override
  String get my_requests => 'My Rental Requests';

  @override
  String get my_properties_list => 'My Listed Properties';

  @override
  String get admin_panel => 'Admin Panel';

  @override
  String get footer_contact => 'Contact Us';

  @override
  String get footer_support_email => 'support@yemenrealestate.local';

  @override
  String get footer_phone => '+967 770 000 000';

  @override
  String get loading => 'Loading...';

  @override
  String get no_results => 'No Results';

  @override
  String get error_occurred => 'An Error Occurred';

  @override
  String get retry => 'Retry';

  @override
  String get success => 'Success';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get near_you => 'Near You';

  @override
  String get nearby_properties => 'Properties Near You';

  @override
  String get nearby_map => 'Map Near You';

  @override
  String get draw_area_button => 'Draw Area';

  @override
  String get offline_map => 'Yemen Map 🇾🇪';

  @override
  String get all_governorates => 'All Governorates 🇾🇪';

  @override
  String get offline_atlas_button => 'View List';

  @override
  String get add_property_prompt => 'To complete this action, please create an account and verify your email first.';

  @override
  String get manage_properties_prompt => 'To manage your properties, please log in first.';

  @override
  String get confirm_logout => 'Are you sure you want to log out?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get loading_properties => 'Loading properties...';

  @override
  String properties_available(Object count) {
    return '$count properties available';
  }

  @override
  String get map_offline_button => 'Map';

  @override
  String get satellite_toggle => 'Satellite';

  @override
  String get map_tools => 'Map Tools';

  @override
  String get property_details => 'Property Details';

  @override
  String get property_price => 'Price';

  @override
  String get property_location => 'Location';

  @override
  String get property_area => 'Area';

  @override
  String get property_bedrooms => 'Bedrooms';

  @override
  String get property_bathrooms => 'Bathrooms';

  @override
  String get property_type_apt => 'Apartment';

  @override
  String get property_type_villa => 'Villa';

  @override
  String get property_type_land => 'Land';

  @override
  String get property_type_shop => 'Shop';

  @override
  String get status_published => 'Published';

  @override
  String get status_pending => 'Pending Review';

  @override
  String get status_draft => 'Draft';

  @override
  String get status_rejected => 'Rejected';

  @override
  String get contact_owner => 'Contact Owner';

  @override
  String get contact_agent => 'Contact Agent';

  @override
  String get send_message => 'Send Message';

  @override
  String get message_sent => 'Sent';

  @override
  String get save_favorite => 'Add to Favorites';

  @override
  String get remove_favorite => 'Remove from Favorites';

  @override
  String get share => 'Share';

  @override
  String get print => 'Print';

  @override
  String get download => 'Download';

  @override
  String get view_on_map => 'View on Map';

  @override
  String get search_this_area => 'Search This Area';

  @override
  String get select_city => 'Select City';

  @override
  String get select_district => 'Select District';

  @override
  String get no_properties_found => 'No Properties Found';

  @override
  String get expand_map => 'Expand Map';

  @override
  String get collapse_map => 'Collapse Map';

  @override
  String get favorite_properties => 'Favorites';

  @override
  String get property_requests => 'Property Requests';

  @override
  String get create_request => 'Create Request';

  @override
  String get my_requests_empty => 'No Requests';

  @override
  String get admin_dashboard => 'Admin Dashboard';

  @override
  String get admin_users => 'Users';

  @override
  String get admin_properties => 'Properties';

  @override
  String get admin_requests => 'Requests';

  @override
  String get admin_analytics => 'Analytics';

  @override
  String get settings_saved => 'Settings Saved';

  @override
  String get reset_settings => 'Reset Settings';

  @override
  String get require_auth => 'Authentication Required';

  @override
  String get login_required => 'Please log in first';

  @override
  String get notifications_empty => 'No Notifications';

  @override
  String get clear_all => 'Clear All';

  @override
  String get close => 'Close';

  @override
  String get mark_as_read => 'Mark as Read';

  @override
  String get back => 'Back';

  @override
  String get home => 'Home';

  @override
  String get map_tab => 'Map';

  @override
  String get search_tab => 'Search';

  @override
  String get profile_tab => 'Profile';

  @override
  String get logout_confirmation => 'Confirm Logout';

  @override
  String get session_expired => 'Session expired, please log in again';

  @override
  String get internet_required => 'Internet connection required';

  @override
  String get try_again => 'Try Again';

  @override
  String get contact_support => 'Contact Support';

  @override
  String get support_email => 'support@yemenrealestate.local';

  @override
  String get terms_link => 'Terms of Service';

  @override
  String get privacy_link => 'Privacy Policy';

  @override
  String get login_enter_email_first => 'Please enter your email address first';

  @override
  String get login_verification_resent => 'A new confirmation link has been sent to your email. Please check your inbox.';

  @override
  String get login_resend_failed => 'Unable to resend right now';

  @override
  String get login_demo_admin_filled => 'The admin email has been filled in. Please enter the password manually to continue securely';

  @override
  String get login_demo_user_filled => 'The demo user email has been filled in. Please enter the password to continue';

  @override
  String get login_title => 'Sign In';

  @override
  String get login_submit => 'Sign In';

  @override
  String get login_subtitle => 'Welcome back to the Yemen Real Estate Portal';

  @override
  String get login_sending => 'Sending...';

  @override
  String get login_resend_now => 'Resend the activation link to my email now';

  @override
  String get login_email => 'Email';

  @override
  String get login_password => 'Password';

  @override
  String get login_remember_me => 'Remember email';

  @override
  String get login_forgot_password => 'Forgot password?';

  @override
  String get login_no_account => 'Don\'t have an account?';

  @override
  String get login_create_account => 'Create a new account';

  @override
  String get login_resend_prompt => 'Didn\'t receive the activation link? Resend it to my email';

  @override
  String get login_quick_demo => 'Quick sign-in with system accounts:';

  @override
  String get login_demo_admin => 'General Manager (email only)';

  @override
  String get login_demo_user => 'Advertiser account (email only)';

  @override
  String get register_confirm_title => 'Confirm and activate your account';

  @override
  String get register_confirm_message => 'A confirmation message has been sent to your email. Please check your inbox and tap the confirmation link to finish creating your account.';

  @override
  String get register_open_inbox => 'Please open your email inbox and click the activation link sent to you to complete verification and activate your account.';

  @override
  String get register_warning => 'Note: You will not be signed in or granted permissions until you click the link in your email.';

  @override
  String get register_resend_success => 'The confirmation link has been resent to your email';

  @override
  String get register_resend_failed => 'Unable to resend right now';

  @override
  String get register_resending => 'Resending...';

  @override
  String get register_resend_prompt => 'Didn\'t receive the message? Resend the activation link';

  @override
  String get register_browse_guest => 'Browse as guest';

  @override
  String get register_go_login => 'Go to sign in';

  @override
  String get register_title => 'Create a new account';

  @override
  String get register_subtitle => 'Join Yemen\'s leading real estate community for free';

  @override
  String get register_go_login_now => 'Go to sign in now';

  @override
  String get register_full_name_required => 'Full name *';

  @override
  String get register_full_name => 'Full name';

  @override
  String get register_name_hint => 'Enter your full name';

  @override
  String get register_email_required => 'Email *';

  @override
  String get register_phone_required => 'Contact phone number *';

  @override
  String get register_phone_hint => 'Example: 770000000';

  @override
  String get register_password_required => 'Password *';

  @override
  String get register_password_hint => 'At least 8 characters (numbers and letters for security)';

  @override
  String get register_submit => 'Create account';

  @override
  String get register_have_account => 'Already have an account?';

  @override
  String get register_login_link => 'Sign In';

  @override
  String get forgot_link_sent => 'Password reset link sent';

  @override
  String get forgot_check_inbox => 'Check your email inbox and follow the instructions to set a new password.';

  @override
  String get forgot_back_to_login => 'Back to sign in';

  @override
  String get forgot_title => 'Reset password';

  @override
  String get forgot_instructions => 'Enter your registered email address and we will send you a link to reset your password.';

  @override
  String get forgot_email => 'Email';

  @override
  String get forgot_send_link => 'Send reset link';

  @override
  String get forgot_return_to_login => 'Return to sign in';

  @override
  String get callback_expired_message => 'This activation link has expired or has already been used. Please request a new link to continue.';

  @override
  String get callback_link_error => 'Could not verify the link. Please try again later.';

  @override
  String get callback_enter_email_first => 'Please enter your email address first';

  @override
  String get callback_resend_success => 'A new activation link has been sent to your email';

  @override
  String get callback_resend_failed => 'Unable to resend right now';

  @override
  String get callback_verifying => 'Verifying your email activation...';

  @override
  String get callback_waiting => 'Please wait a few seconds while we confirm your account with the Yemen Real Estate Portal servers.';

  @override
  String get callback_success_title => 'Your email has been activated successfully!';

  @override
  String get callback_success_message => 'Welcome to the Yemen Real Estate Portal. Your email ownership has been confirmed and your account is now fully active.';

  @override
  String get callback_continue_operation => 'Continue to complete your action';

  @override
  String get callback_continue_home => 'Continue to the home page';

  @override
  String get callback_go_home => 'Go to the home page';

  @override
  String get callback_login_credentials => 'Sign in with email and password';

  @override
  String get callback_expired_title => 'Activation link expired or already used';

  @override
  String get callback_cannot_confirm => 'Could not confirm the link';

  @override
  String get callback_expired_fallback => 'This link has expired or the account has already been verified with it. You can try signing in or request a new activation link.';

  @override
  String get callback_error_fallback => 'An error occurred while processing the activation link. Please try again.';

  @override
  String get callback_resend_email_label => 'Email address for resending';

  @override
  String get callback_sending => 'Sending...';

  @override
  String get callback_send_new_link => 'Send a new activation link';

  @override
  String get callback_back_login => 'Back to the sign-in page';

  @override
  String get admin_restricted_title => 'Restricted admin area';

  @override
  String get admin_restricted_desc => 'This page is reserved for Yemen Real Estate Portal administrators and you do not have permission to access it.';

  @override
  String get admin_back_home => 'Back to home';

  @override
  String get admin_title => 'Administration & Control Dashboard';

  @override
  String get admin_subtitle => 'Manage the platform, properties, rental requests, and manual commission records.';

  @override
  String get admin_general_manager => 'General Manager: Mohammed Al-Saqqaf';

  @override
  String get admin_loading_stats => 'Loading statistics...';

  @override
  String get admin_tab_properties => 'Property Management';

  @override
  String get admin_tab_requests => 'Rental Requests';

  @override
  String get admin_tab_commissions => 'Commission Records';

  @override
  String get admin_tab_reports => 'Violation Reports';

  @override
  String get admin_tab_users => 'Users (Encrypted)';

  @override
  String get admin_print_pdf => 'Print full PDF report for this section';

  @override
  String get admin_total_properties => 'Total Properties';

  @override
  String get admin_published_properties => 'Published Properties';

  @override
  String get admin_pending_review => 'Pending Review';

  @override
  String get admin_total_users => 'Total Users';

  @override
  String get admin_commission_records => 'Commission Records';

  @override
  String get admin_pending_title => 'Properties Awaiting Approval';

  @override
  String get admin_awaiting_review => 'awaiting review';

  @override
  String get admin_review_complete => 'All reviewed';

  @override
  String get admin_pending_desc => 'Review properties added by users and approve their public publication on the map and in search results.';

  @override
  String get admin_refresh_requests => 'Refresh the request list';

  @override
  String get admin_no_pending => 'No properties are awaiting approval — all publication requests have been reviewed and approved.';

  @override
  String get admin_loading_pending => 'Fetching pending publication requests...';

  @override
  String get admin_for_rent => 'For Rent';

  @override
  String get admin_for_sale => 'For Sale';

  @override
  String get admin_sqm => 'm²';

  @override
  String get admin_rooms => 'bedrooms';

  @override
  String get admin_listing_owner => 'Listing owner';

  @override
  String get admin_platform_user => 'Platform user';

  @override
  String get admin_approve_publish => 'Approve & publish listing';

  @override
  String get admin_reject_request => 'Reject request';

  @override
  String get admin_view_full_details => 'View full details';

  @override
  String get admin_approved_prefix => 'Property \"';

  @override
  String get admin_approved_suffix => '\" has been approved for publishing and is now publicly visible in search and on the map.';

  @override
  String get admin_approve_failed => 'Failed to approve property publishing';

  @override
  String get admin_default_reject_reason => 'The information is incomplete or does not comply with the platform\'s publishing policy.';

  @override
  String get admin_reject_dialog_title => 'Reject property publication request';

  @override
  String get admin_reject_reason_prompt => 'Please enter a reason for rejecting the listing so the property owner can be notified:';

  @override
  String get admin_reject_hint => 'Type the rejection reason here...';

  @override
  String get admin_cancel => 'Cancel';

  @override
  String get admin_confirm_reject => 'Confirm rejection';

  @override
  String get admin_reject_saved => 'The listing rejection has been recorded and the reason saved.';

  @override
  String get admin_reject_failed => 'Failed to record the rejection';

  @override
  String get admin_properties_list_title => 'Property list & publishing control';

  @override
  String get admin_export_csv => 'Export CSV';

  @override
  String get admin_export_properties_title => 'Export property data';

  @override
  String get admin_no_properties => 'No properties available';

  @override
  String get admin_status_label => 'Status';

  @override
  String get admin_approve_tooltip => 'Approve & publish listing (Mohammed Al-Saqqaf)';

  @override
  String get admin_approved_by_admin => 'Property approved and published by administrator: Mohammed Al-Saqqaf';

  @override
  String get admin_rejected_by_admin_review => 'Rejected by administration after review';

  @override
  String get admin_rejected_status_updated => 'Publication request rejected and status updated';

  @override
  String get admin_approve_publish_menu => 'Approve publication';

  @override
  String get admin_hide_listing => 'Hide listing';

  @override
  String get admin_republish => 'Republish';

  @override
  String get admin_archive => 'Archive';

  @override
  String get admin_delete_permanent => 'Delete permanently';

  @override
  String get admin_requests_list_title => 'Rental requests & follow-up';

  @override
  String get admin_export_requests_title => 'Export rental requests';

  @override
  String get admin_no_requests => 'No rental requests recorded';

  @override
  String get admin_phone_label => 'Phone';

  @override
  String get admin_property_label => 'Property';

  @override
  String get admin_status_under_review => 'Under review';

  @override
  String get admin_status_contacted => 'Contacted';

  @override
  String get admin_status_provisional => 'Provisionally accepted';

  @override
  String get admin_status_rejected => 'Rejected';

  @override
  String get admin_status_completed => 'Completed';

  @override
  String get admin_commissions_list_title => 'Administrative commission records (manual)';

  @override
  String get admin_add_commission => 'Record commission';

  @override
  String get admin_export_commissions_title => 'Export commission records';

  @override
  String get admin_no_commissions => 'No commission records recorded';

  @override
  String get admin_commissions_desc => 'Commissions are recorded according to approved decisions (manual entry per agreement)';

  @override
  String get admin_registered_property => 'Registered property';

  @override
  String get admin_liable_party => 'Liable party';

  @override
  String get admin_settlement_method => 'Settlement method';

  @override
  String get admin_awaiting_collection => 'Awaiting collection';

  @override
  String get admin_status_paid => 'Paid';

  @override
  String get admin_status_due => 'Due';

  @override
  String get admin_status_cancelled => 'Cancelled';

  @override
  String get admin_commission_modal_title => 'Add a manual commission record';

  @override
  String get admin_commission_property_title => 'Property title or ID *';

  @override
  String get admin_commission_property_hint => 'Example: Bayt Bos villa';

  @override
  String get admin_commission_liable => 'Party liable for the commission *';

  @override
  String get admin_liable_both => 'Both (seller and buyer)';

  @override
  String get admin_liable_seller => 'Seller only';

  @override
  String get admin_liable_buyer => 'Buyer only';

  @override
  String get admin_seller_amount => 'Seller amount';

  @override
  String get admin_buyer_amount => 'Buyer amount';

  @override
  String get admin_currency => 'Currency';

  @override
  String get admin_commission_notes => 'Commission reason and agreement notes';

  @override
  String get admin_save_record => 'Save record';

  @override
  String get admin_reports_list_title => 'Violating listing reports';

  @override
  String get admin_no_reports => 'No violation reports at the moment';

  @override
  String get admin_no_reports_desc => 'All published listings are compliant and no violations have been reported.';

  @override
  String get admin_details_label => 'Details';

  @override
  String get admin_none => 'None';

  @override
  String get admin_verified_closed => 'Verified and closed';

  @override
  String get admin_process => 'Process';

  @override
  String get admin_encrypted_section_title => 'Encrypted, protected section for the General Manager only';

  @override
  String get admin_encrypted_section_desc => 'Under security and encryption policies, user data is visible only to the General Manager (M. Mohammed Al-Saqqaf) to ensure full privacy.';

  @override
  String get admin_users_list_title => 'User account registry (encrypted and protected data)';

  @override
  String get admin_gm_permissions => 'General Manager permissions';

  @override
  String get admin_data_protection => 'Data protection: passwords and sensitive details are encrypted with the standard encryption system, and the General Manager only sees the user\'s name and account.';

  @override
  String get admin_account_label => 'Account';

  @override
  String get admin_created_at => 'Creation date';

  @override
  String get admin_encrypted_protected => 'Encrypted & protected';

  @override
  String get admin_section_users => 'User registry';

  @override
  String get admin_pdf_preparing => 'Preparing and printing a full PDF report for section:';

  @override
  String get admin_day_monday => 'Monday';

  @override
  String get admin_day_tuesday => 'Tuesday';

  @override
  String get admin_day_wednesday => 'Wednesday';

  @override
  String get admin_day_thursday => 'Thursday';

  @override
  String get admin_day_friday => 'Friday';

  @override
  String get admin_day_saturday => 'Saturday';

  @override
  String get admin_day_sunday => 'Sunday';

  @override
  String get admin_month_january => 'January';

  @override
  String get admin_month_february => 'February';

  @override
  String get admin_month_march => 'March';

  @override
  String get admin_month_april => 'April';

  @override
  String get admin_month_may => 'May';

  @override
  String get admin_month_june => 'June';

  @override
  String get admin_month_july => 'July';

  @override
  String get admin_month_august => 'August';

  @override
  String get admin_month_september => 'September';

  @override
  String get admin_month_october => 'October';

  @override
  String get admin_month_november => 'November';

  @override
  String get admin_month_december => 'December';

  @override
  String get admin_pm => 'PM';

  @override
  String get admin_am => 'AM';

  @override
  String get admin_sanaa_time => '(Sana\'a time)';

  @override
  String get admin_col_property_id => 'Property ID';

  @override
  String get admin_col_address => 'Address';

  @override
  String get admin_col_deal => 'Deal';

  @override
  String get admin_col_city => 'City';

  @override
  String get admin_col_price => 'Price';

  @override
  String get admin_col_request_id => 'Request ID';

  @override
  String get admin_col_tenant => 'Tenant';

  @override
  String get admin_col_phone => 'Phone';

  @override
  String get admin_col_start_date => 'Start date';

  @override
  String get admin_col_id => 'ID';

  @override
  String get admin_col_amount => 'Amount';

  @override
  String get admin_col_settlement_status => 'Settlement status';

  @override
  String get admin_col_report_reason => 'Report reason';

  @override
  String get admin_col_report_date => 'Report date';

  @override
  String get admin_status_resolved => 'Resolved';

  @override
  String get admin_col_number => 'No.';

  @override
  String get admin_col_username => 'Username';

  @override
  String get admin_col_account_email => 'Account (email)';

  @override
  String get admin_col_encryption_status => 'Encryption status';

  @override
  String get admin_encrypted_protected_pdf => '🔒 Encrypted & protected';

  @override
  String get admin_pdf_bismillah => 'In the name of Allah, the Most Gracious, the Most Merciful';

  @override
  String get admin_pdf_republic => 'Republic of Yemen — Yemen Real Estate Portal';

  @override
  String get admin_pdf_report_header => 'General Administration — Official comprehensive report';

  @override
  String get admin_pdf_section => 'Section';

  @override
  String get admin_pdf_issuer => 'Issued by: General Manager (M. Mohammed Al-Saqqaf)';

  @override
  String get admin_pdf_day_label => 'Day';

  @override
  String get admin_pdf_date_label => 'Date';

  @override
  String get admin_pdf_month_label => 'Month';

  @override
  String get admin_pdf_year_label => 'Year';

  @override
  String get admin_pdf_year_suffix => 'AD';

  @override
  String get admin_pdf_time_label => 'Time';

  @override
  String get admin_pdf_total_items => 'Total section items';

  @override
  String get admin_pdf_data_status => 'Data status: approved and updated in real time';

  @override
  String get admin_pdf_no_data => 'No data recorded currently';

  @override
  String get admin_pdf_copyright => 'Hiba Soft — All rights reserved © 2026';

  @override
  String get admin_pdf_doc_footer => 'Official administrative document — encrypted and certified';

  @override
  String get admin_report_filename_prefix => 'report_';

  @override
  String get admin_pdf_export_success => 'The PDF report was exported successfully';

  @override
  String get admin_pdf_saved_prefix => 'The comprehensive report for section \"';

  @override
  String get admin_pdf_saved_suffix => '\" has been saved, including the day, date, month, year and exact time in Sana\'a.';

  @override
  String get admin_pdf_file_name => '📁 File name:';

  @override
  String get admin_pdf_save_path => '📍 Saved path on device:';

  @override
  String get admin_copy_path => 'Copy path';

  @override
  String get admin_path_copied => 'File path copied to clipboard';

  @override
  String get admin_ok => 'OK';

  @override
  String get admin_export_failed => 'Failed to export the report';

  @override
  String get admin_copy_data => 'Copy data';

  @override
  String get admin_csv_copied => 'CSV data copied to clipboard successfully';

  @override
  String get admin_close => 'Close';

  @override
  String get contract_auth_prompt_message => 'To complete this action, please create an account and verify your email first.';

  @override
  String get contract_clauses_saved => 'Contract clauses saved and updated successfully';

  @override
  String get contract_bismillah => 'In the name of Allah, the Most Gracious, the Most Merciful';

  @override
  String get contract_republic => 'Republic of Yemen';

  @override
  String get contract_edit_date => 'Draft date:';

  @override
  String get contract_first_party => 'First party (lessor / owner):';

  @override
  String get contract_phone => 'Phone:';

  @override
  String get contract_address => 'Address:';

  @override
  String get contract_second_party => 'Second party (tenant):';

  @override
  String get contract_id_card_number => 'Personal ID card no.:';

  @override
  String get contract_tenant_id_label => 'Personal ID card / identity number *';

  @override
  String get contract_leased_property => 'Leased property:';

  @override
  String get contract_property_in_governorate => 'Property located in governorate of';

  @override
  String get contract_district_label => '- District:';

  @override
  String get contract_specifications => 'Specifications:';

  @override
  String get contract_terms_title => 'Terms and conditions of the agreement:';

  @override
  String get contract_clause1_title => 'Contract term:';

  @override
  String get contract_starts_from_date => 'starting from';

  @override
  String get contract_until_date => 'until';

  @override
  String get contract_non_renewable_plain => 'Not renewable except at the request and with the written consent of the first party.';

  @override
  String get contract_auto_renew_plain => 'Renews automatically unless either party notifies the other one month in advance.';

  @override
  String get contract_clause2_title => 'Agreed rent:';

  @override
  String get contract_amount_of => 'an amount of';

  @override
  String get contract_paid => 'payable';

  @override
  String get contract_clause3_title => 'Security deposit / insurance amount:';

  @override
  String get contract_deposit_return => 'Paid to the lessor and returned to the tenant upon expiry of the contract and handover of the property in its original condition.';

  @override
  String get contract_clause4_title => 'Utility bills:';

  @override
  String get contract_clause5_title => 'Maintenance and use:';

  @override
  String get contract_clause6_title => 'Prohibition of subletting:';

  @override
  String get contract_sublease_ban_text => 'This contract is personal to the tenant, who may not assign, transfer or sublet it in whole or in part.';

  @override
  String get contract_clause7_title => 'Late payment:';

  @override
  String get contract_clause8_title => 'Additional special conditions from the lessor:';

  @override
  String get contract_owner_signature => 'Signature of the first party (lessor): .....................';

  @override
  String get contract_tenant_signature => 'Signature of the second party (tenant): .....................';

  @override
  String get contract_witnesses_line => 'First witness: .....................    Second witness: .....................';

  @override
  String get contract_text_copied => 'The full contract text was copied to the clipboard; you can paste and print it in any application';

  @override
  String get contract_default_title => 'Legal and Sharia-compliant lease contract';

  @override
  String get contract_first_party_pdf => 'First party (lessor/owner):';

  @override
  String get contract_id_number => 'ID no.:';

  @override
  String get contract_tenant_phone => 'Tenant phone:';

  @override
  String get contract_residence => 'Place of residence:';

  @override
  String get contract_start_date => 'Start date:';

  @override
  String get contract_pdf_terms_title => 'Terms and conditions of the agreement:';

  @override
  String get contract_renew_by_mutual_consent => 'Renews by mutual consent of both parties.';

  @override
  String get contract_monthly_rent_agreed => 'Agreed monthly rent:';

  @override
  String get contract_pdf_rent_tail => 'in advance with official receipts; a two-week delay voids the contract.';

  @override
  String get contract_personal_clause => 'This contract is personal between the above parties and was made with their full conviction and consent; it is not subject to any terms harmful to the lessor.';

  @override
  String get contract_tenant_acknowledgement => 'The tenant acknowledges receiving the leased property in sound condition and undertakes to maintain it inside and out, and bears responsibility for any damage or defect occurring to the leased property.';

  @override
  String get contract_no_transfer_clause => 'The contract is personal to the tenant named above; it may not be assigned to others, whether covertly or openly, and no transfer of tenancy is permitted.';

  @override
  String get contract_liability_clause => 'The lessor is not liable for any damage or risks to lives or assets for any reason, including fire, rain, floods or theft.';

  @override
  String get contract_deposit_title => 'Deposit and insurance:';

  @override
  String get contract_deposit_screen_title => 'Security deposit and insurance:';

  @override
  String get contract_paid_amount => 'paid an amount of';

  @override
  String get contract_deposit_tail => 'as a security deposit refunded upon handover of the property in its original condition.';

  @override
  String get contract_owner_signature_short => 'Lessor signature (first party)';

  @override
  String get contract_tenant_signature_short => 'Tenant signature (second party)';

  @override
  String get contract_witness_short => 'First / second witness';

  @override
  String get contract_portal_name_suffix => '— Yemen Real Estate Portal';

  @override
  String get contract_pdf_saved_title => 'Contract PDF saved';

  @override
  String get contract_pdf_saved_body_before => 'The official contract PDF has been saved successfully on your device:\n\n📂 Path:';

  @override
  String get contract_pdf_saved_body_after => 'You can now send it via WhatsApp, print it, or open it with a file manager (Downloads).';

  @override
  String get contract_copy_text => 'Copy contract text';

  @override
  String get contract_cancel => 'Cancel';

  @override
  String get contract_ok => 'OK';

  @override
  String get contract_pdf_save_error => 'An error occurred while saving the PDF file';

  @override
  String get contract_app_bar_title => 'Contract preview and customization';

  @override
  String get contract_edit_tooltip => 'Edit and customize clauses';

  @override
  String get contract_save_pdf => 'Save contract PDF';

  @override
  String get contract_edit_clauses => 'Edit clauses';

  @override
  String get contract_print => 'Print';

  @override
  String get contract_number => 'Contract no.:';

  @override
  String get contract_fill_intro_title => 'Fill in and write the contract details directly';

  @override
  String get contract_fill_intro_body => 'Tap here or any field to enter the tenant and lessor names, ID numbers, amounts and contract terms so they appear printed in the PDF without blank spaces';

  @override
  String get contract_fill_fields => 'Fill in fields';

  @override
  String get contract_section_parties => 'First: Contract parties';

  @override
  String get contract_first_party_box => 'First party (lessor / owner):';

  @override
  String get contract_section_property => 'Second: Leased property details and location';

  @override
  String get contract_approx_area_prefix => 'with an approximate area of';

  @override
  String get contract_sqm_unit => 'm²';

  @override
  String get contract_section_clauses => 'Third: Legal and Sharia-compliant terms and conditions';

  @override
  String get contract_clause1_screen_title => 'Contract term and effective date:';

  @override
  String get contract_duration_label => 'Contract term';

  @override
  String get contract_ends_on_date => 'and ending on';

  @override
  String get contract_non_renewable_screen => 'It is not renewable except at the request and with the express written consent of the first party.';

  @override
  String get contract_renewable_by_consent => 'Renewable by mutual consent of both parties.';

  @override
  String get contract_clause2_screen_title => 'Rental value and payment method:';

  @override
  String get contract_agreed_monthly_value => 'The parties agreed on a monthly rent of';

  @override
  String get contract_receipt_tail => 'with signed payment receipts.';

  @override
  String get contract_deposit_preamble => 'The second party pays a security and insurance amount of';

  @override
  String get contract_deposit_screen_tail => 'held by the first party as a deposit for maintenance, cleanliness and bill payment, and refunded to the tenant upon vacating in sound condition.';

  @override
  String get contract_utilities_screen_title => 'Utility and consumption bills:';

  @override
  String get contract_bears_utilities => 'shall bear';

  @override
  String get contract_utilities_tail => 'all electricity, water, cleaning and communication charges related to the leased property throughout the lease term.';

  @override
  String get contract_maintenance_screen_title => 'Property care and maintenance:';

  @override
  String get contract_no_alterations => 'The tenant may not make any openings or alterations to the building without prior written permission.';

  @override
  String get contract_sublease_screen_title => 'Prohibition of subletting or transferring tenancy:';

  @override
  String get contract_sublease_ban_screen_text => 'This contract is personal to the tenant only; they may not assign it to others in whole or in part, whether by subletting or transferring tenancy.';

  @override
  String get contract_termination_title => 'Contract termination and vacating the property:';

  @override
  String get contract_extra_clauses_title => 'Additional special conditions from the lessor:';

  @override
  String get contract_section_signatures => 'Fourth: Acknowledgement and signatures';

  @override
  String get contract_witness1 => 'First witness';

  @override
  String get contract_witness2 => 'Second witness';

  @override
  String get contract_footer_notice => 'Official document issued by the Yemen Real Estate Portal — Hiba Soft © 2026';

  @override
  String get contract_write_edit => 'Write / edit';

  @override
  String get contract_name_label => 'Name:';

  @override
  String get contract_identity_label => 'ID / card:';

  @override
  String get contract_signature_stamp => 'Signature / fingerprint: ...................';

  @override
  String get contract_sheet_title => 'Fill in and edit contract details';

  @override
  String get contract_tab_parties => 'Tenant and lessor';

  @override
  String get contract_tab_terms => 'Terms and finances';

  @override
  String get contract_tenant_section_title => 'Second party (tenant) - fill in the blanks';

  @override
  String get contract_tenant_name_label => 'Full tenant name *';

  @override
  String get contract_tenant_name_hint => 'e.g. Mohammed Abdullah Al-Ahdal';

  @override
  String get contract_id_hint => 'e.g. 01010023456';

  @override
  String get contract_contact_phone_label => 'Contact phone number *';

  @override
  String get contract_tenant_address_label => 'Current address and place of residence';

  @override
  String get contract_tenant_address_hint => 'e.g. Sanaa - Al-Asbahi';

  @override
  String get contract_owner_section_title => 'First party (lessor / owner)';

  @override
  String get contract_owner_name_label => 'Lessor / owner name *';

  @override
  String get contract_owner_name_hint => 'Full four-part name of the owner';

  @override
  String get contract_owner_id_label => 'Lessor personal ID number';

  @override
  String get contract_id_number_hint => 'ID number';

  @override
  String get contract_owner_phone_label => 'Lessor phone *';

  @override
  String get contract_contact_phone_hint => 'Contact phone';

  @override
  String get contract_owner_address_label => 'Registered lessor address';

  @override
  String get contract_owner_address_hint => 'e.g. Sanaa - Hadda';

  @override
  String get contract_formal_title_label => 'Official contract title';

  @override
  String get contract_rent_amount_label => 'Rent amount';

  @override
  String get contract_deposit_label => 'Security deposit and insurance';

  @override
  String get contract_duration_hint => 'One full year';

  @override
  String get contract_start_date_label => 'Start date';

  @override
  String get contract_end_date_label => 'End date';

  @override
  String get contract_non_renewable_switch_title => 'Non-renewable except at the owner\'s request and with their consent';

  @override
  String get contract_non_renewable_switch_subtitle => 'Protects the lessor\'s right to decide whether to renew';

  @override
  String get contract_sublease_switch_title => 'Strictly prohibit subletting or transferring tenancy';

  @override
  String get contract_sublease_switch_subtitle => 'Prevents the tenant from handing the property to another person without the owner\'s written consent';

  @override
  String get contract_utilities_label => 'Utility bill responsibility (electricity, water)';

  @override
  String get contract_maintenance_label => 'Maintenance terms and property handover';

  @override
  String get contract_late_policy_label => 'Late payment and termination clause';

  @override
  String get contract_extra_owner_clauses_title => 'Additional special conditions from the owner:';

  @override
  String get contract_custom_clause_hint => 'Write a custom clause (e.g. no smoking indoors)...';

  @override
  String get contract_add => 'Add';

  @override
  String get contract_save_template_title => 'Save this contract as a default template for my future properties';

  @override
  String get contract_save_template_subtitle => 'When enabled, these terms will be applied automatically when adding any new listing';

  @override
  String get contract_save_apply => 'Save and apply changes';

  @override
  String get contract_pdf_filename => 'lease_contract';

  @override
  String get dash_add_listing_now => 'Add Your Listing Now';

  @override
  String get dash_add_property_free => 'Add Your Property for Free';

  @override
  String get dash_add_property_prompt => 'To complete this action, please create an account and verify your email first.';

  @override
  String get dash_add_property_tooltip => 'Add your property';

  @override
  String get dash_all => 'All';

  @override
  String get dash_all_governorates => 'All Governorates';

  @override
  String get dash_all_governorates_show_all => 'All Yemeni Governorates (Show All)';

  @override
  String get dash_cta_desc_desktop => 'Post your ad on the Yemen Real Estate portal with instant self-review and direct communication with clients.';

  @override
  String get dash_cta_desc_mobile => 'Post your ad for free on the Yemen Real Estate portal and connect directly with thousands of property seekers.';

  @override
  String get dash_cta_title => 'Do you have a property you want to sell or rent?';

  @override
  String get dash_districts_of_gov => 'Districts and areas of';

  @override
  String get dash_empty_section_description => 'Check back for newly added listings or browse the other sections';

  @override
  String get dash_empty_section_title => 'No properties in this section yet';

  @override
  String get dash_featured_subtitle => 'Trusted and featured properties across Yemen';

  @override
  String get dash_featured_title => 'Featured Properties';

  @override
  String get dash_for_rent_subtitle => 'Residential apartments and commercial spaces ready for rent';

  @override
  String get dash_for_rent_title => 'Latest Properties for Rent';

  @override
  String get dash_for_sale_subtitle => 'Apartments, villas, and land offered for direct sale';

  @override
  String get dash_for_sale_title => 'Latest Properties for Sale';

  @override
  String get dash_governorate => 'Governorate';

  @override
  String get dash_hero_subtitle => 'Thousands of apartments, villas, land, and commercial shops for sale or rent directly from owners';

  @override
  String get dash_hero_title => 'Find Your Dream Property in Yemen';

  @override
  String get dash_loading_featured => 'Loading featured properties...';

  @override
  String get dash_loading_for_rent => 'Loading rental properties...';

  @override
  String get dash_loading_for_sale => 'Loading properties for sale...';

  @override
  String get dash_location_dialog_message => 'Allowing access to your location shows the nearest properties on the map and in the list. You can change this later in Settings.';

  @override
  String get dash_location_dialog_title => 'Find properties near you';

  @override
  String get dash_location_no_thanks => 'No, thanks';

  @override
  String get dash_location_use_my_location => 'Use my location';

  @override
  String get dash_nearby_fallback_count => 'properties near Ibb (default)';

  @override
  String get dash_nearby_in_range_count => 'properties in range';

  @override
  String get dash_nearby_title => 'Properties near you';

  @override
  String get dash_no_nearby_properties => 'No properties within range. Adjust the radius in Settings.';

  @override
  String get dash_or_select_specific_district => 'Or choose a specific district / area:';

  @override
  String get dash_properties_for_rent => 'Properties for Rent';

  @override
  String get dash_properties_for_sale => 'Properties for Sale';

  @override
  String get dash_search_button => 'Search';

  @override
  String get dash_search_hint => 'Search by district, city, or keywords (e.g. apartment in Hadda)...';

  @override
  String get dash_search_in_gov_prefix => 'Search in';

  @override
  String get dash_search_in_gov_suffix => '(e.g. Hadda district, apartment)...';

  @override
  String get dash_select_governorate_title => 'Choose a Yemeni governorate to view properties';

  @override
  String get dash_show_all_gov_properties => 'View all properties in';

  @override
  String get dash_trusted_platform => 'Yemen\'s trusted real estate platform';

  @override
  String get dash_view_all => 'View all';

  @override
  String get dash_view_map => 'View map';

  @override
  String get dash_yemen_map => 'Yemen Map';

  @override
  String get fav_empty_action => 'Browse properties now';

  @override
  String get fav_empty_desc => 'You can add any property to your list by tapping the heart icon on its card';

  @override
  String get fav_empty_title => 'No properties in favorites';

  @override
  String get fav_loading => 'Loading favorites list...';

  @override
  String get fav_login_required => 'Authentication Required';

  @override
  String get fav_signup_or_login => 'Sign Up or Log In';

  @override
  String get fav_signup_prompt => 'To complete this action, please create an account and verify your email first.';

  @override
  String get fav_subtitle => 'Properties you saved for quick access and comparison.';

  @override
  String get fav_title => 'Favorite Properties';

  @override
  String get myprops_add_new => 'Add New Property';

  @override
  String get myprops_add_property => 'Add a Property';

  @override
  String get myprops_added_on => 'Added on:';

  @override
  String get myprops_archive => 'Archive listing';

  @override
  String get myprops_contract => 'Generate and print contract';

  @override
  String get myprops_delete_permanent => 'Delete permanently';

  @override
  String get myprops_edit => 'Edit listing';

  @override
  String get myprops_empty_action => 'Add your first property';

  @override
  String get myprops_empty_desc => 'Post your first property now for free and start receiving inquiries directly';

  @override
  String get myprops_empty_title => 'You haven\'t listed any property yet';

  @override
  String get myprops_hide => 'Hide listing';

  @override
  String get myprops_loading => 'Loading your properties...';

  @override
  String get myprops_login_required => 'Authentication Required';

  @override
  String get myprops_preview => 'Preview';

  @override
  String get myprops_republish => 'Republish';

  @override
  String get myprops_signup_or_login => 'Sign Up or Log In';

  @override
  String get myprops_signup_prompt => 'To complete this action, please create an account and verify your email first.';

  @override
  String get myprops_subtitle => 'Manage your properties, track views, and update their status.';

  @override
  String get myprops_title => 'My Listed Properties';

  @override
  String get myprops_view => 'View listing';

  @override
  String get myprops_views => 'Views:';

  @override
  String get myprops_yemen_map => 'Yemen Map';

  @override
  String get prof_admin => 'Admin';

  @override
  String get prof_admin_subtitle => 'Manage properties, users, commissions, and reports';

  @override
  String get prof_admin_title => 'Admin & Control Panel';

  @override
  String get prof_cancel => 'Cancel';

  @override
  String get prof_edit_account => 'Edit Account Details';

  @override
  String get prof_favorites_subtitle => 'Quick access to properties you saved earlier';

  @override
  String get prof_favorites_title => 'Favorite Properties List';

  @override
  String get prof_full_name => 'Full Name';

  @override
  String get prof_full_name_hint => 'Enter your full name';

  @override
  String get prof_full_name_required => 'Full Name *';

  @override
  String get prof_login_required => 'Authentication Required';

  @override
  String get prof_manage_activities => 'Manage My Real Estate Activity';

  @override
  String get prof_member_since => 'Member since:';

  @override
  String get prof_my_listings_subtitle => 'Review published listings and drafts, edit or hide them';

  @override
  String get prof_my_listings_title => 'My Listed Properties';

  @override
  String get prof_my_requests_subtitle => 'Track the status and details of rental requests sent to owners';

  @override
  String get prof_my_requests_title => 'Submitted Rental Requests';

  @override
  String get prof_no_phone => 'No phone number set';

  @override
  String get prof_phone_required => 'Contact Phone Number *';

  @override
  String get prof_save_changes => 'Save Changes';

  @override
  String get prof_sign_out => 'Sign Out';

  @override
  String get prof_signup_or_login => 'Sign Up or Log In';

  @override
  String get prof_signup_prompt => 'To complete this action, please create an account and verify your email first.';

  @override
  String get prof_super_admin => 'Super Admin';

  @override
  String get prof_update_failure => 'Could not update data';

  @override
  String get prof_update_success => 'Data updated successfully';

  @override
  String get req_close => 'Close';

  @override
  String get req_desired_start_date => 'Desired Move-in Date (optional)';

  @override
  String get req_empty_action => 'Browse rental properties';

  @override
  String get req_empty_desc => 'Browse available rentals and send a preliminary rental request';

  @override
  String get req_empty_title => 'No previous rental requests';

  @override
  String get req_error_prefix => 'An error occurred:';

  @override
  String get req_follow_my_requests => 'Track My Requests';

  @override
  String get req_form_title => 'Request to Rent a Property';

  @override
  String get req_full_name => 'Full Name';

  @override
  String get req_full_name_hint => 'Enter your full name';

  @override
  String get req_full_name_required => 'Full Name *';

  @override
  String get req_loading => 'Loading your requests...';

  @override
  String get req_login_required => 'Authentication Required';

  @override
  String get req_not_specified => 'Not specified';

  @override
  String get req_notes_hint => 'Mention any questions, preferred rental term, or family size...';

  @override
  String get req_notes_label => 'Additional notes or special requests';

  @override
  String get req_owner_admin_reply => 'Owner/Admin reply:';

  @override
  String get req_phone_example_prefix => 'Example:';

  @override
  String get req_phone_required => 'Contact Phone Number *';

  @override
  String get req_pick_date_hint => 'Pick the expected move-in date';

  @override
  String get req_property_fallback => 'Property for rent';

  @override
  String get req_reference_number => 'Request reference number:';

  @override
  String get req_requested_start => 'Requested start date:';

  @override
  String get req_sent_on => 'Sent on:';

  @override
  String get req_signup_or_login => 'Sign Up or Log In';

  @override
  String get req_signup_prompt => 'To complete this action, please create an account and verify your email first.';

  @override
  String get req_submit => 'Send Rental Request Now';

  @override
  String get req_subtitle => 'Track the status of your requests and inquiries for rental properties.';

  @override
  String get req_success => 'Rental request received successfully';

  @override
  String get req_success_note => 'Note: This request is only an inquiry and a preliminary rental interest; it is not a formal contract or a final booking.';

  @override
  String get req_title => 'My Rental Requests';

  @override
  String get req_view_property => 'View Property';

  @override
  String get req_your_notes => 'Your notes:';

  @override
  String get set_add_property_style => 'Add Property button';

  @override
  String get set_asset_count_positive_only => 'Only show count when there are properties';

  @override
  String get set_asset_count_visibility => 'Property count';

  @override
  String get set_current_location => 'Current location';

  @override
  String get set_default_ibb => 'Ibb (default)';

  @override
  String get set_display => 'Display';

  @override
  String get set_location => 'Location';

  @override
  String get set_reset_location => 'Reset';

  @override
  String get set_search_radius => 'Search radius';

  @override
  String get set_currency => 'Currency';

  @override
  String get set_currency_yer => 'Yemeni Rial (ر.ي)';

  @override
  String get set_currency_sar => 'Saudi Riyal (ر.س)';

  @override
  String get set_currency_usd => 'US Dollar (\$)';

  @override
  String get set_distance_unit => 'Distance unit';

  @override
  String get set_distance_unit_km => 'Kilometers (km)';

  @override
  String get set_distance_unit_miles => 'Miles (mi)';

  @override
  String get set_text_size => 'Text size';

  @override
  String get set_text_size_small => 'Small';

  @override
  String get set_text_size_medium => 'Medium';

  @override
  String get set_text_size_large => 'Large';

  @override
  String get set_default_map_view => 'Default map view';

  @override
  String get set_default_map_view_map => 'Map';

  @override
  String get set_default_map_view_list => 'List';

  @override
  String get map_all => 'All';

  @override
  String get map_all_deals => 'All (sale and rent)';

  @override
  String get map_all_deals_short => 'All (sale/rent)';

  @override
  String get map_all_districts_in => 'All districts in';

  @override
  String get map_all_governorates => 'All governorates 🇾🇪';

  @override
  String get map_all_governorates_plain => 'All governorates';

  @override
  String get map_all_property_types => 'All property types';

  @override
  String get map_all_types => 'All types';

  @override
  String get map_apply_filter => 'Apply filter';

  @override
  String get map_apply_filters => 'Apply filters';

  @override
  String get map_approximate_location_prefix => 'Approximate location based on the center of';

  @override
  String get map_area_label => 'Area (m²)';

  @override
  String get map_area_sqm => 'm² area';

  @override
  String get map_back_home => 'Back to home';

  @override
  String get map_bedrooms => 'bedrooms';

  @override
  String get map_call => 'Call';

  @override
  String get map_cancel => 'Cancel';

  @override
  String get map_cancel_draw => 'Cancel drawing';

  @override
  String get map_check_availability => 'Check availability';

  @override
  String get map_clear_draw => 'Clear drawing';

  @override
  String get map_close => 'Close';

  @override
  String get map_cluster_properties_title => 'Properties at this location';

  @override
  String get map_cluster_property_unit => 'properties';

  @override
  String get map_currency_sar => 'SAR';

  @override
  String get map_currency_yer => 'YER';

  @override
  String get map_deal_type => 'Deal type';

  @override
  String get map_deal_type_search => 'Transaction type';

  @override
  String get map_directions => 'Directions to the property';

  @override
  String get map_directions_google_maps => 'Directions to the property via Google Maps';

  @override
  String get map_district_in => 'District in';

  @override
  String get map_draw_area => 'Draw area';

  @override
  String get map_draw_filter_active => 'Search limited to drawn area';

  @override
  String get map_draw_instruction => 'Touch and drag on the map to draw the area you\'re looking for';

  @override
  String get map_draw_search_area => 'Draw search area';

  @override
  String get map_exact_gps_only => 'Exact GPS coordinates only';

  @override
  String get map_exact_location => 'Exact location pinned on the map';

  @override
  String get map_filter_hint => 'Try adjusting the filters or using less specific keywords';

  @override
  String get map_filter_results => 'Filter results';

  @override
  String get map_filter_title => 'Filter properties on the map';

  @override
  String get map_filters => 'Filters';

  @override
  String get map_filters_active => 'Filters ✓';

  @override
  String get map_final_purchase_price => 'Official final purchase price';

  @override
  String get map_for_rent => 'For rent';

  @override
  String get map_for_sale => 'For sale';

  @override
  String get map_governorate => 'Governorate';

  @override
  String get map_governorate_search => 'Governorate';

  @override
  String get map_hide_approximate => 'Hide properties with approximate locations';

  @override
  String get map_load_error => 'Couldn\'t load the map. You can use the alternative view.';

  @override
  String get map_loading_map => 'Loading map...';

  @override
  String get map_loading_search => 'Searching the database...';

  @override
  String get map_location_missing_message => 'This property isn\'t pinned on the map yet. Please contact the owner to confirm its location.';

  @override
  String get map_main_menu => 'Main menu';

  @override
  String get map_maps_open_error => 'Couldn\'t open Google Maps. Make sure the app is installed or that you\'re online.';

  @override
  String get map_max_price => 'Maximum';

  @override
  String get map_million_abbr => 'M';

  @override
  String get map_min_bedrooms => 'Minimum bedrooms';

  @override
  String get map_min_price => 'Minimum';

  @override
  String get map_no_map_properties => 'No properties to show on the map';

  @override
  String get map_no_matching_properties => 'No matching properties found';

  @override
  String get map_no_max => 'No limit';

  @override
  String get map_no_properties_area_hint => 'Try changing the search area or clearing the filters to see properties in other Yemeni governorates.';

  @override
  String get map_no_properties_in_area => 'No matching properties in this area';

  @override
  String get map_offline_atlas_hint => 'Pinch or use the mouse to zoom in and out';

  @override
  String get map_offline_atlas_title => 'Official Map of the Republic of Yemen (Offline)';

  @override
  String get map_one_bedroom => 'One bedroom';

  @override
  String get map_or_more => 'or more';

  @override
  String get map_per_month => '/month';

  @override
  String get map_price_from => 'From';

  @override
  String get map_price_range => 'Price range';

  @override
  String get map_price_range_search => 'Price range';

  @override
  String get map_price_to => 'To';

  @override
  String get map_properties_available => 'properties available';

  @override
  String get map_property_type => 'Property type';

  @override
  String get map_property_type_search => 'Property type';

  @override
  String get map_rent_discount => 'Special rent discount';

  @override
  String get map_rent_only => 'Rent only';

  @override
  String get map_reset => 'Reset';

  @override
  String get map_reset_filters => 'Reset';

  @override
  String get map_reset_filters_action => 'Reset filters';

  @override
  String get map_result_property_unit => 'properties';

  @override
  String get map_retry => 'Retry';

  @override
  String get map_sale_discount => 'Special sale discount';

  @override
  String get map_sale_only => 'Sale only';

  @override
  String get map_search_button => 'Search';

  @override
  String get map_search_found => 'Found';

  @override
  String get map_search_hint => 'Search by governorate, neighborhood, or property name...';

  @override
  String get map_search_hint_main => 'Search by address, neighborhood, or keywords...';

  @override
  String get map_search_list_view => 'List view';

  @override
  String get map_search_map_view => 'Property map';

  @override
  String get map_search_property_unit => 'properties';

  @override
  String get map_search_results => 'Search results';

  @override
  String get map_search_settings => 'Settings';

  @override
  String get map_search_this_area => 'Search this area';

  @override
  String get map_show_all_governorates => 'Show all Yemeni governorates';

  @override
  String get map_show_list => 'Show list';

  @override
  String get map_show_map => 'Show map';

  @override
  String get map_sort_by => 'Sort by: ';

  @override
  String get map_sort_newest => 'Newest';

  @override
  String get map_sort_price_asc => 'Price: lowest first';

  @override
  String get map_sort_price_desc => 'Price: highest first';

  @override
  String get map_switch_to_satellite => 'Switch to satellite view';

  @override
  String get map_switch_to_streets => 'Switch to street map';

  @override
  String get map_thousand_abbr => 'K';

  @override
  String get map_total_monthly_price => 'Total monthly price';

  @override
  String get map_two_bedrooms => 'Two bedrooms';

  @override
  String get map_type_apartment => 'Apartments';

  @override
  String get map_type_building => 'Buildings';

  @override
  String get map_type_land => 'Land';

  @override
  String get map_type_office => 'Offices';

  @override
  String get map_type_shop => 'Shops';

  @override
  String get map_type_villa => 'Villas & houses';

  @override
  String get map_view_details => 'View details';

  @override
  String get map_whatsapp => 'WhatsApp';

  @override
  String get map_whatsapp_prefix => 'Assalamu alaikum, regarding the property listed on the Yemen Real Estate Portal';

  @override
  String get map_yemen_atlas => 'Map of Yemen 🇾🇪';

  @override
  String get addprop_verified_login_required => 'You must sign in with an email-verified account to publish properties.';

  @override
  String get addprop_ownership_pledge_required => 'You must agree to the ownership pledge to continue.';

  @override
  String get addprop_self_review_title => 'Self-review of the listing';

  @override
  String get addprop_review_intro => 'Please review your listing details carefully before publishing:';

  @override
  String get addprop_review_title_label => 'Title';

  @override
  String get addprop_review_deal_type_label => 'Deal type';

  @override
  String get addprop_review_price_label => 'Price';

  @override
  String get addprop_review_area_label => 'Area';

  @override
  String get addprop_review_location_label => 'Location';

  @override
  String get addprop_review_phone_label => 'Advertiser phone';

  @override
  String get addprop_review_status_label => 'Publishing status';

  @override
  String get addprop_status_private_draft => 'Private draft';

  @override
  String get addprop_status_instant_publish => 'Instant publish (admin account)';

  @override
  String get addprop_status_pending_review => 'Publish request under review';

  @override
  String get addprop_admin_publish_note => 'As the general administrator, this property will be published directly on the platform.';

  @override
  String get addprop_review_policy_note => 'Under the approved publishing policy, your listing is sent to management (General Manager: Mohammed Al-Saqqaf) for review and approval before it appears publicly.';

  @override
  String get addprop_edit_data => 'Edit details';

  @override
  String get addprop_save_draft => 'Save as draft';

  @override
  String get addprop_confirm_publish => 'Confirm and publish listing';

  @override
  String get addprop_submit_request => 'Submit publish request';

  @override
  String get addprop_confirm_email_required => 'You must confirm your email address before publishing the property.';

  @override
  String get addprop_published_success => 'Listing published successfully on the Yemen Real Estate Portal';

  @override
  String get addprop_request_sent_success => 'Publish request sent successfully; it is under management review for approval.';

  @override
  String get addprop_draft_saved_success => 'Listing draft saved successfully';

  @override
  String get addprop_save_error => 'An error occurred while saving the listing';

  @override
  String get addprop_login_required_title => 'Sign-in required';

  @override
  String get addprop_login_required_desc => 'To complete this action, please create an account and verify your email first.';

  @override
  String get addprop_login_required_action => 'Create an account or sign in';

  @override
  String get addprop_new_title => 'Add a new property listing';

  @override
  String get addprop_edit_title => 'Edit property details';

  @override
  String get addprop_intro => 'Enter accurate property details to reach interested buyers efficiently.';

  @override
  String get addprop_section_basic_info => 'Listing and deal information';

  @override
  String get addprop_title_label => 'Listing title *';

  @override
  String get addprop_title_field_name => 'Listing title';

  @override
  String get addprop_title_hint => 'e.g. Apartment for sale in Hadda with deluxe finishing and a strategic location';

  @override
  String get addprop_deal_type_label => 'Deal type *';

  @override
  String get addprop_deal_sale => 'For sale';

  @override
  String get addprop_deal_rent => 'For rent';

  @override
  String get addprop_property_type_label => 'Property type *';

  @override
  String get addprop_section_price_area => 'Price and area';

  @override
  String get addprop_price_label => 'Asking price *';

  @override
  String get addprop_price_field_name => 'Asking price';

  @override
  String get addprop_price_hint => 'e.g. 50000000';

  @override
  String get addprop_currency_label => 'Currency *';

  @override
  String get addprop_area_label => 'Total area (m²) *';

  @override
  String get addprop_area_field_name => 'Area';

  @override
  String get addprop_area_hint => 'e.g. 180';

  @override
  String get addprop_bedrooms_label => 'Number of rooms';

  @override
  String get addprop_na_hint => '0 if not applicable';

  @override
  String get addprop_bathrooms_label => 'Bathrooms';

  @override
  String get addprop_section_location => 'Geographic location';

  @override
  String get addprop_governorate_label => 'Governorate *';

  @override
  String get addprop_district_label => 'District or neighborhood *';

  @override
  String get addprop_district_field_name => 'Neighborhood or district';

  @override
  String get addprop_district_hint => 'e.g. Hadda, Bayt Bous, Al-Ma\'la...';

  @override
  String get addprop_common_districts_intro => 'Popular neighborhoods and districts in';

  @override
  String get addprop_common_districts_quick_pick => '(tap for quick selection):';

  @override
  String get addprop_address_details_label => 'Address details and nearby landmarks';

  @override
  String get addprop_address_hint => 'e.g. Near Al-Rawishan roundabout - Street 14';

  @override
  String get addprop_map_picker_label => 'Pinpoint the location on the map (tap the map to set the place):';

  @override
  String get addprop_location_pinned => 'Location pinned:';

  @override
  String get addprop_map_tap_hint => 'Tap any point on the map to set the exact property location';

  @override
  String get addprop_sqm_unit => 'm²';

  @override
  String get addprop_section_description_photos => 'Description and photos';

  @override
  String get addprop_description_label => 'Full property description *';

  @override
  String get addprop_description_field_name => 'Description';

  @override
  String get addprop_description_hint => 'Include the property details, features, finishes, entrances, and available services...';

  @override
  String get addprop_photos_label => 'Property photos (maximum 5 MB per image)';

  @override
  String get addprop_add_photos => 'Add photos';

  @override
  String get addprop_no_images_hint => 'No photos selected yet. You can add photos to attract more buyers.';

  @override
  String get addprop_section_contact_pledge => 'Contact details and pledge';

  @override
  String get addprop_phone_label => 'Contact phone number *';

  @override
  String get addprop_whatsapp_label => 'WhatsApp number';

  @override
  String get addprop_whatsapp_hint => 'Optional for quick contact';

  @override
  String get addprop_pledge_text => 'I affirm and pledge that all data and information in this listing is accurate, and that I hold the legal and lawful right to market or publish it.';

  @override
  String get addprop_section_contract => 'Customize and print the Yemen property contract';

  @override
  String get addprop_contract_intro => 'You can customize the contract terms and save your approved template to print and notarize when the deal is completed with the tenant or buyer.';

  @override
  String get addprop_customize_contract => 'Customize contract clauses and print';

  @override
  String get addprop_preview_publish => 'Preview and publish listing';

  @override
  String get detail_reason_inaccurate => 'Inaccurate or misleading information';

  @override
  String get detail_reason_price => 'Price does not match the market';

  @override
  String get detail_reason_duplicate => 'Duplicate property or already sold';

  @override
  String get detail_reason_images => 'Inappropriate or mismatched photos';

  @override
  String get detail_reason_fraud => 'Impersonation or fraud';

  @override
  String get detail_reason_other => 'Other reason';

  @override
  String get detail_report_title => 'Report a violating listing';

  @override
  String get detail_report_intro => 'Help us keep the platform trustworthy by reporting any violation.';

  @override
  String get detail_report_reason_label => 'Report reason *';

  @override
  String get detail_report_details_label => 'Additional details (optional)';

  @override
  String get detail_report_details_hint => 'Describe the reason in detail...';

  @override
  String get detail_cancel => 'Cancel';

  @override
  String get detail_report_submitted => 'Your report was received successfully and will be reviewed by the management team.';

  @override
  String get detail_submit_report => 'Submit report';

  @override
  String get detail_loading => 'Loading property details...';

  @override
  String get detail_browse_properties => 'Browse available properties';

  @override
  String get detail_home => 'Home';

  @override
  String get detail_properties => 'Properties';

  @override
  String get detail_auth_prompt_message => 'To complete this action, please create an account and verify your email first.';

  @override
  String get detail_publish_date => 'Published on:';

  @override
  String get detail_send_rental_request => 'Send rental request';

  @override
  String get detail_contract_preview => 'Preview, customize and print the contract';

  @override
  String get detail_report_action => 'Report a violation';

  @override
  String get detail_link_copied => 'Property link copied for sharing';

  @override
  String get detail_share_ad => 'Share listing';

  @override
  String get detail_total_area => 'Total area';

  @override
  String get detail_property_type => 'Property type';

  @override
  String get detail_bedrooms => 'Number of bedrooms';

  @override
  String get detail_rooms_unit => 'rooms';

  @override
  String get detail_bathrooms => 'Bathrooms';

  @override
  String get detail_bathrooms_unit => 'bathrooms';

  @override
  String get detail_views_unit => 'views';

  @override
  String get detail_publishing_method => 'Publishing method';

  @override
  String get detail_self_review_published => 'Self-declared review';

  @override
  String get detail_description_title => 'Property details and description';

  @override
  String get detail_map_section_title => 'Property location on the map';

  @override
  String get detail_open_full_map => 'Open the full interactive map';

  @override
  String get detail_directions_google_maps => 'Directions (Google Maps)';

  @override
  String get detail_views_label => 'View count';

  @override
  String get map_load_more => 'Load more properties';

  @override
  String get sh_header_settings => 'Settings';

  @override
  String get sh_header_add_property => 'Add your property';

  @override
  String get sh_header_add_property_free => 'Add your property for free';

  @override
  String get sh_auth_prompt_message => 'To complete this action, please create an account and verify your email first.';

  @override
  String get sh_nav_home => 'Home';

  @override
  String get sh_nav_my_properties => 'My Properties';

  @override
  String get sh_manage_properties_prompt => 'To manage your properties, please sign in first.';

  @override
  String get sh_brand_name => 'Yemen Real Estate Portal';

  @override
  String get sh_drawer_admin_greeting => 'General Manager Dashboard';

  @override
  String get sh_drawer_user_greeting => 'Welcome to your account';

  @override
  String get sh_drawer_tagline => 'Yemen\'s leading real estate platform';

  @override
  String get sh_drawer_map_title => 'Property map';

  @override
  String get sh_drawer_map_subtitle => 'Search by price directly on the map of Yemen';

  @override
  String get sh_drawer_search => 'Search properties';

  @override
  String get sh_drawer_favorites => 'Favorite properties';

  @override
  String get sh_drawer_my_properties => 'My listed properties';

  @override
  String get sh_drawer_my_requests => 'Rental requests';

  @override
  String get sh_drawer_profile => 'Profile';

  @override
  String get sh_drawer_admin_panel => 'Admin dashboard';

  @override
  String get sh_logout => 'Sign out';

  @override
  String get sh_login_register => 'Sign in / Create account';

  @override
  String get sh_drawer_initial_fallback => 'U';

  @override
  String get sh_nav_search => 'Search';

  @override
  String get sh_nav_map => 'Map';

  @override
  String get sh_nav_search_map => 'Search & Map';

  @override
  String get sh_nav_favorites => 'Favorites';

  @override
  String get sh_rail_my_properties => 'My properties';

  @override
  String get sh_rail_admin => 'Admin panel';

  @override
  String get sh_rail_login => 'Sign in / Register';

  @override
  String get sh_back => 'Back';

  @override
  String get sh_footer_republic => 'Republic of Yemen';

  @override
  String get sh_footer_tagline_desktop => 'The leading national platform for buying, selling, and renting properties across all Yemeni governorates, with trusted and direct connections between advertisers and seekers.';

  @override
  String get sh_footer_quick_links => 'Quick links';

  @override
  String get sh_footer_properties_sale => 'Properties for sale';

  @override
  String get sh_footer_properties_rent => 'Properties for rent';

  @override
  String get sh_footer_add_listing => 'Post your listing for free';

  @override
  String get sh_footer_my_account => 'My account';

  @override
  String get sh_footer_my_listings => 'My listings';

  @override
  String get sh_footer_contact => 'Contact us';

  @override
  String get sh_footer_tagline_mobile => 'Yemen Real Estate Portal — your trusted platform for renting, buying, and selling properties in Yemen.';

  @override
  String get sh_auth_login_required => 'Sign in required';

  @override
  String get sh_auth_info_note => 'Browsing properties and services is free for guests, while protected actions require an email-verified account to safeguard your rights.';

  @override
  String get sh_login => 'Sign in';

  @override
  String get sh_auth_register_new => 'Create a new account';

  @override
  String get sh_auth_continue_guest => 'Continue browsing as a guest';

  @override
  String get sh_error_unexpected => 'An unexpected error occurred';

  @override
  String get sh_retry => 'Retry';

  @override
  String get sh_property_featured => 'Featured';

  @override
  String get sh_property_rooms => 'rooms';

  @override
  String get sh_property_bathrooms => 'bathrooms';

  @override
  String get sh_contact_unavailable => 'Direct contact details are not available for this listing at the moment.';

  @override
  String get sh_contact_whatsapp => 'Chat on WhatsApp';

  @override
  String get sh_contact_call => 'Call now';

  @override
  String get sh_contact_whatsapp_error => 'Couldn\'t open WhatsApp. Please make sure it\'s installed or call instead.';

  @override
  String get sh_contact_call_error_prefix => 'Couldn\'t start the phone call. Phone number:';

  @override
  String get sh_router_not_found => 'Page not found';

  @override
  String get sh_router_404_title => 'Sorry, the page you requested doesn\'t exist (404)';

  @override
  String get sh_router_404_description => 'Check the link or return to the home page';

  @override
  String get sh_router_404_action => 'Back to home';

  @override
  String get sh_router_select_property => 'Please select a property first';

  @override
  String get sh_back_exit_snackbar => 'Press again to exit the app';

  @override
  String get sys_rate_limit => 'Too many requests recently. Please wait one minute before requesting another confirmation email to avoid being blocked.';

  @override
  String get sys_email_not_confirmed => 'Your email address has not been confirmed yet. Please open your inbox and click the activation link to continue.';

  @override
  String get sys_link_expired => 'The activation link has expired or has already been used. Please request a new link.';

  @override
  String get sys_user_exists => 'This email address is already registered. Please sign in instead of creating a new account.';

  @override
  String get sys_invalid_credentials => 'Invalid email or password.';

  @override
  String get sys_weak_password => 'Password must be at least 8 characters.';

  @override
  String get sys_network_error => 'Unable to connect to the server. Please check your internet connection and try again.';

  @override
  String get sys_session_expired => 'Your session has expired. Please sign in again.';

  @override
  String get sys_permission_denied => 'You do not have permission to perform this action.';

  @override
  String get sys_unknown_error => 'An error occurred while processing the request. Please try again later.';

  @override
  String sys_required_field(Object fieldName) {
    return 'Please enter $fieldName';
  }

  @override
  String get sys_required => 'This field is required';

  @override
  String get sys_enter_email => 'Please enter your email address';

  @override
  String get sys_invalid_email => 'Invalid email format';

  @override
  String get sys_enter_password => 'Please enter your password';

  @override
  String get sys_weak_password_long => 'Password must be at least 8 letters or numbers to keep your account secure';

  @override
  String get sys_enter_phone => 'Please enter a contact phone number';

  @override
  String get sys_invalid_phone => 'Invalid phone number (example: 770000000)';

  @override
  String get sys_positive_number => 'Please enter a valid positive number';

  @override
  String get sys_non_negative_number => 'Please enter a valid number (0 or more)';

  @override
  String get sys_login_failed => 'Sign in failed';

  @override
  String get sys_signup_failed => 'Account creation failed';

  @override
  String get sys_enter_email_first => 'Please enter your email address first';

  @override
  String sys_resend_wait(Object remaining) {
    return 'Please wait $remaining seconds before requesting another activation link to avoid duplicate requests.';
  }

  @override
  String get sys_property_not_found => 'Property not found';

  @override
  String get sys_image_too_large => 'Image size exceeds the allowed limit (5 MB)';

  @override
  String get sys_unsupported_image_format => 'Unsupported image format. Supported formats: JPG, PNG, WEBP';

  @override
  String sys_upload_failed(Object error) {
    return 'Failed to upload image: $error';
  }

  @override
  String misc_whatsapp_inquiry(Object propertyId, Object propertyTitle) {
    return 'Hello, regarding the property listed on Yemen Real Estate Portal: \"$propertyTitle\" (ID: $propertyId), I would like to ask about the details.';
  }

  @override
  String get misc_area_unit => 'm²';

  @override
  String get misc_verified_advertiser => 'Verified advertiser';

  @override
  String get csv_id => 'ID';

  @override
  String get csv_property_title => 'Property title';

  @override
  String get csv_deal_type => 'Deal type';

  @override
  String get csv_property_type => 'Property type';

  @override
  String get csv_city => 'City';

  @override
  String get csv_district => 'District';

  @override
  String get csv_price => 'Price';

  @override
  String get csv_currency => 'Currency';

  @override
  String get csv_area => 'Area (m²)';

  @override
  String get csv_status => 'Status';

  @override
  String get csv_publish_date => 'Publish date';

  @override
  String get csv_contact_phone => 'Contact phone';

  @override
  String get csv_request_number => 'Request number';

  @override
  String get csv_tenant_name => 'Tenant name';

  @override
  String get csv_phone => 'Phone number';

  @override
  String get csv_requested_start => 'Requested start date';

  @override
  String get csv_admin_notes => 'Admin notes';

  @override
  String get csv_request_date => 'Request date';

  @override
  String get csv_liable_party => 'Liable party';

  @override
  String get csv_seller_amount => 'Seller amount';

  @override
  String get csv_buyer_amount => 'Buyer amount';

  @override
  String get csv_total_commission => 'Total commission';

  @override
  String get csv_settlement_status => 'Settlement status';

  @override
  String get csv_settlement_method => 'Settlement method';

  @override
  String get csv_registration_date => 'Registration date';

  @override
  String get csv_notes => 'Notes';

  @override
  String get misc_owner => 'Owner';

  @override
  String get misc_listed_property => 'Listed property';

  @override
  String get misc_user => 'User';

  @override
  String get dash_map_cta_title => 'Explore Yemeni properties on the interactive map 🇾🇪';

  @override
  String get dash_map_cta_subtitle => 'Browse prices and locations directly in Sanaa, Ibb, Taiz, and all governorates';
}
