// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_name => 'البوابة العقارية';

  @override
  String get app_name_english => 'Yemen Real Estate Portal';

  @override
  String get title_dashboard => 'الرئيسية';

  @override
  String get title_my_properties => 'ممتلكاتي';

  @override
  String get title_settings => 'الإعدادات';

  @override
  String get title_add_property => 'إضافة عقار';

  @override
  String get header_add_property => 'أضف عقارك';

  @override
  String get header_add_property_free => 'أضف عقارك مجاناً';

  @override
  String get header_settings => 'الإعدادات';

  @override
  String get bottom_home => 'الرئيسية';

  @override
  String get bottom_my_properties => 'ممتلكاتي';

  @override
  String get dashboard_search_hint => 'ابحث بالعنوان، الحي، أو الكلمات الدلالية...';

  @override
  String get search_button => 'بحث';

  @override
  String get filter_button => 'الفلاتر';

  @override
  String get filter_save => 'حفظ';

  @override
  String get filter_reset => 'إعادة تعيين';

  @override
  String get city_dropdown => 'اختر المدينة';

  @override
  String get district_dropdown => 'اختر الحي/المنطقة';

  @override
  String get deal_type => 'نوع الصفقة';

  @override
  String get deal_sale => 'للبيع';

  @override
  String get deal_rent => 'للإيجار';

  @override
  String get deal_all => 'الكل (بيع/إيجار)';

  @override
  String get property_type => 'نوع العقار';

  @override
  String get property_type_all => 'جميع الأنواع';

  @override
  String get draw_area => 'رسم منطقة';

  @override
  String get satellite => 'الأقمار الصناعية';

  @override
  String get map => 'خريطة';

  @override
  String get list_view => 'عرض القائمة';

  @override
  String get asset_count => 'عقار';

  @override
  String get asset_count_plural => 'عقارات';

  @override
  String get asset_zero => 'لا توجد عقارات';

  @override
  String get asset_count_always => 'إظهار عدد العقارات دائماً';

  @override
  String get add_property_style_outline => 'زر Outline على الصفحة الرئيسية';

  @override
  String get add_property_style_fab => 'FAB أعلى زر الخريطة';

  @override
  String get location_permission_title => 'السماح بالموقع';

  @override
  String get location_permission_message => 'أريد العثور على العقارات القريبة منك. نرجو منح permission للوصول إلى موقعك.';

  @override
  String get location_allow => 'السماح';

  @override
  String get location_deny => 'لا الآن';

  @override
  String location_city(Object city) {
    return 'المدينة: $city';
  }

  @override
  String get language => 'اللغة';

  @override
  String get language_ar => 'العربية';

  @override
  String get language_en => 'English';

  @override
  String get theme => 'المظهر';

  @override
  String get theme_system => 'النظام';

  @override
  String get theme_light => 'فاتح';

  @override
  String get theme_dark => 'داكن';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get notifications_on => 'تشغيل الإشعارات';

  @override
  String get about => 'حول البرنامج';

  @override
  String about_version(Object version) {
    return 'الإصدار: $version';
  }

  @override
  String get about_privacy => 'سياسة الخصوصية';

  @override
  String get about_privacy_body => 'نحن نحترم خصوصيتك ولا نشارك بياناتك الشخصية مع أي طرف ثالث دون موافقتك، وتُستخدم بياناتك فقط لتقديم خدمات المنصة وتحسينها.';

  @override
  String get about_terms => 'شروط الاستخدام';

  @override
  String get about_terms_body => 'باستخدامك للمنصة فإنك توافق على الشروط والأحكام المنظمة لاستخدام الخدمة، بما في ذلك دقة بيانات الإعلانات ومسؤولية المعلن عن محتواها.';

  @override
  String get about_contact => 'تواصل معنا';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get my_requests => 'طلبات الاستئجار';

  @override
  String get my_properties_list => 'عقاراتي المعروضة';

  @override
  String get admin_panel => 'لوحة الإدارة الشاملة';

  @override
  String get footer_contact => 'اتصل بنا';

  @override
  String get footer_support_email => 'support@yemenrealestate.local';

  @override
  String get footer_phone => '+967 770 000 000';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get no_results => 'لا توجد نتائج';

  @override
  String get error_occurred => 'حدث خطأ';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get success => 'نجح';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get search => 'بحث';

  @override
  String get near_you => 'قريب منك';

  @override
  String get nearby_properties => 'العقارات القريبة منك';

  @override
  String get nearby_map => 'الخريطة القريبة منك';

  @override
  String get draw_area_button => 'رسم منطقة';

  @override
  String get offline_map => 'خريطة اليمن 🇾🇪';

  @override
  String get all_governorates => 'كافة المحافظات 🇾🇪';

  @override
  String get offline_atlas_button => 'عرض القائمة';

  @override
  String get add_property_prompt => 'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.';

  @override
  String get manage_properties_prompt => 'لإدارة عقاراتك، يرجى تسجيل الدخول أولاً.';

  @override
  String get confirm_logout => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get loading_properties => 'جاري تحميل العقارات...';

  @override
  String properties_available(Object count) {
    return '$count عقار متاح';
  }

  @override
  String get map_offline_button => 'الخريطة';

  @override
  String get satellite_toggle => 'الأقمار الصناعية';

  @override
  String get map_tools => 'أدوات الخريطة';

  @override
  String get property_details => 'تفاصيل العقار';

  @override
  String get property_price => 'السعر';

  @override
  String get property_location => 'الموقع';

  @override
  String get property_area => 'المساحة';

  @override
  String get property_bedrooms => 'غرف النوم';

  @override
  String get property_bathrooms => 'الحمامات';

  @override
  String get property_type_apt => 'شقة';

  @override
  String get property_type_villa => 'فيلا';

  @override
  String get property_type_land => 'أرض';

  @override
  String get property_type_shop => 'محل';

  @override
  String get status_published => 'منشور';

  @override
  String get status_pending => 'قيد المراجعة';

  @override
  String get status_draft => 'مسودة';

  @override
  String get status_rejected => 'مرفوض';

  @override
  String get contact_owner => 'تواصل مع المالك';

  @override
  String get contact_agent => 'تواصل مع الوسيط';

  @override
  String get send_message => 'إرسال رسالة';

  @override
  String get message_sent => 'تم الإرسال';

  @override
  String get save_favorite => 'إضافة للمفضلة';

  @override
  String get remove_favorite => 'إزالة من المفضلة';

  @override
  String get share => 'مشاركة';

  @override
  String get print => 'طباعة';

  @override
  String get download => 'تحميل';

  @override
  String get view_on_map => 'عرض على الخريطة';

  @override
  String get search_this_area => 'البحث في هذه المنطقة';

  @override
  String get select_city => 'اختر المدينة';

  @override
  String get select_district => 'اختر الحي';

  @override
  String get no_properties_found => 'لم يتم العثور على عقارات';

  @override
  String get expand_map => 'توسيع الخريطة';

  @override
  String get collapse_map => 'تصغير الخريطة';

  @override
  String get favorite_properties => 'المفضلة';

  @override
  String get property_requests => 'طلبات العقارات';

  @override
  String get create_request => 'إنشاء طلب';

  @override
  String get my_requests_empty => 'لا توجد طلبات';

  @override
  String get admin_dashboard => 'لوحة الإدارة';

  @override
  String get admin_users => 'المستخدمون';

  @override
  String get admin_properties => 'العقارات';

  @override
  String get admin_requests => 'الطلبات';

  @override
  String get admin_analytics => 'الإحصائيات';

  @override
  String get settings_saved => 'تم حفظ الإعدادات';

  @override
  String get reset_settings => 'إعادة تعيين الإعدادات';

  @override
  String get require_auth => 'تسجيل الدخول مطلوب';

  @override
  String get login_required => 'يجب تسجيل الدخول أولاً';

  @override
  String get notifications_empty => 'لا توجد إشعارات';

  @override
  String get clear_all => 'مسح الكل';

  @override
  String get close => 'إغلاق';

  @override
  String get mark_as_read => 'تحديد كمقروء';

  @override
  String get back => 'العودة';

  @override
  String get home => 'الرئيسية';

  @override
  String get map_tab => 'الخريطة';

  @override
  String get search_tab => 'البحث';

  @override
  String get profile_tab => 'الملف الشخصي';

  @override
  String get logout_confirmation => 'تأكيد تسجيل الخروج';

  @override
  String get session_expired => 'انتهت الجلسة، يرجى تسجيل الدخول novamente';

  @override
  String get internet_required => 'يحتاج التطبيق إلى اتصال بالإنترنت';

  @override
  String get try_again => 'حاول مرة أخرى';

  @override
  String get contact_support => 'تواصل مع الدعم';

  @override
  String get support_email => 'support@yemenrealestate.local';

  @override
  String get terms_link => 'شروط الاستخدام';

  @override
  String get privacy_link => 'سياسة الخصوصية';

  @override
  String get login_enter_email_first => 'يرجى كتابة البريد الإلكتروني أولاً';

  @override
  String get login_verification_resent => 'تم إرسال رابط تأكيد جديد إلى بريدك بنجاح. يرجى مراجعة صندوق الوارد.';

  @override
  String get login_resend_failed => 'تعذر إعادة الإرسال حالياً';

  @override
  String get login_demo_admin_filled => 'تمت كتابة بريد المدير العام فقط. يرجى إدخال كلمة المرور يدوياً للمتابعة بأمان';

  @override
  String get login_demo_user_filled => 'تمت كتابة بريد المستخدم التجريبي. يرجى إدخال كلمة المرور للمتابعة';

  @override
  String get login_title => 'تسجيل الدخول';

  @override
  String get login_submit => 'تسجيل الدخول';

  @override
  String get login_subtitle => 'أهلاً بك مجدداً في بوابة اليمن العقارية';

  @override
  String get login_sending => 'جارٍ الإرسال...';

  @override
  String get login_resend_now => 'إعادة إرسال رابط التفعيل الآن إلى البريد';

  @override
  String get login_email => 'البريد الإلكتروني';

  @override
  String get login_password => 'كلمة المرور';

  @override
  String get login_remember_me => 'تذكر البريد';

  @override
  String get login_forgot_password => 'نسيت كلمة المرور؟';

  @override
  String get login_no_account => 'ليس لديك حساب؟';

  @override
  String get login_create_account => 'إنشاء حساب جديد';

  @override
  String get login_resend_prompt => 'لم يصلك رابط التفعيل؟ إعادة الإرسال إلى البريد';

  @override
  String get login_quick_demo => 'تسجيل دخول سريع بحسابات النظام:';

  @override
  String get login_demo_admin => 'المدير العام (إيميل فقط)';

  @override
  String get login_demo_user => 'حساب معلن (إيميل فقط)';

  @override
  String get register_confirm_title => 'تأكيد وتفعيل الحساب';

  @override
  String get register_confirm_message => 'تم إرسال رسالة تأكيد إلى بريدك الإلكتروني. يرجى مراجعة صندوق الوارد والضغط على رابط التأكيد لإكمال إنشاء حسابك.';

  @override
  String get register_open_inbox => 'يرجى فتح صندوق الوارد في بريدك الإلكتروني والنقر على رابط التفعيل المرسل لإكمال التحقق وتفعيل حسابك.';

  @override
  String get register_warning => 'تنبيه: لن يتم تسجيل دخولك أو تفعيل الصلاحيات إلا بعد الضغط على الرابط في بريدك.';

  @override
  String get register_resend_success => 'تمت إعادة إرسال رابط التأكيد بنجاح إلى بريدك';

  @override
  String get register_resend_failed => 'تعذر إعادة الإرسال حالياً';

  @override
  String get register_resending => 'جارٍ إعادة الإرسال...';

  @override
  String get register_resend_prompt => 'لم تصلك الرسالة؟ إعادة إرسال رابط التفعيل';

  @override
  String get register_browse_guest => 'تصفح كزائر';

  @override
  String get register_go_login => 'الانتقال لتسجيل الدخول';

  @override
  String get register_title => 'إنشاء حساب جديد';

  @override
  String get register_subtitle => 'انضم إلى مجتمع العقارات الأول في اليمن مجاناً';

  @override
  String get register_go_login_now => 'الانتقال لتسجيل الدخول الآن';

  @override
  String get register_full_name_required => 'الاسم الكامل *';

  @override
  String get register_full_name => 'الاسم الكامل';

  @override
  String get register_name_hint => 'أدخل اسمك الثلاثي أو الرباعي';

  @override
  String get register_email_required => 'البريد الإلكتروني *';

  @override
  String get register_phone_required => 'رقم الهاتف للتواصل *';

  @override
  String get register_phone_hint => 'مثال: 770000000';

  @override
  String get register_password_required => 'كلمة المرور *';

  @override
  String get register_password_hint => 'لا تقل عن 8 خانات (أرقام وحروف لضمان الحماية)';

  @override
  String get register_submit => 'تسجيل حساب جديد';

  @override
  String get register_have_account => 'لديك حساب بالفعل؟';

  @override
  String get register_login_link => 'تسجيل الدخول';

  @override
  String get forgot_link_sent => 'تم إرسال رابط الاستعادة';

  @override
  String get forgot_check_inbox => 'تحقق من صندوق الوارد في بريدك الإلكتروني واتبع التعليمات لتعيين كلمة مرور جديدة.';

  @override
  String get forgot_back_to_login => 'العودة لتسجيل الدخول';

  @override
  String get forgot_title => 'استعادة كلمة المرور';

  @override
  String get forgot_instructions => 'أدخل بريدك الإلكتروني المسجل وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.';

  @override
  String get forgot_email => 'البريد الإلكتروني';

  @override
  String get forgot_send_link => 'إرسال رابط الاستعادة';

  @override
  String get forgot_return_to_login => 'الرجوع لتسجيل الدخول';

  @override
  String get callback_expired_message => 'رابط التفعيل منتهي الصلاحية أو تم استخدامه مسبقاً. يرجى طلب رابط جديد للمتابعة.';

  @override
  String get callback_link_error => 'تعذر إتمام التحقق من الرابط، يرجى المحاولة لاحقاً.';

  @override
  String get callback_enter_email_first => 'يرجى إدخال البريد الإلكتروني أولاً';

  @override
  String get callback_resend_success => 'تم إرسال رابط تفعيل جديد بنجاح إلى بريدك';

  @override
  String get callback_resend_failed => 'تعذر إعادة الإرسال حالياً';

  @override
  String get callback_verifying => 'جارٍ التحقق من تفعيل البريد الإلكتروني...';

  @override
  String get callback_waiting => 'يرجى الانتظار بضع ثوانٍ بينما نؤكد حسابك لدى خوادم بوابة اليمن العقارية.';

  @override
  String get callback_success_title => 'تم تفعيل بريدك الإلكتروني بنجاح!';

  @override
  String get callback_success_message => 'أهلاً بك في بوابة اليمن العقارية. تم تأكيد ملكية بريدك الإلكتروني بنجاح وأصبح حسابك نشطاً بالكامل الآن.';

  @override
  String get callback_continue_operation => 'المتابعة لإكمال عمليتك';

  @override
  String get callback_continue_home => 'المتابعة إلى الصفحة الرئيسية';

  @override
  String get callback_go_home => 'الذهاب إلى الصفحة الرئيسية';

  @override
  String get callback_login_credentials => 'تسجيل الدخول بالبريد وكلمة المرور';

  @override
  String get callback_expired_title => 'رابط التفعيل منتهي أو مستخدم مسبقاً';

  @override
  String get callback_cannot_confirm => 'تعذر تأكيد الرابط';

  @override
  String get callback_expired_fallback => 'انتهت صلاحية هذا الرابط أو تم تأكيد الحساب به بالفعل. يمكنك تجربة تسجيل الدخول أو طلب رابط تفعيل جديد.';

  @override
  String get callback_error_fallback => 'حدث خطأ أثناء معالجة رابط التفعيل، يرجى إعادة المحاولة.';

  @override
  String get callback_resend_email_label => 'البريد الإلكتروني لإعادة الإرسال';

  @override
  String get callback_sending => 'جارٍ الإرسال...';

  @override
  String get callback_send_new_link => 'إرسال رابط تفعيل جديد';

  @override
  String get callback_back_login => 'العودة إلى صفحة تسجيل الدخول';

  @override
  String get admin_restricted_title => 'منطقة إدارية محمية';

  @override
  String get admin_restricted_desc => 'هذه الصفحة مخصصة لمديري بوابة اليمن العقارية فقط، وليس لديك الصلاحية الكافية لدخولها.';

  @override
  String get admin_back_home => 'العودة للرئيسية';

  @override
  String get admin_title => 'لوحة الإدارة والتحكم';

  @override
  String get admin_subtitle => 'إدارة المنصة، العقارات، طلبات الاستئجار، وسجلات العمولات اليدوية.';

  @override
  String get admin_general_manager => 'المسؤول العام: محمد السقاف';

  @override
  String get admin_loading_stats => 'جاري تحميل الإحصائيات...';

  @override
  String get admin_tab_properties => 'إدارة العقارات';

  @override
  String get admin_tab_requests => 'طلبات الاستئجار';

  @override
  String get admin_tab_commissions => 'سجلات العمولات';

  @override
  String get admin_tab_reports => 'بلاغات المخالفات';

  @override
  String get admin_tab_users => 'المستخدمين (مشفر)';

  @override
  String get admin_print_pdf => 'طباعة تقرير شامل PDF للقسم';

  @override
  String get admin_total_properties => 'إجمالي العقارات';

  @override
  String get admin_published_properties => 'العقارات المنشورة';

  @override
  String get admin_pending_review => 'معلقة للمراجعة';

  @override
  String get admin_total_users => 'إجمالي المستخدمين';

  @override
  String get admin_commission_records => 'سجلات العمولات';

  @override
  String get admin_pending_title => 'طلبات العقارات بانتظار الموافقة';

  @override
  String get admin_awaiting_review => 'بانتظار المراجعة';

  @override
  String get admin_review_complete => 'مكتمل ومراجع';

  @override
  String get admin_pending_desc => 'مراجعة العقارات المضافة من قبل المستخدمين واعتماد نشرها للعامة على الخريطة وقائمة البحث.';

  @override
  String get admin_refresh_requests => 'تحديث قائمة الطلبات';

  @override
  String get admin_no_pending => 'لا توجد عقارات بانتظار الموافقة حالياً — كافة طلبات النشر تم مراجعتها واعتمادها.';

  @override
  String get admin_loading_pending => 'جاري جلب طلبات النشر المعلقة...';

  @override
  String get admin_for_rent => 'للإيجار';

  @override
  String get admin_for_sale => 'للبيع';

  @override
  String get admin_sqm => 'م²';

  @override
  String get admin_rooms => 'غرف';

  @override
  String get admin_listing_owner => 'صاحب الإعلان';

  @override
  String get admin_platform_user => 'مستخدم المنصة';

  @override
  String get admin_approve_publish => 'موافقة ونشر الإعلان';

  @override
  String get admin_reject_request => 'رفض الطلب';

  @override
  String get admin_view_full_details => 'عرض التفاصيل الكاملة';

  @override
  String get admin_approved_prefix => 'تمت الموافقة على نشر عقار \"';

  @override
  String get admin_approved_suffix => '\" بنجاح، وأصبح ظاهراً للعامة في البحث والخريطة.';

  @override
  String get admin_approve_failed => 'فشل اعتماد نشر العقار';

  @override
  String get admin_default_reject_reason => 'المعلومات غير مكتملة أو غير مطابقة لسياسة النشر في المنصة.';

  @override
  String get admin_reject_dialog_title => 'رفض طلب نشر العقار';

  @override
  String get admin_reject_reason_prompt => 'يرجى كتابة سبب رفض الإعلان ليتم إبلاغ صاحب العقار به:';

  @override
  String get admin_reject_hint => 'اكتب سبب الرفض هنا...';

  @override
  String get admin_cancel => 'إلغاء';

  @override
  String get admin_confirm_reject => 'تأكيد الرفض';

  @override
  String get admin_reject_saved => 'تم تسجيل رفض الإعلان وحفظ السبب بنجاح.';

  @override
  String get admin_reject_failed => 'فشل تسجيل الرفض';

  @override
  String get admin_properties_list_title => 'قائمة العقارات والتحكم بالنشر';

  @override
  String get admin_export_csv => 'تصدير CSV';

  @override
  String get admin_export_properties_title => 'تصدير بيانات العقارات';

  @override
  String get admin_no_properties => 'لا توجد عقارات حالياً';

  @override
  String get admin_status_label => 'الحالة';

  @override
  String get admin_approve_tooltip => 'قبول ونشر الإعلان (محمد السقاف)';

  @override
  String get admin_approved_by_admin => 'تم قبول ونشر العقار بواسطة المسؤول: محمد السقاف';

  @override
  String get admin_rejected_by_admin_review => 'مرفوض من قبل الإدارة بعد المراجعة';

  @override
  String get admin_rejected_status_updated => 'تم رفض طلب النشر وتحديث الحالة';

  @override
  String get admin_approve_publish_menu => 'قبول واعتماد النشر';

  @override
  String get admin_hide_listing => 'إخفاء الإعلان';

  @override
  String get admin_republish => 'إعادة نشر';

  @override
  String get admin_archive => 'أرشفة';

  @override
  String get admin_delete_permanent => 'حذف نهائي';

  @override
  String get admin_requests_list_title => 'طلبات الاستئجار والمتابعة';

  @override
  String get admin_export_requests_title => 'تصدير طلبات الاستئجار';

  @override
  String get admin_no_requests => 'لا توجد طلبات استئجار مسجلة';

  @override
  String get admin_phone_label => 'هاتف';

  @override
  String get admin_property_label => 'العقار';

  @override
  String get admin_status_under_review => 'قيد المراجعة';

  @override
  String get admin_status_contacted => 'تم التواصل';

  @override
  String get admin_status_provisional => 'مقبول مبدئياً';

  @override
  String get admin_status_rejected => 'مرفوض';

  @override
  String get admin_status_completed => 'مكتمل';

  @override
  String get admin_commissions_list_title => 'سجلات العمولة الإدارية (يدوية)';

  @override
  String get admin_add_commission => 'تسجيل عمولة';

  @override
  String get admin_export_commissions_title => 'تصدير سجلات العمولات';

  @override
  String get admin_no_commissions => 'لا توجد سجلات عمولة مسجلة';

  @override
  String get admin_commissions_desc => 'سجل العمولات وفق القرارات المعتمدة (تسجيل يدوي بحسب الاتفاق)';

  @override
  String get admin_registered_property => 'عقار مسجل';

  @override
  String get admin_liable_party => 'المتحمل';

  @override
  String get admin_settlement_method => 'طريقة التسوية';

  @override
  String get admin_awaiting_collection => 'بانتظار التحصيل';

  @override
  String get admin_status_paid => 'تم السداد';

  @override
  String get admin_status_due => 'مستحق';

  @override
  String get admin_status_cancelled => 'ملغى';

  @override
  String get admin_commission_modal_title => 'تسجيل سجل عمولة يدوي';

  @override
  String get admin_commission_property_title => 'عنوان العقار أو المعرف *';

  @override
  String get admin_commission_property_hint => 'مثال: فيلا بيت بوس';

  @override
  String get admin_commission_liable => 'الطرف المتحمل للعمولة *';

  @override
  String get admin_liable_both => 'كلاهما (البائع والمشتري)';

  @override
  String get admin_liable_seller => 'البائع فقط';

  @override
  String get admin_liable_buyer => 'المشتري فقط';

  @override
  String get admin_seller_amount => 'مبلغ البائع';

  @override
  String get admin_buyer_amount => 'مبلغ المشتري';

  @override
  String get admin_currency => 'العملة';

  @override
  String get admin_commission_notes => 'سبب العمولة وملاحظات الاتفاق';

  @override
  String get admin_save_record => 'حفظ السجل';

  @override
  String get admin_reports_list_title => 'بلاغات الإعلانات المخالفة';

  @override
  String get admin_no_reports => 'لا توجد بلاغات مخالفة حالياً';

  @override
  String get admin_no_reports_desc => 'كافة الإعلانات المعلنة مطابقة ولم يتم الإبلاغ عن أي مخالفة.';

  @override
  String get admin_details_label => 'تفاصيل';

  @override
  String get admin_none => 'لا يوجد';

  @override
  String get admin_verified_closed => 'تم التحقق والإغلاق';

  @override
  String get admin_process => 'معالجة';

  @override
  String get admin_encrypted_section_title => 'قسم مشفر ومحمي خاص بالمدير العام فقط';

  @override
  String get admin_encrypted_section_desc => 'وفقاً لسياسات الأمان والتشفير، بيانات المستخدمين لا تظهر إلا للمدير العام (م. محمد السقاف) لضمان الخصوصية التامة.';

  @override
  String get admin_users_list_title => 'سجل حسابات المستخدمين (بيانات مشفرة ومحمية)';

  @override
  String get admin_gm_permissions => 'صلاحيات المدير العام';

  @override
  String get admin_data_protection => 'حماية البيانات: كلمات المرور والتفاصيل الحساسة مشفرة بنظام التشفير القياسي، ويظهر للمدير العام فقط اسم المستخدم وحسابه.';

  @override
  String get admin_account_label => 'الحساب';

  @override
  String get admin_created_at => 'تاريخ الإنشاء';

  @override
  String get admin_encrypted_protected => 'مشفر ومحمي';

  @override
  String get admin_section_users => 'سجل المستخدمين';

  @override
  String get admin_pdf_preparing => 'جاري تجهيز وطباعة تقرير PDF شامل لقسم:';

  @override
  String get admin_day_monday => 'الإثنين';

  @override
  String get admin_day_tuesday => 'الثلاثاء';

  @override
  String get admin_day_wednesday => 'الأربعاء';

  @override
  String get admin_day_thursday => 'الخميس';

  @override
  String get admin_day_friday => 'الجمعة';

  @override
  String get admin_day_saturday => 'السبت';

  @override
  String get admin_day_sunday => 'الأحد';

  @override
  String get admin_month_january => 'يناير';

  @override
  String get admin_month_february => 'فبراير';

  @override
  String get admin_month_march => 'مارس';

  @override
  String get admin_month_april => 'أبريل';

  @override
  String get admin_month_may => 'مايو';

  @override
  String get admin_month_june => 'يونيو';

  @override
  String get admin_month_july => 'يوليو';

  @override
  String get admin_month_august => 'أغسطس';

  @override
  String get admin_month_september => 'سبتمبر';

  @override
  String get admin_month_october => 'أكتوبر';

  @override
  String get admin_month_november => 'نوفمبر';

  @override
  String get admin_month_december => 'ديسمبر';

  @override
  String get admin_pm => 'مساءً';

  @override
  String get admin_am => 'صباحاً';

  @override
  String get admin_sanaa_time => '(بتوقيت صنعاء)';

  @override
  String get admin_col_property_id => 'رقم العقار';

  @override
  String get admin_col_address => 'العنوان';

  @override
  String get admin_col_deal => 'العملية';

  @override
  String get admin_col_city => 'المدينة';

  @override
  String get admin_col_price => 'السعر';

  @override
  String get admin_col_request_id => 'رقم الطلب';

  @override
  String get admin_col_tenant => 'المستأجر';

  @override
  String get admin_col_phone => 'الهاتف';

  @override
  String get admin_col_start_date => 'تاريخ البدء';

  @override
  String get admin_col_id => 'المعرف';

  @override
  String get admin_col_amount => 'المبلغ';

  @override
  String get admin_col_settlement_status => 'حالة التسوية';

  @override
  String get admin_col_report_reason => 'سبب البلاغ';

  @override
  String get admin_col_report_date => 'تاريخ البلاغ';

  @override
  String get admin_status_resolved => 'محلول';

  @override
  String get admin_col_number => 'الرقم';

  @override
  String get admin_col_username => 'اسم المستخدم';

  @override
  String get admin_col_account_email => 'الحساب (البريد)';

  @override
  String get admin_col_encryption_status => 'حالة التشفير';

  @override
  String get admin_encrypted_protected_pdf => '🔒 مشفر ومحمي';

  @override
  String get admin_pdf_bismillah => 'بسم الله الرحمن الرحيم';

  @override
  String get admin_pdf_republic => 'الجمهورية اليمنية — بوابة اليمن العقارية';

  @override
  String get admin_pdf_report_header => 'الإدارة العامة — تقرير رسمي شامل';

  @override
  String get admin_pdf_section => 'القسم';

  @override
  String get admin_pdf_issuer => 'المستخرج: المدير العام (م. محمد السقاف)';

  @override
  String get admin_pdf_day_label => 'اليوم';

  @override
  String get admin_pdf_date_label => 'التاريخ';

  @override
  String get admin_pdf_month_label => 'الشهر';

  @override
  String get admin_pdf_year_label => 'السنة';

  @override
  String get admin_pdf_year_suffix => 'م';

  @override
  String get admin_pdf_time_label => 'الوقت';

  @override
  String get admin_pdf_total_items => 'إجمالي عناصر القسم';

  @override
  String get admin_pdf_data_status => 'حالة البيانات: معتمدة ومحدثة لحظياً';

  @override
  String get admin_pdf_no_data => 'لا توجد بيانات مسجلة حالياً';

  @override
  String get admin_pdf_copyright => 'شركة هيبه سوفت (Hiba Soft) — جميع الحقوق محفوظة © 2026';

  @override
  String get admin_pdf_doc_footer => 'وثيقة إدارية رسمية — مشفرة وموثقة';

  @override
  String get admin_report_filename_prefix => 'تقرير_';

  @override
  String get admin_pdf_export_success => 'تم تصدير تقرير الـ PDF بنجاح';

  @override
  String get admin_pdf_saved_prefix => 'تم حفظ التقرير الشامل لقسم \"';

  @override
  String get admin_pdf_saved_suffix => '\" متضمناً تفاصيل اليوم والتاريخ والشهر والسنة والوقت الدقيق بتوقيت صنعاء.';

  @override
  String get admin_pdf_file_name => '📁 اسم الملف:';

  @override
  String get admin_pdf_save_path => '📍 مسار الحفظ بالجهاز:';

  @override
  String get admin_copy_path => 'نسخ المسار';

  @override
  String get admin_path_copied => 'تم نسخ مسار الملف إلى الحافظة';

  @override
  String get admin_ok => 'حسناً';

  @override
  String get admin_export_failed => 'فشل تصدير التقرير';

  @override
  String get admin_copy_data => 'نسخ البيانات';

  @override
  String get admin_csv_copied => 'تم نسخ بيانات CSV بنجاح إلى الحافظة';

  @override
  String get admin_close => 'إغلاق';

  @override
  String get contract_auth_prompt_message => 'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.';

  @override
  String get contract_clauses_saved => 'تم حفظ وتحديث بنود العقد بنجاح';

  @override
  String get contract_bismillah => 'بسم الله الرحمن الرحيم';

  @override
  String get contract_republic => 'الجمهورية اليمنية';

  @override
  String get contract_edit_date => 'تاريخ التحرير:';

  @override
  String get contract_first_party => 'الطرف الأول (المؤجر / المالك):';

  @override
  String get contract_phone => 'هاتف:';

  @override
  String get contract_address => 'العنوان:';

  @override
  String get contract_second_party => 'الطرف الثاني (المستأجر):';

  @override
  String get contract_id_card_number => 'بطاقة شخصية رقم:';

  @override
  String get contract_tenant_id_label => 'رقم البطاقة الشخصية / الهوية *';

  @override
  String get contract_leased_property => 'العين المؤجرة:';

  @override
  String get contract_property_in_governorate => 'عقار كائن في محافظة';

  @override
  String get contract_district_label => '- مديرية';

  @override
  String get contract_specifications => 'المواصفات:';

  @override
  String get contract_terms_title => 'بنود وشروط الاتفاق:';

  @override
  String get contract_clause1_title => 'مدة العقد:';

  @override
  String get contract_starts_from_date => 'تبدأ من تاريخ';

  @override
  String get contract_until_date => 'وحتى';

  @override
  String get contract_non_renewable_plain => 'غير قابلة للتجديد إلا برغبة وموافقة خطية من الطرف الأول.';

  @override
  String get contract_auto_renew_plain => 'تجدد تلقائياً ما لم يخطر أحد الطرفين الآخر قبل شهر.';

  @override
  String get contract_clause2_title => 'الإيجار المتفق عليه:';

  @override
  String get contract_amount_of => 'مبلغ وقدره';

  @override
  String get contract_paid => 'يدفع';

  @override
  String get contract_clause3_title => 'مبلغ الضمان / التأمين:';

  @override
  String get contract_deposit_return => 'يسلم للمؤجر ويُعاد للمستأجر عند انتهاء العقد وتسليم العين بحالتها الأولى.';

  @override
  String get contract_clause4_title => 'فواتير الخدمات:';

  @override
  String get contract_clause5_title => 'الصيانة والاستخدام:';

  @override
  String get contract_clause6_title => 'منع التأجير من الباطن:';

  @override
  String get contract_sublease_ban_text => 'هذا العقد شخصي للمستأجر ولا يحق له التنازل أو التقبيل أو التأجير من الباطن كلياً أو جزئياً.';

  @override
  String get contract_clause7_title => 'التخلف عن السداد:';

  @override
  String get contract_clause8_title => 'شروط خاصة إضافية من المؤجر:';

  @override
  String get contract_owner_signature => 'توقيع الطرف الأول (المؤجر): .....................';

  @override
  String get contract_tenant_signature => 'توقيع الطرف الثاني (المستأجر): .....................';

  @override
  String get contract_witnesses_line => 'الشاهد الأول: .....................    الشاهد الثاني: .....................';

  @override
  String get contract_text_copied => 'تم نسخ نص العقد الكامل إلى الحافظة بنجاح، يمكنك لصقه وطباعته في أي برنامج';

  @override
  String get contract_default_title => 'عقد إيجار شرعي وقانوني';

  @override
  String get contract_first_party_pdf => 'الطرف الأول (المؤجر/المالك):';

  @override
  String get contract_id_number => 'هوية رقم:';

  @override
  String get contract_tenant_phone => 'هاتف المستأجر:';

  @override
  String get contract_residence => 'محل الإقامة:';

  @override
  String get contract_start_date => 'تاريخ البدء:';

  @override
  String get contract_pdf_terms_title => 'بنود وشروط الاتفاق والتراضي:';

  @override
  String get contract_renew_by_mutual_consent => 'تجدد بالتراضي بين الطرفين.';

  @override
  String get contract_monthly_rent_agreed => 'الإيجار الشهري المتفق عليه:';

  @override
  String get contract_pdf_rent_tail => 'مقدماً وبسندات رسمية، وفي حال التأخر أسبوعين يعتبر العقد لاغياً.';

  @override
  String get contract_personal_clause => 'هذا العقد شخصي بين الطرفين أعلاه وتم بقناعتهم ورضاهم جميعاً ولا يخضع لأي نظم تضر بمصلحة المؤجر.';

  @override
  String get contract_tenant_acknowledgement => 'أقر المستأجر بأنه قد استلم العين المؤجرة في حالة سليمة وتعهد بالمحافظة عليها من الداخل والخارج، ويتحمل مسؤولية أي تلف أو خلل يحصل في العين المؤجرة.';

  @override
  String get contract_no_transfer_clause => 'العقد شخصي للمستأجر والمدون اسمه أعلاه ولا يجوز التنازل عنه للغير من الباطن أو الظاهر ولا يحق له التقبيل مطلقاً.';

  @override
  String get contract_liability_clause => 'إن المؤجر غير مسؤول عن أي ضرر أو أخطار قد تقع في الأرواح أو الأصول لأي سبب كان مثل الحرائق أو الأمطار والسيول أو السرقات.';

  @override
  String get contract_deposit_title => 'الضمان والتأمين:';

  @override
  String get contract_deposit_screen_title => 'مبلغ الضمان والتأمين:';

  @override
  String get contract_paid_amount => 'دفع مبلغ';

  @override
  String get contract_deposit_tail => 'كوديعة تأمين تسترد عند تسليم العين بحالتها الأصلية.';

  @override
  String get contract_owner_signature_short => 'توقيع المؤجر (الطرف الأول)';

  @override
  String get contract_tenant_signature_short => 'توقيع المستأجر (الطرف الثاني)';

  @override
  String get contract_witness_short => 'الشاهد الأول / الثاني';

  @override
  String get contract_portal_name_suffix => '— بوابة اليمن العقارية';

  @override
  String get contract_pdf_saved_title => 'تم حفظ العقد PDF';

  @override
  String get contract_pdf_saved_body_before => 'تم حفظ ملف العقد الرسمي بصيغة PDF بنجاح في جهازك:\n\n📂 المسار:';

  @override
  String get contract_pdf_saved_body_after => 'يمكنك الآن إرساله عبر واتساب أو طباعته أو فتحه عبر مدير الملفات (التنزيلات).';

  @override
  String get contract_copy_text => 'نسخ نص العقد';

  @override
  String get contract_cancel => 'إلغاء';

  @override
  String get contract_ok => 'حسناً';

  @override
  String get contract_pdf_save_error => 'حدث خطأ أثناء حفظ ملف PDF';

  @override
  String get contract_app_bar_title => 'معاينة وتشكيل العقد';

  @override
  String get contract_edit_tooltip => 'تعديل وتشكيل البنود';

  @override
  String get contract_save_pdf => 'حفظ العقد PDF';

  @override
  String get contract_edit_clauses => 'تعديل البنود';

  @override
  String get contract_print => 'طباعة';

  @override
  String get contract_number => 'رقم العقد:';

  @override
  String get contract_fill_intro_title => 'تعبئة وكتابة بيانات العقد مباشرة';

  @override
  String get contract_fill_intro_body => 'اضغط هنا أو على أي خانة لكتابة اسم المستأجر والمؤجر وأرقام الهويات ومبالغ وشروط العقد لتظهر مطبوعة في الـ PDF دون فراغات';

  @override
  String get contract_fill_fields => 'تعبئة الخانات';

  @override
  String get contract_section_parties => 'أولاً: أطراف العقد';

  @override
  String get contract_first_party_box => 'الطرف الأول (المؤجر / المالك):';

  @override
  String get contract_section_property => 'ثانياً: بيانات العين المؤجرة وموقعها';

  @override
  String get contract_approx_area_prefix => 'بمساحة تقريبية';

  @override
  String get contract_sqm_unit => 'م²';

  @override
  String get contract_section_clauses => 'ثالثاً: بنود وشروط الاتفاق الشرعية والقانونية';

  @override
  String get contract_clause1_screen_title => 'مدة العقد وتاريخ السريان:';

  @override
  String get contract_duration_label => 'مدة العقد';

  @override
  String get contract_ends_on_date => 'وتنتهي في تاريخ';

  @override
  String get contract_non_renewable_screen => 'وهي غير قابلة للتجديد إلا برغبة وموافقة خطية صريحة من الطرف الأول.';

  @override
  String get contract_renewable_by_consent => 'قابلة للتجديد برضا الطرفين.';

  @override
  String get contract_clause2_screen_title => 'القيمة الإيجارية وطريقة السداد:';

  @override
  String get contract_agreed_monthly_value => 'اتفق الطرفان على قيمة إيجارية شهرية قدرها';

  @override
  String get contract_receipt_tail => 'وبسندات قبض موقعة.';

  @override
  String get contract_deposit_preamble => 'يدفع الطرف الثاني مبلغ تأمين وضمان قدره';

  @override
  String get contract_deposit_screen_tail => 'يبقى لدى الطرف الأول كوديعة ضمان لصيانة ونظافة العين وتسديد الفواتير، ويُرد للمستأجر عند الإخلاء بحالة سليمة.';

  @override
  String get contract_utilities_screen_title => 'فواتير الخدمات والاستهلاك:';

  @override
  String get contract_bears_utilities => 'يتحمل';

  @override
  String get contract_utilities_tail => 'كافة فواتير الكهرباء والمياه وخدمات النظافة والاتصالات المترتبة على العين المؤجرة طوال فترة الإيجار.';

  @override
  String get contract_maintenance_screen_title => 'المحافظة على العين والصيانة:';

  @override
  String get contract_no_alterations => 'ولا يحق للمستأجر إحداث أي فتحات أو تغييرات في المبنى إلا بإذن كتابي مسبق.';

  @override
  String get contract_sublease_screen_title => 'منع التأجير من الباطن أو التقبيل:';

  @override
  String get contract_sublease_ban_screen_text => 'هذا العقد شخصي للمستأجر فقط، ولا يجوز له التنازل عنه للغير كلياً أو جزئياً من الباطن أو التقبيل نهائياً.';

  @override
  String get contract_termination_title => 'فسخ العقد وإخلاء العين:';

  @override
  String get contract_extra_clauses_title => 'شروط إضافية خاصة بالمؤجر:';

  @override
  String get contract_section_signatures => 'رابعاً: الإقرار والتوقيعات';

  @override
  String get contract_witness1 => 'الشاهد الأول';

  @override
  String get contract_witness2 => 'الشاهد الثاني';

  @override
  String get contract_footer_notice => 'وثيقة رسمية صادرة عبر بوابة اليمن العقارية — هيبه سوفت (Hiba Soft) © 2026';

  @override
  String get contract_write_edit => 'كتابة / تعديل';

  @override
  String get contract_name_label => 'الاسم:';

  @override
  String get contract_identity_label => 'الهوية / البطاقة:';

  @override
  String get contract_signature_stamp => 'التوقيع / البصمة: ...................';

  @override
  String get contract_sheet_title => 'تعبئة وتعديل بيانات العقد';

  @override
  String get contract_tab_parties => 'المستأجر والمؤجر';

  @override
  String get contract_tab_terms => 'الشروط والماليات';

  @override
  String get contract_tenant_section_title => 'الطرف الثاني (المستأجر) - تعبئة الفراغات';

  @override
  String get contract_tenant_name_label => 'اسم المستأجر الكامل *';

  @override
  String get contract_tenant_name_hint => 'مثال: محمد عبدالله الأهدل';

  @override
  String get contract_id_hint => 'مثال: 01010023456';

  @override
  String get contract_contact_phone_label => 'رقم الهاتف للتواصل *';

  @override
  String get contract_tenant_address_label => 'العنوان ومحل الإقامة الحالي';

  @override
  String get contract_tenant_address_hint => 'مثال: صنعاء - الأصبحي';

  @override
  String get contract_owner_section_title => 'الطرف الأول (المؤجر / المالك)';

  @override
  String get contract_owner_name_label => 'اسم المؤجر / المالك *';

  @override
  String get contract_owner_name_hint => 'اسم المالك الرباعي';

  @override
  String get contract_owner_id_label => 'رقم البطاقة الشخصية للمؤجر';

  @override
  String get contract_id_number_hint => 'رقم الهوية';

  @override
  String get contract_owner_phone_label => 'هاتف المؤجر *';

  @override
  String get contract_contact_phone_hint => 'هاتف التواصل';

  @override
  String get contract_owner_address_label => 'عنوان المؤجر المعتمد';

  @override
  String get contract_owner_address_hint => 'مثال: صنعاء - حدة';

  @override
  String get contract_formal_title_label => 'عنوان العقد الرسمي';

  @override
  String get contract_rent_amount_label => 'مبلغ الإيجار';

  @override
  String get contract_deposit_label => 'مبلغ الضمان والتأمين';

  @override
  String get contract_duration_hint => 'سنة كاملة';

  @override
  String get contract_start_date_label => 'تاريخ البدء';

  @override
  String get contract_end_date_label => 'تاريخ الانتهاء';

  @override
  String get contract_non_renewable_switch_title => 'غير قابل للتجديد إلا برغبة وموافقة المالك';

  @override
  String get contract_non_renewable_switch_subtitle => 'حماية لحق المؤجر في تقرير التجديد من عدمه';

  @override
  String get contract_sublease_switch_title => 'منع التأجير من الباطن أو التقبيل نهائياً';

  @override
  String get contract_sublease_switch_subtitle => 'يمنع المستأجر من تسليم العين لشخص آخر دون موافقة المالك الخطية';

  @override
  String get contract_utilities_label => 'مسؤولية فواتير الخدمات (كهرباء، ماء)';

  @override
  String get contract_maintenance_label => 'شروط الصيانة وتسليم العين';

  @override
  String get contract_late_policy_label => 'شرط التأخير عن السداد والفسخ';

  @override
  String get contract_extra_owner_clauses_title => 'شروط خاصة إضافية من المالك:';

  @override
  String get contract_custom_clause_hint => 'اكتب شرطاً مخصصاً (مثال: عدم التدخين بالداخل)...';

  @override
  String get contract_add => 'إضافة';

  @override
  String get contract_save_template_title => 'حفظ هذا العقد كنموذج افتراضي لعقاراتي القادمة';

  @override
  String get contract_save_template_subtitle => 'عند تفعيل هذا الخيار، سيتم تطبيق هذه الشروط تلقائياً عند إضافة أي عرض جديد';

  @override
  String get contract_save_apply => 'حفظ وتطبيق التعديلات';

  @override
  String get contract_pdf_filename => 'عقد_ايجار';

  @override
  String get dash_add_listing_now => 'أضف إعلانك الآن';

  @override
  String get dash_add_property_free => 'أضف عقارك مجاناً';

  @override
  String get dash_add_property_prompt => 'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.';

  @override
  String get dash_add_property_tooltip => 'أضف عقارك';

  @override
  String get dash_all => 'الكل';

  @override
  String get dash_all_governorates => 'كافة المحافظات';

  @override
  String get dash_all_governorates_show_all => 'كافة المحافظات اليمنية (عرض الكل)';

  @override
  String get dash_cta_desc_desktop => 'انشر إعلانك عبر بوابة اليمن العقارية بميزة المراجعة الذاتية الفورية والتواصل المباشر مع العملاء.';

  @override
  String get dash_cta_desc_mobile => 'انشر إعلانك مجاناً عبر بوابة اليمن العقارية وتواصل مباشرة مع آلاف الباحثين عن عقارات.';

  @override
  String get dash_cta_title => 'هل تمتلك عقاراً ترغب في بيعه أو تأجيره؟';

  @override
  String get dash_districts_of_gov => 'أحياء ومناطق';

  @override
  String get dash_empty_section_description => 'تابع الإعلانات المضافة قريباً أو ابحث في الأقسام الأخرى';

  @override
  String get dash_empty_section_title => 'لا توجد عقارات في هذا القسم حالياً';

  @override
  String get dash_featured_subtitle => 'مختارات عقارية موثوقة ومميزة في اليمن';

  @override
  String get dash_featured_title => 'عقارات مميزة';

  @override
  String get dash_for_rent_subtitle => 'شقق سكنية ومقرات تجارية جاهزة للإيجار';

  @override
  String get dash_for_rent_title => 'أحدث العقارات للإيجار';

  @override
  String get dash_for_sale_subtitle => 'شقق، فلل، وأراضٍ معروضة للبيع المباشر';

  @override
  String get dash_for_sale_title => 'أحدث العقارات للبيع';

  @override
  String get dash_governorate => 'المحافظة';

  @override
  String get dash_hero_subtitle => 'آلاف الشقق والفلل والأراضي والمحلات التجارية المعروضة للبيع أو الإيجار مباشرة من المالك';

  @override
  String get dash_hero_title => 'ابحث عن عقارك المثالي في اليمن';

  @override
  String get dash_loading_featured => 'جاري تحميل العقارات المميزة...';

  @override
  String get dash_loading_for_rent => 'جاري تحميل عقارات للإيجار...';

  @override
  String get dash_loading_for_sale => 'جاري تحميل عقارات للبيع...';

  @override
  String get dash_location_dialog_message => 'السماح بالوصول إلى موقعك يعرض العقارات الأقرب إليك على الخريطة وفي القائمة. يمكنك تغيير ذلك لاحقاً من الإعدادات.';

  @override
  String get dash_location_dialog_title => 'عرض عقارات قريبة منك';

  @override
  String get dash_location_no_thanks => 'لا، شكراً';

  @override
  String get dash_location_use_my_location => 'استخدام موقعي';

  @override
  String get dash_nearby_fallback_count => 'عقار قريب من إب (افتراضي)';

  @override
  String get dash_nearby_in_range_count => 'عقار ضمن نطاق البحث';

  @override
  String get dash_nearby_title => 'عقارات قريبة منك';

  @override
  String get dash_no_nearby_properties => 'لا توجد عقارات ضمن النطاق المحدد. يمكنك تغيير نطاق البحث من الإعدادات.';

  @override
  String get dash_or_select_specific_district => 'أو اختر حي / منطقة محددة:';

  @override
  String get dash_properties_for_rent => 'عقارات للإيجار';

  @override
  String get dash_properties_for_sale => 'عقارات للبيع';

  @override
  String get dash_search_button => 'بحث';

  @override
  String get dash_search_hint => 'ابحث بالحي، المدينة، أو الكلمات الدلالية (مثال: شقة حدة)...';

  @override
  String get dash_search_in_gov_prefix => 'ابحث في';

  @override
  String get dash_search_in_gov_suffix => '(مثال: حي حدة، شقة)...';

  @override
  String get dash_select_governorate_title => 'اختر المحافظة اليمنية لعرض العقارات';

  @override
  String get dash_show_all_gov_properties => 'عرض كافة عقارات محافظة';

  @override
  String get dash_trusted_platform => 'المنصة العقارية الموثوقة في اليمن';

  @override
  String get dash_view_all => 'عرض الكل';

  @override
  String get dash_view_map => 'عرض الخريطة';

  @override
  String get dash_yemen_map => 'خريطة اليمن';

  @override
  String get fav_empty_action => 'تصفح العقارات الآن';

  @override
  String get fav_empty_desc => 'يمكنك إضافة أي عقار إلى قائمتك بالنقر على أيقونة القلب في بطاقة العقار';

  @override
  String get fav_empty_title => 'لا توجد عقارات في المفضلة';

  @override
  String get fav_loading => 'جاري تحميل قائمة المفضلة...';

  @override
  String get fav_login_required => 'تسجيل الدخول مطلوب';

  @override
  String get fav_signup_or_login => 'إنشاء حساب أو تسجيل الدخول';

  @override
  String get fav_signup_prompt => 'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.';

  @override
  String get fav_subtitle => 'العقارات التي قمت بحفظها لسهولة الرجوع إليها ومقارنتها.';

  @override
  String get fav_title => 'العقارات المفضلة';

  @override
  String get myprops_add_new => 'إضافة عقار جديد';

  @override
  String get myprops_add_property => 'أضف عقاراً';

  @override
  String get myprops_added_on => 'تاريخ الإضافة:';

  @override
  String get myprops_archive => 'أرشفة الإعلان';

  @override
  String get myprops_contract => 'تشكيل وطباعة العقد';

  @override
  String get myprops_delete_permanent => 'حذف نهائي';

  @override
  String get myprops_edit => 'تعديل الإعلان';

  @override
  String get myprops_empty_action => 'أضف عقارك الأول';

  @override
  String get myprops_empty_desc => 'انشر أول عقار لك الآن مجاناً وابدأ باستقبال طلبات المهتمين مباشرة';

  @override
  String get myprops_empty_title => 'لم تقم بنشر أي عقار بعد';

  @override
  String get myprops_hide => 'إخفاء الإعلان';

  @override
  String get myprops_loading => 'جاري تحميل عقاراتك...';

  @override
  String get myprops_login_required => 'تسجيل الدخول مطلوب';

  @override
  String get myprops_preview => 'معاينة';

  @override
  String get myprops_republish => 'إعادة النشر';

  @override
  String get myprops_signup_or_login => 'إنشاء حساب أو تسجيل الدخول';

  @override
  String get myprops_signup_prompt => 'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.';

  @override
  String get myprops_subtitle => 'إدارة عقاراتك، متابعة المشاهدات، وتعديل الحالة.';

  @override
  String get myprops_title => 'عقاراتي المعلنة';

  @override
  String get myprops_view => 'عرض الإعلان';

  @override
  String get myprops_views => 'المشاهدات:';

  @override
  String get myprops_yemen_map => 'خريطة اليمن';

  @override
  String get prof_admin => 'مدير';

  @override
  String get prof_admin_subtitle => 'إدارة العقارات، المستخدمين، العمولات، والبلاغات';

  @override
  String get prof_admin_title => 'لوحة الإدارة والتحكم';

  @override
  String get prof_cancel => 'إلغاء';

  @override
  String get prof_edit_account => 'تعديل بيانات الحساب';

  @override
  String get prof_favorites_subtitle => 'الوصول السريع إلى العقارات التي حفظتها سابقاً';

  @override
  String get prof_favorites_title => 'قائمة العقارات المفضلة';

  @override
  String get prof_full_name => 'الاسم الكامل';

  @override
  String get prof_full_name_hint => 'أدخل اسمك الكامل';

  @override
  String get prof_full_name_required => 'الاسم الكامل *';

  @override
  String get prof_login_required => 'تسجيل الدخول مطلوب';

  @override
  String get prof_manage_activities => 'إدارة نشاطاتي العقارية';

  @override
  String get prof_member_since => 'عضو منذ:';

  @override
  String get prof_my_listings_subtitle => 'استعراض الإعلانات المنشورة والمسودات وتعديلها أو إخفائها';

  @override
  String get prof_my_listings_title => 'عقاراتي المعلنة';

  @override
  String get prof_my_requests_subtitle => 'متابعة حالة وتفاصيل طلبات الاستئجار المرسلة للملاك';

  @override
  String get prof_my_requests_title => 'طلبات الاستئجار المقدمة';

  @override
  String get prof_no_phone => 'لم يتم تعيين رقم هاتف';

  @override
  String get prof_phone_required => 'رقم الهاتف للتواصل *';

  @override
  String get prof_save_changes => 'حفظ التعديلات';

  @override
  String get prof_sign_out => 'تسجيل الخروج من الحساب';

  @override
  String get prof_signup_or_login => 'إنشاء حساب أو تسجيل الدخول';

  @override
  String get prof_signup_prompt => 'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.';

  @override
  String get prof_super_admin => 'مدير عام';

  @override
  String get prof_update_failure => 'تعذر تحديث البيانات';

  @override
  String get prof_update_success => 'تم تحديث البيانات بنجاح';

  @override
  String get req_close => 'إغلاق';

  @override
  String get req_desired_start_date => 'تاريخ الاستئجار المطلوب (اختياري)';

  @override
  String get req_empty_action => 'تصفح عقارات الإيجار';

  @override
  String get req_empty_desc => 'تصفح العقارات المتاحة للإيجار وأرسل طلب استئجار مبدئي';

  @override
  String get req_empty_title => 'لا توجد طلبات استئجار سابقة';

  @override
  String get req_error_prefix => 'حدث خطأ:';

  @override
  String get req_follow_my_requests => 'متابعة طلباتي';

  @override
  String get req_form_title => 'طلب استئجار عقار';

  @override
  String get req_full_name => 'الاسم الكامل';

  @override
  String get req_full_name_hint => 'أدخل اسمك الثلاثي أو الرباعي';

  @override
  String get req_full_name_required => 'الاسم الكامل *';

  @override
  String get req_loading => 'جاري تحميل طلباتك...';

  @override
  String get req_login_required => 'تسجيل الدخول مطلوب';

  @override
  String get req_not_specified => 'غير محدد';

  @override
  String get req_notes_hint => 'أذكر أي استفسارات، مدة الإيجار المرغوبة، أو عدد أفراد الأسرة...';

  @override
  String get req_notes_label => 'ملاحظات إضافية أو شروط خاصة';

  @override
  String get req_owner_admin_reply => 'رد المالك/الإدارة:';

  @override
  String get req_phone_example_prefix => 'مثال:';

  @override
  String get req_phone_required => 'رقم الهاتف للتواصل *';

  @override
  String get req_pick_date_hint => 'حدد التاريخ المتوقع لبدء الإيجار';

  @override
  String get req_property_fallback => 'عقار للإيجار';

  @override
  String get req_reference_number => 'رقم الطلب المرجعي:';

  @override
  String get req_requested_start => 'تاريخ البدء المطلوب:';

  @override
  String get req_sent_on => 'تاريخ الإرسال:';

  @override
  String get req_signup_or_login => 'إنشاء حساب أو تسجيل الدخول';

  @override
  String get req_signup_prompt => 'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.';

  @override
  String get req_submit => 'إرسال طلب الاستئجار الآن';

  @override
  String get req_subtitle => 'تابع حالة طلباتك واستفساراتك المقدمة للعقارات المعروضة للإيجار.';

  @override
  String get req_success => 'تم استلام طلب الاستئجار بنجاح';

  @override
  String get req_success_note => 'ملاحظة: هذا الطلب يعد استفساراً ورغبة استئجار مبدئية فقط، ولا يعتبر عقداً رسمياً أو حجزاً نهائياً.';

  @override
  String get req_title => 'طلبات الاستئجار الخاصة بي';

  @override
  String get req_view_property => 'عرض العقار';

  @override
  String get req_your_notes => 'ملاحظاتك:';

  @override
  String get set_add_property_style => 'زر إضافة العقار';

  @override
  String get set_asset_count_positive_only => 'إظهار العدد عند وجود عقارات فقط';

  @override
  String get set_asset_count_visibility => 'عدد العقارات';

  @override
  String get set_current_location => 'موقعك الحالي';

  @override
  String get set_default_ibb => 'إب (افتراضي)';

  @override
  String get set_display => 'العرض';

  @override
  String get set_location => 'الموقع';

  @override
  String get set_reset_location => 'إعادة تعيين';

  @override
  String get set_search_radius => 'نطاق البحث';

  @override
  String get map_all => 'الكل';

  @override
  String get map_all_deals => 'الكل (بيع وإيجار)';

  @override
  String get map_all_deals_short => 'الكل (بيع/إيجار)';

  @override
  String get map_all_districts_in => 'كافة مديريات';

  @override
  String get map_all_governorates => 'كافة المحافظات 🇾🇪';

  @override
  String get map_all_governorates_plain => 'كافة المحافظات';

  @override
  String get map_all_property_types => 'كافة أنواع العقارات';

  @override
  String get map_all_types => 'جميع الأنواع';

  @override
  String get map_apply_filter => 'تطبيق التصفية';

  @override
  String get map_apply_filters => 'تطبيق الفلاتر';

  @override
  String get map_approximate_location_prefix => 'موقع تقديري بناءً على مركز';

  @override
  String get map_area_label => 'المساحة (م²)';

  @override
  String get map_area_sqm => 'م² مساحة';

  @override
  String get map_back_home => 'العودة للرئيسية';

  @override
  String get map_bedrooms => 'غرف نوم';

  @override
  String get map_call => 'اتصال';

  @override
  String get map_cancel => 'إلغاء';

  @override
  String get map_cancel_draw => 'إلغاء الرسم';

  @override
  String get map_check_availability => 'تحقق من التوافر';

  @override
  String get map_clear_draw => 'مسح الرسم';

  @override
  String get map_close => 'إغلاق';

  @override
  String get map_cluster_properties_title => 'عقارات هذا الموقع';

  @override
  String get map_cluster_property_unit => 'عقار';

  @override
  String get map_currency_sar => 'ر.س';

  @override
  String get map_currency_yer => 'ر.ي';

  @override
  String get map_deal_type => 'نوع المعاملة';

  @override
  String get map_deal_type_search => 'نوع العملية';

  @override
  String get map_directions => 'الوصول إلى العقار';

  @override
  String get map_directions_google_maps => 'الوصول إلى العقار عبر Google Maps';

  @override
  String get map_district_in => 'المديرية في';

  @override
  String get map_draw_area => 'رسم منطقة';

  @override
  String get map_draw_filter_active => 'تم حصر البحث بالرسم';

  @override
  String get map_draw_instruction => 'المس واسحب بإصبعك على الخريطة لرسم حدود المنطقة المطلوبة';

  @override
  String get map_draw_search_area => 'رسم منطقة البحث';

  @override
  String get map_exact_gps_only => 'إحداثيات GPS دقيقة فقط';

  @override
  String get map_exact_location => 'موقع محدد بدقة على الخريطة';

  @override
  String get map_filter_hint => 'جرب تعديل خيارات التصفية أو استخدام كلمات بحث أقل تحديداً';

  @override
  String get map_filter_results => 'تصفية النتائج';

  @override
  String get map_filter_title => 'تصفية خريطة العقارات (Filters)';

  @override
  String get map_filters => 'الفلاتر';

  @override
  String get map_filters_active => 'الفلاتر ✓';

  @override
  String get map_final_purchase_price => 'سعر الشراء النهائي المعتمد';

  @override
  String get map_for_rent => 'للإيجار';

  @override
  String get map_for_sale => 'للبيع';

  @override
  String get map_governorate => 'المحافظة';

  @override
  String get map_governorate_search => 'المحافظة';

  @override
  String get map_hide_approximate => 'إخفاء العقارات ذات المواقع التقريبية';

  @override
  String get map_load_error => 'تعذر تحميل الخريطة. يمكنك استخدام العرض البديل.';

  @override
  String get map_loading_map => 'جاري تحميل الخريطة...';

  @override
  String get map_loading_search => 'جاري البحث في قاعدة البيانات...';

  @override
  String get map_location_missing_message => 'لم يتم تحديد موقع هذا العقار على الخريطة بعد. يرجى التواصل مع صاحب العقار لتحديد الموقع.';

  @override
  String get map_main_menu => 'القائمة الرئيسية';

  @override
  String get map_maps_open_error => 'تعذر فتح خرائط Google. تأكد من تثبيت التطبيق أو الاتصال بالإنترنت.';

  @override
  String get map_max_price => 'الحد الأقصى';

  @override
  String get map_million_abbr => 'م';

  @override
  String get map_min_bedrooms => 'عدد الغرف على الأقل';

  @override
  String get map_min_price => 'الحد الأدنى';

  @override
  String get map_no_map_properties => 'لا توجد عقارات لعرضها على الخريطة';

  @override
  String get map_no_matching_properties => 'لم يتم العثور على عقارات مطابقة';

  @override
  String get map_no_max => 'بلا سقف';

  @override
  String get map_no_properties_area_hint => 'يرجى تغيير نطاق البحث أو مسح الفلاتر لعرض العقارات المتوفرة في بقية محافظات اليمن.';

  @override
  String get map_no_properties_in_area => 'لا توجد عقارات مطابقة في هذا النطاق';

  @override
  String get map_offline_atlas_hint => 'يمكنك تكبير وتصغير الخريطة باللمس أو الماوس';

  @override
  String get map_offline_atlas_title => 'خريطة الجمهورية اليمنية المعتمدة (أوفلاين)';

  @override
  String get map_one_bedroom => 'غرفة نوم واحدة';

  @override
  String get map_or_more => 'فأكثر';

  @override
  String get map_per_month => '/شهرياً';

  @override
  String get map_price_from => 'من';

  @override
  String get map_price_range => 'نطاق السعر';

  @override
  String get map_price_range_search => 'نطاق السعر';

  @override
  String get map_price_to => 'إلى';

  @override
  String get map_properties_available => 'عقار متاح';

  @override
  String get map_property_type => 'نوع العقار';

  @override
  String get map_property_type_search => 'نوع العقار';

  @override
  String get map_rent_discount => 'خصم خاص للإيجار';

  @override
  String get map_rent_only => 'للإيجار فقط';

  @override
  String get map_reset => 'إعادة تعيين';

  @override
  String get map_reset_filters => 'إعادة ضبط';

  @override
  String get map_reset_filters_action => 'إعادة تعيين الفلاتر';

  @override
  String get map_result_property_unit => 'عقار';

  @override
  String get map_retry => 'إعادة المحاولة';

  @override
  String get map_sale_discount => 'خصم خاص للبيع';

  @override
  String get map_sale_only => 'للبيع فقط';

  @override
  String get map_search_button => 'بحث';

  @override
  String get map_search_found => 'تم العثور على';

  @override
  String get map_search_hint => 'ابحث بالمحافظة، الحي، أو اسم العقار...';

  @override
  String get map_search_hint_main => 'ابحث بالعنوان، الحي، أو الكلمات الدلالية...';

  @override
  String get map_search_list_view => 'عرض القائمة';

  @override
  String get map_search_map_view => 'الخريطة العقارية';

  @override
  String get map_search_property_unit => 'عقار';

  @override
  String get map_search_results => 'نتائج البحث';

  @override
  String get map_search_settings => 'الإعدادات';

  @override
  String get map_search_this_area => 'البحث في هذه المنطقة';

  @override
  String get map_show_all_governorates => 'عرض كافة المحافظات اليمنية';

  @override
  String get map_show_list => 'عرض القائمة';

  @override
  String get map_show_map => 'عرض الخريطة';

  @override
  String get map_sort_by => 'ترتيب حسب: ';

  @override
  String get map_sort_newest => 'الأحدث';

  @override
  String get map_sort_price_asc => 'السعر: الأقل أولاً';

  @override
  String get map_sort_price_desc => 'السعر: الأعلى أولاً';

  @override
  String get map_switch_to_satellite => 'تبديل إلى قمر صناعي';

  @override
  String get map_switch_to_streets => 'تبديل إلى خريطة الشوارع';

  @override
  String get map_thousand_abbr => 'ألف';

  @override
  String get map_total_monthly_price => 'السعر الشهري الإجمالي';

  @override
  String get map_two_bedrooms => 'غرفتا نوم';

  @override
  String get map_type_apartment => 'شقق سكنية';

  @override
  String get map_type_building => 'عمارات ومباني';

  @override
  String get map_type_land => 'أراضٍ';

  @override
  String get map_type_office => 'مكاتب تجارية';

  @override
  String get map_type_shop => 'محلات تجارية';

  @override
  String get map_type_villa => 'فلل ومنازل';

  @override
  String get map_view_details => 'عرض التفاصيل';

  @override
  String get map_whatsapp => 'واتساب';

  @override
  String get map_whatsapp_prefix => 'السلام عليكم، بخصوص العقار المعروض في بوابة اليمن العقارية';

  @override
  String get map_yemen_atlas => 'خريطة اليمن 🇾🇪';

  @override
  String get addprop_verified_login_required => 'يلزم تسجيل الدخول بحساب مفعل عبر البريد الإلكتروني لنشر العقارات.';

  @override
  String get addprop_ownership_pledge_required => 'يجب الموافقة على إقرار ملكية الحق في نشر الإعلان للمتابعة';

  @override
  String get addprop_self_review_title => 'المراجعة الذاتية للإعلان';

  @override
  String get addprop_review_intro => 'يرجى مراجعة بيانات إعلانك بدقة قبل النشر الفعلي:';

  @override
  String get addprop_review_title_label => 'العنوان';

  @override
  String get addprop_review_deal_type_label => 'نوع العملية';

  @override
  String get addprop_review_price_label => 'السعر';

  @override
  String get addprop_review_area_label => 'المساحة';

  @override
  String get addprop_review_location_label => 'الموقع';

  @override
  String get addprop_review_phone_label => 'هاتف المعلن';

  @override
  String get addprop_review_status_label => 'حالة النشر';

  @override
  String get addprop_status_private_draft => 'مسودة خاصة';

  @override
  String get addprop_status_instant_publish => 'نشر فوري (حساب الإدارة)';

  @override
  String get addprop_status_pending_review => 'طلب نشر قيد المراجعة';

  @override
  String get addprop_admin_publish_note => 'بصفتك المدير العام، سيتم نشر هذا العقار مباشرة في المنصة.';

  @override
  String get addprop_review_policy_note => 'وفق سياسة النشر المعتمدة، يتم إرسال إعلانك إلى الإدارة (المسؤول العام: محمد السقاف) للمراجعة والاعتماد قبل ظهوره للعامة.';

  @override
  String get addprop_edit_data => 'تعديل البيانات';

  @override
  String get addprop_save_draft => 'حفظ كمسودة';

  @override
  String get addprop_confirm_publish => 'تأكيد ونشر الإعلان';

  @override
  String get addprop_submit_request => 'إرسال طلب النشر';

  @override
  String get addprop_confirm_email_required => 'يلزم تأكيد بريدك الإلكتروني أولاً قبل نشر العقار.';

  @override
  String get addprop_published_success => 'تم نشر الإعلان بنجاح في بوابة اليمن العقارية';

  @override
  String get addprop_request_sent_success => 'تم إرسال طلب نشر الإعلان بنجاح، وهو قيد مراجعة الإدارة للموافقة والاعتماد';

  @override
  String get addprop_draft_saved_success => 'تم حفظ مسودة الإعلان بنجاح';

  @override
  String get addprop_save_error => 'حدث خطأ أثناء حفظ الإعلان';

  @override
  String get addprop_login_required_title => 'تسجيل الدخول مطلوب';

  @override
  String get addprop_login_required_desc => 'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.';

  @override
  String get addprop_login_required_action => 'إنشاء حساب أو تسجيل الدخول';

  @override
  String get addprop_new_title => 'إضافة إعلان عقاري جديد';

  @override
  String get addprop_edit_title => 'تعديل بيانات العقار';

  @override
  String get addprop_intro => 'أدخل بيانات العقار بدقة لضمان وصوله إلى المهتمين بأعلى كفاءة.';

  @override
  String get addprop_section_basic_info => 'معلومات الإعلان والعملية';

  @override
  String get addprop_title_label => 'عنوان الإعلان *';

  @override
  String get addprop_title_field_name => 'عنوان الإعلان';

  @override
  String get addprop_title_hint => 'مثال: شقة للبيع في حدة بتشطيب ديلوكس وموقع استراتيجي';

  @override
  String get addprop_deal_type_label => 'نوع العملية *';

  @override
  String get addprop_deal_sale => 'للبيع';

  @override
  String get addprop_deal_rent => 'للإيجار';

  @override
  String get addprop_property_type_label => 'نوع العقار *';

  @override
  String get addprop_section_price_area => 'السعر والمساحة';

  @override
  String get addprop_price_label => 'السعر المطلوب *';

  @override
  String get addprop_price_field_name => 'السعر المطلوب';

  @override
  String get addprop_price_hint => 'مثال: 50000000';

  @override
  String get addprop_currency_label => 'العملة *';

  @override
  String get addprop_area_label => 'المساحة الإجمالية (م²) *';

  @override
  String get addprop_area_field_name => 'المساحة';

  @override
  String get addprop_area_hint => 'مثال: 180';

  @override
  String get addprop_bedrooms_label => 'عدد الغرف';

  @override
  String get addprop_na_hint => '0 إذا لم ينطبق';

  @override
  String get addprop_bathrooms_label => 'دورات المياه';

  @override
  String get addprop_section_location => 'الموقع الجغرافي';

  @override
  String get addprop_governorate_label => 'المحافظة *';

  @override
  String get addprop_district_label => 'المنطقة أو الحي *';

  @override
  String get addprop_district_field_name => 'الحي أو المنطقة';

  @override
  String get addprop_district_hint => 'مثال: حدة، بيت بوس، المعلا...';

  @override
  String get addprop_common_districts_intro => 'أحياء ومناطق شائعة في';

  @override
  String get addprop_common_districts_quick_pick => '(انقر للاختيار السريع):';

  @override
  String get addprop_address_details_label => 'تفاصيل العنوان والمعالم القريبة';

  @override
  String get addprop_address_hint => 'مثال: بالقرب من جولة الرويشان - شارع 14';

  @override
  String get addprop_map_picker_label => 'تحديد الموقع الدقيق على الخريطة (انقر على الخريطة لتثبيت المكان):';

  @override
  String get addprop_location_pinned => 'تم تثبيت الموقع:';

  @override
  String get addprop_map_tap_hint => 'انقر على أي نقطة في الخريطة لتثبيت موقع العقار بدقة';

  @override
  String get addprop_sqm_unit => 'م²';

  @override
  String get addprop_section_description_photos => 'الوصف والصور';

  @override
  String get addprop_description_label => 'الوصف الكامل للعقار *';

  @override
  String get addprop_description_field_name => 'الوصف';

  @override
  String get addprop_description_hint => 'اذكر تفاصيل ومميزات العقار، التشطيبات، المداخل، والخدمات المتوفرة...';

  @override
  String get addprop_photos_label => 'صور العقار (بحد أقصى 5 ميجابايت لكل صورة)';

  @override
  String get addprop_add_photos => 'إضافة صور';

  @override
  String get addprop_no_images_hint => 'لم يتم اختيار صور بعد. يمكنك إضافة صور لجذب المزيد من المشترين.';

  @override
  String get addprop_section_contact_pledge => 'بيانات التواصل والإقرار';

  @override
  String get addprop_phone_label => 'رقم الهاتف للتواصل *';

  @override
  String get addprop_whatsapp_label => 'رقم الواتساب';

  @override
  String get addprop_whatsapp_hint => 'اختياري للتواصل السريع';

  @override
  String get addprop_pledge_text => 'أقر وأتعهد بصحة كافة البيانات والمعلومات الواردة في هذا الإعلان، وبامتلاكي الحق النظامي والشرعي في تسويقه أو نشره.';

  @override
  String get addprop_section_contract => 'تشكيل وطباعة عقد العقار اليمني';

  @override
  String get addprop_contract_intro => 'يمكنك تشكيل وتخصيص شروط العقد وحفظ نموذجك المعتمد لطباعته وتوثيقه عند إتمام الصفقة مع المستأجر أو المشتري.';

  @override
  String get addprop_customize_contract => 'تخصيص بنود العقد والطباعة';

  @override
  String get addprop_preview_publish => 'معاينة الإعلان ونشره';

  @override
  String get detail_reason_inaccurate => 'معلومات غير دقيقة أو مضللة';

  @override
  String get detail_reason_price => 'السعر غير مطابق للواقع';

  @override
  String get detail_reason_duplicate => 'العقار مكرر أو مباع بالفعل';

  @override
  String get detail_reason_images => 'صور غير لائقة أو غير مطابقة';

  @override
  String get detail_reason_fraud => 'انتحال صفة أو احتيال';

  @override
  String get detail_reason_other => 'سبب آخر';

  @override
  String get detail_report_title => 'الإبلاغ عن إعلان مخالف';

  @override
  String get detail_report_intro => 'ساعدنا في الحفاظ على موثوقية المنصة بإبلاغنا عن أي مخالفة.';

  @override
  String get detail_report_reason_label => 'سبب البلاغ *';

  @override
  String get detail_report_details_label => 'تفاصيل إضافية (اختياري)';

  @override
  String get detail_report_details_hint => 'وضّح سبب البلاغ بالتفصيل...';

  @override
  String get detail_cancel => 'إلغاء';

  @override
  String get detail_report_submitted => 'تم استلام بلاغك بنجاح وسيقوم فريق الإدارة بمراجعته.';

  @override
  String get detail_submit_report => 'إرسال البلاغ';

  @override
  String get detail_loading => 'جاري تحميل تفاصيل العقار...';

  @override
  String get detail_browse_properties => 'تصفح العقارات المتاحة';

  @override
  String get detail_home => 'الرئيسية';

  @override
  String get detail_properties => 'العقارات';

  @override
  String get detail_auth_prompt_message => 'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.';

  @override
  String get detail_publish_date => 'تاريخ النشر:';

  @override
  String get detail_send_rental_request => 'إرسال طلب استئجار';

  @override
  String get detail_contract_preview => 'معاينة وتشكيل العقد والطباعة';

  @override
  String get detail_report_action => 'إبلاغ عن مخالفة';

  @override
  String get detail_link_copied => 'تم نسخ رابط العقار للمشاركة';

  @override
  String get detail_share_ad => 'مشاركة الإعلان';

  @override
  String get detail_total_area => 'المساحة الإجمالية';

  @override
  String get detail_property_type => 'نوع العقار';

  @override
  String get detail_bedrooms => 'عدد غرف النوم';

  @override
  String get detail_rooms_unit => 'غرف';

  @override
  String get detail_bathrooms => 'دورات المياه';

  @override
  String get detail_bathrooms_unit => 'حمامات';

  @override
  String get detail_views_unit => 'زيارة';

  @override
  String get detail_publishing_method => 'طريقة النشر';

  @override
  String get detail_self_review_published => 'مراجعة معلنة ذاتية';

  @override
  String get detail_description_title => 'تفاصيل ووصف العقار';

  @override
  String get detail_map_section_title => 'موقع العقار على الخريطة';

  @override
  String get detail_open_full_map => 'فتح الخريطة التفاعلية الشاملة';

  @override
  String get detail_directions_google_maps => 'الاتجاهات (خرائط جوجل)';

  @override
  String get detail_views_label => 'عدد المشاهدات';

  @override
  String get map_load_more => 'عرض المزيد من العقارات';

  @override
  String get sh_header_settings => 'الإعدادات';

  @override
  String get sh_header_add_property => 'أضف عقارك';

  @override
  String get sh_header_add_property_free => 'أضف عقارك مجاناً';

  @override
  String get sh_auth_prompt_message => 'لإكمال هذه العملية، يرجى إنشاء حساب وتأكيد بريدك الإلكتروني أولاً.';

  @override
  String get sh_nav_home => 'الرئيسية';

  @override
  String get sh_nav_my_properties => 'ممتلكاتي';

  @override
  String get sh_manage_properties_prompt => 'لإدارة عقاراتك، يرجى تسجيل الدخول أولاً.';

  @override
  String get sh_brand_name => 'بوابة اليمن العقارية';

  @override
  String get sh_drawer_admin_greeting => 'لوحة تحكم المدير العام';

  @override
  String get sh_drawer_user_greeting => 'أهلاً بك في حسابك';

  @override
  String get sh_drawer_tagline => 'المنصة العقارية الأولى في اليمن';

  @override
  String get sh_drawer_map_title => 'الخريطة العقارية';

  @override
  String get sh_drawer_map_subtitle => 'ابحث بالأسعار مباشرة على خريطة اليمن';

  @override
  String get sh_drawer_search => 'البحث عن العقارات';

  @override
  String get sh_drawer_favorites => 'العقارات المفضلة';

  @override
  String get sh_drawer_my_properties => 'عقاراتي المعروضة';

  @override
  String get sh_drawer_my_requests => 'طلبات الاستئجار';

  @override
  String get sh_drawer_profile => 'الملف الشخصي';

  @override
  String get sh_drawer_admin_panel => 'لوحة الإدارة الشاملة';

  @override
  String get sh_logout => 'تسجيل الخروج';

  @override
  String get sh_login_register => 'تسجيل الدخول / إنشاء حساب';

  @override
  String get sh_drawer_initial_fallback => 'ي';

  @override
  String get sh_nav_search => 'البحث';

  @override
  String get sh_nav_map => 'الخريطة';

  @override
  String get sh_nav_search_map => 'البحث والخريطة';

  @override
  String get sh_nav_favorites => 'المفضلة';

  @override
  String get sh_rail_my_properties => 'عقاراتي';

  @override
  String get sh_rail_admin => 'لوحة الإدارة';

  @override
  String get sh_rail_login => 'دخول / تسجيل';

  @override
  String get sh_back => 'رجوع';

  @override
  String get sh_footer_republic => 'الجمهورية اليمنية';

  @override
  String get sh_footer_tagline_desktop => 'المنصة الوطنية الرائدة لخدمات بيع وشراء وتأجير العقارات في كافة المحافظات اليمنية، بطرق موثوقة ومباشرة بين المعلن والباحث.';

  @override
  String get sh_footer_quick_links => 'روابط سريعة';

  @override
  String get sh_footer_properties_sale => 'عقارات للبيع';

  @override
  String get sh_footer_properties_rent => 'عقارات للإيجار';

  @override
  String get sh_footer_add_listing => 'أضف إعلانك مجاناً';

  @override
  String get sh_footer_my_account => 'حسابي';

  @override
  String get sh_footer_my_listings => 'عقاراتي المعلنة';

  @override
  String get sh_footer_contact => 'تواصل معنا';

  @override
  String get sh_footer_tagline_mobile => 'بوابة اليمن العقارية — منصتك الموثوقة لاستئجار وشراء وبيع العقارات في اليمن.';

  @override
  String get sh_auth_login_required => 'تسجيل الدخول مطلوب';

  @override
  String get sh_auth_info_note => 'تصفح العقارات والخدمات متاح مجاناً للزوار، بينما تتطلب العمليات المحمية حساباً موثقاً بالبريد لحفظ حقوقك.';

  @override
  String get sh_login => 'تسجيل الدخول';

  @override
  String get sh_auth_register_new => 'إنشاء حساب جديد';

  @override
  String get sh_auth_continue_guest => 'متابعة التصفح كزائر';

  @override
  String get sh_error_unexpected => 'حدث خطأ غير متوقع';

  @override
  String get sh_retry => 'إعادة المحاولة';

  @override
  String get sh_property_featured => 'مميز';

  @override
  String get sh_property_rooms => 'غرف';

  @override
  String get sh_property_bathrooms => 'حمام';

  @override
  String get sh_contact_unavailable => 'بيانات التواصل المباشر غير متوفرة لهذا الإعلان حالياً';

  @override
  String get sh_contact_whatsapp => 'تواصل عبر واتساب';

  @override
  String get sh_contact_call => 'اتصال هاتفي';

  @override
  String get sh_contact_whatsapp_error => 'تعذر فتح تطبيق واتساب. يرجى التأكد من تثبيته أو الاتصال هاتفياً.';

  @override
  String get sh_contact_call_error_prefix => 'تعذر بدء الاتصال الهاتفي. رقم الهاتف:';

  @override
  String get sh_router_not_found => 'الصفحة غير موجودة';

  @override
  String get sh_router_404_title => 'عفواً، الصفحة المطلوبة غير موجودة (404)';

  @override
  String get sh_router_404_description => 'تأكد من صحة الرابط أو عد إلى الصفحة الرئيسية';

  @override
  String get sh_router_404_action => 'العودة للرئيسية';

  @override
  String get sh_router_select_property => 'يرجى تحديد العقار أولاً';

  @override
  String get sh_back_exit_snackbar => 'اضغط مرة أخرى للخروج من التطبيق';

  @override
  String get sys_rate_limit => 'تم إرسال عدة طلبات مؤخراً. يرجى الانتظار دقيقة واحدة قبل طلب إعادة الإرسال لمنع الحظر.';

  @override
  String get sys_email_not_confirmed => 'البريد الإلكتروني لم يتم تأكيده بعد. يرجى فتح بريدك الإلكتروني والضغط على رابط التفعيل للمتابعة.';

  @override
  String get sys_link_expired => 'رابط التفعيل منتهي الصلاحية أو تم استخدامه مسبقاً. يرجى طلب رابط جديد.';

  @override
  String get sys_user_exists => 'هذا البريد الإلكتروني مسجل بالفعل. يرجى تسجيل الدخول بدلاً من إنشاء حساب جديد.';

  @override
  String get sys_invalid_credentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  @override
  String get sys_weak_password => 'كلمة المرور يجب ألا تقل عن 8 خانات.';

  @override
  String get sys_network_error => 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';

  @override
  String get sys_session_expired => 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مرة أخرى.';

  @override
  String get sys_permission_denied => 'ليس لديك الصلاحية الكافية لتنفيذ هذا الإجراء.';

  @override
  String get sys_unknown_error => 'حدث خطأ أثناء معالجة الطلب، يرجى المحاولة لاحقاً.';

  @override
  String sys_required_field(Object fieldName) {
    return 'يرجى إدخال $fieldName';
  }

  @override
  String get sys_required => 'هذا الحقل مطلوب';

  @override
  String get sys_enter_email => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get sys_invalid_email => 'صيغة البريد الإلكتروني غير صحيحة';

  @override
  String get sys_enter_password => 'يرجى إدخال كلمة المرور';

  @override
  String get sys_weak_password_long => 'يجب أن لا تقل كلمة المرور عن 8 أحرف أو أرقام لضمان حماية حسابك';

  @override
  String get sys_enter_phone => 'يرجى إدخال رقم الهاتف للتواصل';

  @override
  String get sys_invalid_phone => 'رقم الهاتف غير صحيح (مثال: 770000000)';

  @override
  String get sys_positive_number => 'يرجى إدخال رقم موجب صحيح';

  @override
  String get sys_non_negative_number => 'يرجى إدخال رقم صحيح (0 أو أكثر)';

  @override
  String get sys_login_failed => 'فشل تسجيل الدخول';

  @override
  String get sys_signup_failed => 'فشل إنشاء الحساب';

  @override
  String get sys_enter_email_first => 'يرجى إدخال البريد الإلكتروني أولاً';

  @override
  String sys_resend_wait(Object remaining) {
    return 'يرجى الانتظار $remaining ثانية قبل طلب إعادة إرسال رابط التفعيل مجدداً لمنع تكرار الطلبات.';
  }

  @override
  String get sys_property_not_found => 'العقار غير موجود';

  @override
  String get sys_image_too_large => 'حجم الصورة يتجاوز الحد المسموح به (5 ميجابايت)';

  @override
  String get sys_unsupported_image_format => 'صيغة الصورة غير مدعومة. الصيغ المتاحة: JPG, PNG, WEBP';

  @override
  String sys_upload_failed(Object error) {
    return 'فشل في رفع الصورة: $error';
  }

  @override
  String misc_whatsapp_inquiry(Object propertyId, Object propertyTitle) {
    return 'السلام عليكم، بخصوص العقار المعروض في بوابة اليمن العقارية: \"$propertyTitle\" (رقم: $propertyId)، أود الاستفسار عن التفاصيل.';
  }

  @override
  String get misc_area_unit => 'م²';

  @override
  String get misc_verified_advertiser => 'معلن موثق';

  @override
  String get csv_id => 'المعرف';

  @override
  String get csv_property_title => 'عنوان العقار';

  @override
  String get csv_deal_type => 'نوع العملية';

  @override
  String get csv_property_type => 'نوع العقار';

  @override
  String get csv_city => 'المدينة';

  @override
  String get csv_district => 'المنطقة';

  @override
  String get csv_price => 'السعر';

  @override
  String get csv_currency => 'العملة';

  @override
  String get csv_area => 'المساحة (م²)';

  @override
  String get csv_status => 'الحالة';

  @override
  String get csv_publish_date => 'تاريخ النشر';

  @override
  String get csv_contact_phone => 'هاتف التواصل';

  @override
  String get csv_request_number => 'رقم الطلب';

  @override
  String get csv_tenant_name => 'اسم المستأجر';

  @override
  String get csv_phone => 'رقم الهاتف';

  @override
  String get csv_requested_start => 'تاريخ البدء المطلوب';

  @override
  String get csv_admin_notes => 'ملاحظات الإدارة';

  @override
  String get csv_request_date => 'تاريخ الطلب';

  @override
  String get csv_liable_party => 'الطرف المتحمل';

  @override
  String get csv_seller_amount => 'مبلغ البائع';

  @override
  String get csv_buyer_amount => 'مبلغ المشتري';

  @override
  String get csv_total_commission => 'إجمالي العمولة';

  @override
  String get csv_settlement_status => 'حالة التسوية';

  @override
  String get csv_settlement_method => 'طريقة التسوية';

  @override
  String get csv_registration_date => 'تاريخ التسجيل';

  @override
  String get csv_notes => 'الملاحظات';

  @override
  String get misc_owner => 'المالك';

  @override
  String get misc_listed_property => 'عقار معلن';

  @override
  String get misc_user => 'مستخدم';

  @override
  String get dash_map_cta_title => 'استكشف عقارات اليمن على الخريطة التفاعلية 🇾🇪';

  @override
  String get dash_map_cta_subtitle => 'تصفح الأسعار والمواقع مباشرة في صنعاء، إب، تعز، وكافة المحافظات';
}
