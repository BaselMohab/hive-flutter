import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/person.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PersonAdapter());
  await Hive.openBox<Person>('personBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hive Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        hintColor: Colors.orange,
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color.fromARGB(255, 11, 0, 0)),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.blue),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1.0),
          ),
          hintStyle: TextStyle(color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _boxName = 'personBox';
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedGender = 'Male';

  Box<Person>? _box;

  @override
  void initState() {
    super.initState();
    Hive.openBox<Person>(_boxName).then((box) {
      setState(() {
        _box = box;
      });
    });
  }

  void _addPerson() {
    final name = _nameController.text;
    final age = int.tryParse(_ageController.text) ?? 0;
    final email = _emailController.text;
    final person = Person(name: name, age: age, email: email, gender: _selectedGender);

    _box?.add(person);
    _nameController.clear();
    _ageController.clear();
    _emailController.clear();
    setState(() {
      _selectedGender = 'Male'; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hive Demo'),
      ),
      body: _box == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _ageController,
                    decoration: InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female'].map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _addPerson,
                    child: Text('Add Person'),
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ValueListenableBuilder(
                      valueListenable: _box!.listenable(),
                      builder: (context, Box<Person> box, _) {
                        if (box.values.isEmpty) {
                          return Center(child: Text('No people added yet.'));
                        }
                        return ListView.builder(
                          itemCount: box.length,
                          itemBuilder: (context, index) {
                            final person = box.getAt(index);
                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              elevation: 4,
                              child: ListTile(
                                title: Text(person!.name),
                                subtitle: Text('Age: ${person.age}\nEmail: ${person.email}\nGender: ${person.gender}'),
                              ),
                            );
                          },
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
