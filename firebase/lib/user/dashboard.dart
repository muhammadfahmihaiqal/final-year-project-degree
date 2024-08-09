import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'emergency_page.dart';
import 'forecasting.dart';

void main() {
  runApp(MaterialApp(
    home: DashboardPage(),
    theme: ThemeData(
      primaryColor: Color(0xFFB388FF),
      hintColor: Colors.white,
    ),
  ));
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final String apiKey = '79c9df438bf290f7c1c1d335ea4ac9a5';
  List<String>? savedCities;
  Map<String, Map<String, dynamic>> weatherData = {};

  @override
  void initState() {
    super.initState();
    loadSavedCities();
  }

  Future<void> loadSavedCities() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedCities = prefs.getStringList('savedCities') ?? [];
    });
    if (savedCities != null) {
      for (var city in savedCities!) {
        await fetchWeatherData(city);
      }
    }
  }

  Future<void> fetchWeatherData(String city) async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric'));

      if (response.statusCode == 200) {
        setState(() {
          weatherData[city] = jsonDecode(response.body);
        });
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      print('Error fetching weather data for $city: $e');
      // Handle error state or retry logic
    }
  }

  Future<void> addCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedCities?.add(city);
    });
    await prefs.setStringList('savedCities', savedCities ?? []);
    await fetchWeatherData(city); // Fetch weather data for the newly added city
  }

  Future<void> deleteCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedCities?.remove(city);
      weatherData.remove(city);
    });
    await prefs.setStringList('savedCities', savedCities ?? []);
  }

  String getWeatherIconUrl(String iconCode) {
    return 'https://openweathermap.org/img/w/$iconCode.png';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Color(0xFFB388FF),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFB388FF),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Icon(Icons.person, size: 30),
                  ),
                  SizedBox(height: 10),
                  Text(
                    FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Emergency Report'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmergencyPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: savedCities == null || savedCities!.isEmpty
          ? Center(child: Text('No saved cities'))
          : ListView.separated(
              itemCount: savedCities!.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                String city = savedCities![index];
                var cityWeather = weatherData[city];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ForecastingPage(city: city, weatherData: cityWeather),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: [
                          if (cityWeather != null)
                            Image.network(
                              getWeatherIconUrl(cityWeather['weather'][0]['icon']),
                              width: 50,
                              height: 50,
                            ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                if (cityWeather != null)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Temperature: ${cityWeather['main']['temp'].toStringAsFixed(1)}°C',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      Text(
                                        'Description: ${cityWeather['weather'][0]['description']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  )
                                else
                                  Text('Loading weather data...'),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              deleteCity(city);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add a city
          showDialog(
            context: context,
            builder: (BuildContext context) {
              String newCity = '';
              return AlertDialog(
                title: Text('Add City'),
                content: TextFormField(
                  decoration: InputDecoration(labelText: 'Enter city name'),
                  onChanged: (value) {
                    newCity = value;
                  },
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      addCity(newCity);
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: Color(0xFFB388FF),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
