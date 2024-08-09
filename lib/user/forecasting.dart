import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ForecastingPage extends StatelessWidget {
  final String city;
  final Map<String, dynamic>? weatherData;

  ForecastingPage({required this.city, required this.weatherData});

  Future<Map<String, dynamic>> fetchForecastData(String city) async {
    final apiKey = '79c9df438bf290f7c1c1d335ea4ac9a5'; // Replace with your OpenWeatherMap API key
    final response = await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$apiKey&units=metric'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch forecast data');
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

  List<Map<String, dynamic>> getFiveDayForecast(List<dynamic> forecastList) {
    List<Map<String, dynamic>> fiveDayForecast = [];
    DateTime today = DateTime.now();
    DateTime nextDay = today.add(Duration(days: 1));

    for (int i = 0; i < 5; i++) {
      List<Map<String, dynamic>> filteredForecasts = filterForecastForDay(forecastList, nextDay);
      if (filteredForecasts.isNotEmpty) {
        fiveDayForecast.add(filteredForecasts.first);
      }
      nextDay = nextDay.add(Duration(days: 1));
    }

    return fiveDayForecast;
  }

  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/w/$iconCode.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast for $city'),
        backgroundColor: Color(0xFFB388FF), // Your main system color
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchForecastData(city),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final forecastData = snapshot.data;
            final List<dynamic> forecastList = forecastData!['list'];
            final DateTime today = DateTime.now();
            final List<Map<String, dynamic>> todayForecast = filterForecastForDay(forecastList, today);
            final List<Map<String, dynamic>> fiveDayForecast = getFiveDayForecast(forecastList);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hourly Forecast for Today (${DateFormat('yyyy-MM-dd').format(today)}):',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    if (todayForecast.isNotEmpty)
                      Container(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: todayForecast.length,
                          itemBuilder: (context, index) {
                            final forecast = todayForecast[index];
                            final time = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
                            final temp = forecast['main']['temp'].toStringAsFixed(2);
                            final description = forecast['weather'][0]['description'];
                            final iconCode = forecast['weather'][0]['icon'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 2,
                                child: Container(
                                  width: 150,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.network(
                                        getWeatherIconUrl(iconCode),
                                        width: 50,
                                        height: 50,
                                      ),
                                      Text('${DateFormat('hh:mm a').format(time)}'),
                                      Text('$temp°C'),
                                      Text('$description'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    else
                      Text(
                        'No forecasting data available for today.',
                        style: TextStyle(fontSize: 16),
                      ),
                    SizedBox(height: 20),
                    Text(
                      '5-Day Forecast:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    if (fiveDayForecast.isNotEmpty)
                      Column(
                        children: fiveDayForecast.map((forecast) {
                          final DateTime forecastDate = DateTime.fromMillisecondsSinceEpoch(forecast['dt'] * 1000);
                          final temp = forecast['main']['temp'].toStringAsFixed(2);
                          final description = forecast['weather'][0]['description'];
                          final iconCode = forecast['weather'][0]['icon'];

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                leading: Image.network(
                                  getWeatherIconUrl(iconCode),
                                  width: 50,
                                  height: 50,
                                ),
                                title: Text(
                                  DateFormat('EEEE, MMM d').format(forecastDate),
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Temperature: $temp°C'),
                                    Text('Description: $description'),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        'No forecasting data available for the next 5 days.',
                        style: TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ForecastingPage(city: 'London', weatherData: null), // Replace with your desired city
  ));
}
