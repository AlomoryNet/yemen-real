import 'package:url_launcher/url_launcher.dart';
import '../core/utils/formatters.dart';

class ExternalCommunicationService {
  /// Open phone dialer
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final cleanPhone = Formatters.formatPhoneForDialing(phoneNumber);
    final uri = Uri.parse('tel:$cleanPhone');
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri);
    }
    return false;
  }

  /// Open WhatsApp with prefilled message
  static Future<bool> openWhatsApp({
    required String phoneNumber,
    required String propertyTitle,
    required String propertyId,
  }) async {
    final cleanPhone = Formatters.formatPhoneForWhatsApp(phoneNumber);
    final message = Uri.encodeComponent(
      'السلام عليكم، بخصوص العقار المعروض في بوابة اليمن العقارية: "$propertyTitle" (رقم: $propertyId)، أود الاستفسار عن التفاصيل.',
    );
    final urlString = 'https://wa.me/$cleanPhone?text=$message';
    final uri = Uri.parse(urlString);

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Open general URL or map link
  static Future<bool> openMap(double latitude, double longitude) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}
