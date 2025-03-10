import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String apiKey = "d8a98a8dd8ba094b7975c6b6c75c4f8e"; // Replace with your OpenWeather API Key
  String weatherInfo = "Fetching weather...";
  String currentImage = "";
  String weathericon = "https://openweathermap.org/img/wn/10d@2x.png";

  @override
  void initState() {
    super.initState();
    _getWeather();
  }

  Future<void> _getWeather() async {
    Position position = await _determinePosition();
    String url =
        "https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          weatherInfo =
              "${data['name']}: ${data['weather'][0]['description']}, ${data['main']['temp']}°C";
          if (data['weather'][0]['description'].contains("cloud"))
          {
            currentImage = "assets/Cloudy.jpg";
            weathericon = "https://openweathermap.org/img/wn/04d@2x.png";
          }
          else if (data['weather'][0]['description'].contains("sunny"))
          {
            currentImage = "assets/Sunny.jpg";
            weathericon = "https://openweathermap.org/img/wn/01d@2x.png";
          }
          else if (data['weather'][0]['description'].contains("clear"))
          {
            currentImage = "assets/Clear.jpg";
            weathericon = "https://openweathermap.org/img/wn/01d@2x.png";
          }
        });
      } else {
        setState(() {
          weatherInfo = "Failed to fetch weather: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        weatherInfo = "Error fetching weather.";
      });
    }
  }

  // Function to get user's location
  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return Future.error("Location permissions are permanently denied.");
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(currentImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.network(
                  weathericon, // URL of the PNG image
                  width: 40, // Set the width of the image
                  height: 40, // Set the height of the image
                ),
                Text(
                  weatherInfo,
                  style: TextStyle(fontSize: 22, color: Colors.white, backgroundColor: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
