import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const String _apiKey = "0c91c08a10fe1d8c072c927aaf5e935c";

  Future<Map<String, dynamic>> fetchWeather(double lat, double lon) async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("Weather API Error: ${response.body}");

      throw Exception("Failed to fetch weather");
    }
  }
}
