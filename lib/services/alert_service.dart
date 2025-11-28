import 'package:url_launcher/url_launcher.dart';

class AlertService {
  /// Opens the default SMS app with prefilled message and number(s).
  /// This is a simple placeholder — replace numbers with emergency contacts later.
  static Future<void> sendSmsAlert({
    String phone = '',
    required String message,
  }) async {
    // sms: format handles Android / iOS — multiple recipients separated by comma on Android.
    final uri = Uri.parse('sms:$phone?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not open SMS app';
    }
  }

  /// Open a web url (donation or info)
  static Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open $url';
    }
  }

  /// Open a location query in maps via intent (Google Maps / Apple Maps)
  static Future<void> openInMaps(String query) async {
    final encoded = Uri.encodeComponent(query);
    // Google Maps search URI (works on Android and iOS if maps installed)
    final googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$encoded');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      // fallback try maps: URI
      final mapsUri = Uri.parse('geo:0,0?q=$encoded');
      if (await canLaunchUrl(mapsUri)) {
        await launchUrl(mapsUri);
      } else {
        throw 'Could not open maps for $query';
      }
    }
  }
}
