import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String _city = "Fetching...";
  double _temperature = 0.0;
  String _weatherDescription = "";
  String _iconCode = "01d";

  final String apiKey = "YOUR_API_KEY"; // Replace with your OpenWeatherMap API key

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    try {
      Position position = await _determinePosition();
      final response = await http.get(Uri.parse(
          "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric"));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _city = data['name'];
          _temperature = data['main']['temp'];
          _weatherDescription = data['weather'][0]['description'];
          _iconCode = data['weather'][0]['icon'];
        });
      } else {
        setState(() => _city = "Error fetching weather");
      }
    } catch (e) {
      setState(() => _city = "Location error");
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Monitor')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_city, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Image.network("https://openweathermap.org/img/wn/$_iconCode@2x.png"),
            Text("$_temperature°C", style: const TextStyle(fontSize: 40)),
            Text(_weatherDescription, style: const TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _getWeather, child: const Text("Refresh")),
          ],
        ),
      ),
    );
  }
}
