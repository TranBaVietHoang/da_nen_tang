import 'package:flutter/material.dart';

void main() {
  runApp(BMICalculator());
}

class BMICalculator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BMIScreen(),
    );
  }
}

class BMIScreen extends StatefulWidget {
  @override
  _BMIScreenState createState() => _BMIScreenState();
}

class _BMIScreenState extends State<BMIScreen> {
  double height = 170; // Chiều cao mặc định
  double weight = 65; // Cân nặng mặc định
  double bmi = 0;

  String calculateBMI() {
    setState(() {
      bmi = weight / ((height / 100) * (height / 100));
    });
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 24.9) return 'Normal';
    if (bmi < 29.9) return 'Overweight';
    return 'Obese';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BMI Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Height: ${height.toStringAsFixed(1)} cm', style: TextStyle(fontSize: 20)),
            Slider(
              value: height,
              min: 100,
              max: 220,
              divisions: 120,
              onChanged: (value) {
                setState(() {
                  height = value;
                });
              },
            ),
            Text('Weight: ${weight.toStringAsFixed(1)} kg', style: TextStyle(fontSize: 20)),
            Slider(
              value: weight,
              min: 30,
              max: 150,
              divisions: 120,
              onChanged: (value) {
                setState(() {
                  weight = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: calculateBMI,
              child: Text('Calculate BMI'),
            ),
            SizedBox(height: 20),
            Text('Your BMI: ${bmi.toStringAsFixed(1)}', style: TextStyle(fontSize: 24)),
            Text('Status: ${calculateBMI()}', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
