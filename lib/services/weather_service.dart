import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/config/env_config.dart';
import '../models/destination.dart';

class DailyForecast {
  final String dayName;
  final int tempMax;
  final int tempMin;
  final String condition;
  final String iconCode;

  const DailyForecast({
    required this.dayName,
    required this.tempMax,
    required this.tempMin,
    required this.condition,
    required this.iconCode,
  });
}

class WeatherInfo {
  final double tempCelsius;
  final double feelsLikeCelsius;
  final String conditionText;
  final String iconCode;
  final int humidity;
  final double windSpeedKmh;
  final List<DailyForecast> dailyForecasts;
  final bool isLiveApiData;

  const WeatherInfo({
    required this.tempCelsius,
    required this.feelsLikeCelsius,
    required this.conditionText,
    required this.iconCode,
    required this.humidity,
    required this.windSpeedKmh,
    required this.dailyForecasts,
    this.isLiveApiData = false,
  });

  /// Weather risk level for trip recommendations (0 = Clear, 1 = Mild, 2 = High Alert)
  int get riskScore {
    final lower = conditionText.toLowerCase();
    if (lower.contains('thunderstorm') || lower.contains('heavy rain') || lower.contains('blizzard')) {
      return 2; // High Risk
    }
    if (lower.contains('rain') || lower.contains('snow') || lower.contains('fog')) {
      return 1; // Moderate Risk
    }
    return 0; // Clear / Good Trekking Weather
  }
}

class WeatherService {
  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetch live weather or return deterministic fallback weather
  Future<WeatherInfo> getWeather(double lat, double lng, {int altitudeMeters = 1500}) async {
    final apiKey = EnvConfig.openWeatherApiKey;

    if (EnvConfig.isWeatherApiConfigured && !EnvConfig.useMockData) {
      try {
        final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lng&units=metric&appid=$apiKey',
        );
        final response = await _client.get(url).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return _parseOpenWeatherResponse(data);
        }
      } catch (_) {
        // Fallback to offline forecast if API request fails or times out
      }
    }

    return _getFallbackWeather(lat, lng, altitudeMeters);
  }

  WeatherInfo _parseOpenWeatherResponse(Map<String, dynamic> data) {
    final list = data['list'] as List<dynamic>? ?? [];
    if (list.isEmpty) {
      return _getFallbackWeather(20.0, 78.0, 1500);
    }

    final first = list.first;
    final main = first['main'] ?? {};
    final weatherList = first['weather'] as List<dynamic>? ?? [];
    final weather = weatherList.isNotEmpty ? weatherList.first : {};
    final wind = first['wind'] ?? {};

    final temp = (main['temp'] as num?)?.toDouble() ?? 15.0;
    final feelsLike = (main['feels_like'] as num?)?.toDouble() ?? 14.0;
    final condition = (weather['main'] as String?) ?? 'Clear';
    final icon = (weather['icon'] as String?) ?? '01d';
    final humidity = (main['humidity'] as num?)?.toInt() ?? 60;
    final windSpeed = ((wind['speed'] as num?)?.toDouble() ?? 3.5) * 3.6; // m/s to km/h

    // Parse up to 5 daily forecasts (1 sample per 24 hours / 8 slots)
    final List<DailyForecast> forecasts = [];
    final days = ['Today', 'Tomorrow', 'Day 3', 'Day 4', 'Day 5'];

    for (int i = 0; i < list.length && forecasts.length < 5; i += 8) {
      final slot = list[i];
      final slotMain = slot['main'] ?? {};
      final slotWeatherList = slot['weather'] as List<dynamic>? ?? [];
      final slotWeather = slotWeatherList.isNotEmpty ? slotWeatherList.first : {};

      forecasts.add(
        DailyForecast(
          dayName: days[forecasts.length],
          tempMax: ((slotMain['temp_max'] as num?)?.toDouble() ?? 15.0).round(),
          tempMin: ((slotMain['temp_min'] as num?)?.toDouble() ?? 10.0).round(),
          condition: (slotWeather['main'] as String?) ?? 'Clear',
          iconCode: (slotWeather['icon'] as String?) ?? '01d',
        ),
      );
    }

    return WeatherInfo(
      tempCelsius: temp,
      feelsLikeCelsius: feelsLike,
      conditionText: condition,
      iconCode: icon,
      humidity: humidity,
      windSpeedKmh: windSpeed,
      dailyForecasts: forecasts,
      isLiveApiData: true,
    );
  }

  WeatherInfo _getFallbackWeather(double lat, double lng, int altitudeMeters) {
    // Altitude-adjusted baseline temperature (colder at higher altitudes)
    final baseTemp = 25.0 - (altitudeMeters / 300.0);
    final temp = baseTemp.clamp(-10.0, 35.0);
    final feelsLike = temp - 2.0;

    return WeatherInfo(
      tempCelsius: temp,
      feelsLikeCelsius: feelsLike,
      conditionText: altitudeMeters > 3000 ? 'Partly Cloudy' : 'Mostly Sunny',
      iconCode: '01d',
      humidity: 55,
      windSpeedKmh: 12.5,
      dailyForecasts: [
        DailyForecast(dayName: 'Today', tempMax: (temp + 2).round(), tempMin: (temp - 4).round(), condition: 'Sunny', iconCode: '01d'),
        DailyForecast(dayName: 'Tomorrow', tempMax: (temp + 1).round(), tempMin: (temp - 5).round(), condition: 'Cloudy', iconCode: '02d'),
        DailyForecast(dayName: 'Wed', tempMax: temp.round(), tempMin: (temp - 6).round(), condition: 'Cool', iconCode: '03d'),
        DailyForecast(dayName: 'Thu', tempMax: (temp + 3).round(), tempMin: (temp - 3).round(), condition: 'Sunny', iconCode: '01d'),
        DailyForecast(dayName: 'Fri', tempMax: (temp + 4).round(), tempMin: (temp - 2).round(), condition: 'Clear', iconCode: '01d'),
      ],
      isLiveApiData: false,
    );
  }
}

/// Global Weather Service Provider
final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService());

/// Family Provider for Destination Weather
final destinationWeatherProvider = FutureProvider.family<WeatherInfo, Destination>((ref, destination) async {
  final service = ref.watch(weatherServiceProvider);
  return service.getWeather(destination.lat, destination.lng, altitudeMeters: destination.altitudeMeters);
});
