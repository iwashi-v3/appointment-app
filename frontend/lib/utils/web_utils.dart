import 'package:web/web.dart';

void addGoogleMapsScript(String apiKey) {
  final script = HTMLScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey&callback=initMap'
    ..type = 'text/javascript'
    ..async = true
    ..defer = true;
  document.body!.append(script);
}