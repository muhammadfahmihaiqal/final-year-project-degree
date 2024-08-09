import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SafetyOfficerWeatherPage extends StatefulWidget {
  @override
  _SafetyOfficerWeatherPageState createState() => _SafetyOfficerWeatherPageState();
}

class _SafetyOfficerWeatherPageState extends State<SafetyOfficerWeatherPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, Map<String, dynamic>> weatherData = {};
  List<String> cities = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCities = prefs.getStringList('cities') ?? [];
    setState(() {
      cities = savedCities;
    });
    for (var city in savedCities) {
      await fetchForecastData(city);
    }
  }

  Future<void> _saveCities() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList('cities', cities);
  }

  Future<void> fetchForecastData(String city) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final apiKey = '79c9df438bf290f7c1c1d335ea4ac9a5'; // Replace with your OpenWeatherMap API key
    final response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric'));

    if (response.statusCode == 200) {
      setState(() {
        weatherData[city] = json.decode(response.body);
        if (!cities.contains(city)) {
          cities.add(city);
        }
        isLoading = false;
        _saveCities();
      });
    } else {
      setState(() {
        errorMessage = 'Failed to fetch forecast data';
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> filterForecastForDay(List<dynamic> forecastList, DateTime date) {
    List<Map<String, dynamic>> filteredForecasts = [];
    for (var forecast in forecastList) {
      DateTime forecastDate = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
      if (forecastDate.year == date.year && forecastDate.month == date.month && forecastDate.day == date.day) {
        filteredForecasts.add(forecast);
      }
    }
    return filteredForecasts;
  }

  void addCity(String city) {
    if (!cities.contains(city)) {
      fetchForecastData(city);
    }
  }

  void removeCity(String city) {
    setState(() {
      cities.remove(city);
      weatherData.remove(city);
      _saveCities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecasting'),
        backgroundColor: Color(0xFFB388FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    addCity(_controller.text);
                    _controller.clear();
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : errorMessage.isNotEmpty
                    ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
                    : cities.isEmpty
                        ? Center(child: Text('Add a city to see the forecast'))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: cities.length,
                              itemBuilder: (context, index) {
                                String city = cities[index];
                                var cityWeather = weatherData[city];
                                List<Map<String, dynamic>> todayForecast = cityWeather != null
                                    ? filterForecastForDay(cityWeather['list'], today)
                                    : [];

                                return Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ExpansionTile(
                                    title: Text(city, style: TextStyle(color: Colors.black)),
                                    children: [
                                      if (cityWeather == null)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('Loading weather data...'),
                                        )
                                      else if (todayForecast.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text('No forecasting data available for today.'),
                                        )
                                      else
                                        ...todayForecast.map((forecast) {
                                          final time = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
                                          final temp = forecast['main']['temp'].toStringAsFixed(2);
                                          final windSpeed = forecast['wind']['speed'].toString();
                                          final windDeg = forecast['wind']['deg'].toString();
                                          final lon = cityWeather['city']['coord']['lon'].toString();
                                          final lat = cityWeather['city']['coord']['lat'].toString();
                                          final description = forecast['weather'][0]['description'];
                                          return ListTile(
                                            title: Text('Time: ${DateFormat('h:mm a').format(time)}'),
                                            subtitle: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('Date: ${DateFormat('yyyy-MM-dd').format(time)}'),
                                                Text('Location: Lon: $lon, Lat: $lat'),
                                                Text('Temperature: $temp°C'),
                                                Text('Wind Speed: $windSpeed m/s'),
                                                Text('Wind Degree: $windDeg°'),
                                                Text('Description: $description'),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      TextButton(
                                        onPressed: () => removeCity(city),
                                        child: Text('Remove', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ],
        ),
      ),
    );
  }
}
