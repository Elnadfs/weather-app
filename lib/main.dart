import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const WeatherPage(),
    );
  }
}

// Halaman Pertama - Weather App (StatefulWidget)
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  String temperature = '28°C';
  String weather = 'Cerah';
  String location = 'Jakarta';
  
  final List<String> availableLocations = [
    'Jakarta',
    'Bandung',
    'Surabaya',
    'Yogyakarta',
    'Medan',
    'Makassar',
    'Denpasar'
  ];

  void _refreshWeather() {
    // Simulasi update cuaca berdasarkan lokasi
    setState(() {
      final List<String> weathers = ['Cerah', 'Hujan', 'Berawan', 'Badai'];
      weather = weathers[DateTime.now().second % 4];
      // Simulasi suhu berbeda untuk setiap kota
      final int baseTemp = 20 + availableLocations.indexOf(location) * 2;
      temperature = '${baseTemp + (DateTime.now().second % 5)}°C';
    });
  }

  void _changeLocation() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pilih Lokasi'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableLocations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(availableLocations[index]),
                  onTap: () {
                    setState(() {
                      location = availableLocations[index];
                    });
                    _refreshWeather();
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Weather App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.schedule),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HourlyWeatherPage(
                    location: location,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud,
                size: 100,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              InkWell(
                onTap: _changeLocation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      location,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.location_on),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                temperature,
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w300),
              ),
              Text(
                weather,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshWeather,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Halaman Kedua - Todo List (StatefulWidget)
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final List<String> _todos = [];
  final TextEditingController _controller = TextEditingController();
  static const String _todosKey = 'todos_key';

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  // Load todos from SharedPreferences
  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _todos.clear();
      _todos.addAll(prefs.getStringList(_todosKey) ?? []);
    });
  }

  // Save todos to SharedPreferences
  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_todosKey, _todos);
  }

  void _addTodo(String todo) {
    if (todo.isNotEmpty) {
      setState(() {
        _todos.add(todo);
      });
      _saveTodos();
      _controller.clear();
    }
  }

  void _removeTodo(int index) {
    setState(() {
      _todos.removeAt(index);
    });
    _saveTodos();
  }

  void _editTodo(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController editController = TextEditingController(text: _todos[index]);
        return AlertDialog(
          title: const Text('Edit Todo'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Todo',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  setState(() {
                    _todos[index] = editController.text;
                  });
                  _saveTodos();
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Todo List'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Tambah Todo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _addTodo(_controller.text),
                  child: const Text('Tambah'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_todos[index]),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editTodo(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTodo(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Mengubah TodoListPage menjadi HourlyWeatherPage
class HourlyWeatherPage extends StatefulWidget {
  final String location;
  
  const HourlyWeatherPage({
    super.key,
    required this.location,
  });

  @override
  State<HourlyWeatherPage> createState() => _HourlyWeatherPageState();
}

class _HourlyWeatherPageState extends State<HourlyWeatherPage> {
  final List<WeatherData> _hourlyWeather = [];

  @override
  void initState() {
    super.initState();
    _generateHourlyWeather();
  }

  void _generateHourlyWeather() {
    final List<String> weathers = ['Cerah', 'Hujan', 'Berawan', 'Badai'];
    final now = DateTime.now();
    
    _hourlyWeather.clear();
    // Generate 24 jam kedepan
    for (int i = 0; i < 24; i++) {
      final hour = now.add(Duration(hours: i));
      final baseTemp = 20 + (hour.hour % 5); // Variasi suhu berdasarkan jam
      
      _hourlyWeather.add(
        WeatherData(
          time: hour,
          temperature: baseTemp + (i % 3), // Tambah variasi
          weather: weathers[i % 4],
          humidity: 60 + (i % 30), // Simulasi kelembaban 60-90%
          windSpeed: 5 + (i % 10), // Simulasi kecepatan angin 5-15 km/h
        ),
      );
    }
  }

  String _getWeatherIcon(String weather) {
    switch (weather.toLowerCase()) {
      case 'cerah':
        return '☀️';
      case 'hujan':
        return '🌧️';
      case 'berawan':
        return '☁️';
      case 'badai':
        return '⛈️';
      default:
        return '🌤️';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Cuaca ${widget.location}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Prakiraan Cuaca 24 Jam Kedepan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _hourlyWeather.length,
              itemBuilder: (context, index) {
                final weather = _hourlyWeather[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0,
                  ),
                  child: ListTile(
                    leading: Text(
                      _getWeatherIcon(weather.weather),
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      '${weather.time.hour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(weather.weather),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${weather.temperature}°C',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '💧 ${weather.humidity}% 💨 ${weather.windSpeed}km/h',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _generateHourlyWeather();
          });
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Model untuk data cuaca
class WeatherData {
  final DateTime time;
  final int temperature;
  final String weather;
  final int humidity;
  final int windSpeed;

  WeatherData({
    required this.time,
    required this.temperature,
    required this.weather,
    required this.humidity,
    required this.windSpeed,
  });
}
