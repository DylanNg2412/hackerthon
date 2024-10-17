import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Harvest Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WorkerHarvestInterface(),
    );
  }
}

class WorkerHarvestInterface extends StatefulWidget {
  const WorkerHarvestInterface({super.key});

  @override
  _WorkerHarvestInterfaceState createState() => _WorkerHarvestInterfaceState();
}

class _WorkerHarvestInterfaceState extends State<WorkerHarvestInterface> {
  final List<Map<String, dynamic>> progress = []; // Dynamic progress list
  final List<String> trainingTips = [
    "Focus on choosing fruits that are fully ripe to improve quality.",
    "Handle the fruit gently to avoid damage and maintain high quality.",
    "Ensure you're using the correct harvesting technique for each type of fruit.",
    "Pay attention to color and firmness when selecting fruits for harvest.",
    "Remember to stay hydrated and take short breaks to maintain your productivity.",
  ];

  final _formKey = GlobalKey<FormState>();
  String quantity = '';
  String quality = '';
  bool submitted = false;
  bool showMidDayAlert = false;
  String dispute = '';
  List<String> chatMessages = []; // Chat messages list

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      setState(() {
        showMidDayAlert = true;
      });
    });
  }

  int getBonus(double quality) {
    if (quality >= 4) return 10;
    if (quality >= 3) return 5;
    return 0;
  }

  String getFeedback(double quantity, double quality) {
    if (quality >= 4) {
      return 'Great job! You harvested $quantity tonnes today with an average quality score of $quality stars.';
    } else {
      return 'You harvested $quantity tonnes today. Try to improve your quality tomorrow by focusing on ripeness!';
    }
  }

  String getRandomTip() {
    return trainingTips[Random().nextInt(trainingTips.length)];
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        progress.add({
          'day': progress.length + 1,
          'quantity': double.parse(quantity),
          'quality': double.parse(quality),
        });
        submitted = true;
      });
    }
  }

  void handleDisputeSubmit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Concern Submitted"),
        content:
            const Text("Your concern has been submitted to the supervisor."),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                dispute = '';
              });
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  // Adding message to chat
  void addMessage(String message) {
    setState(() {
      chatMessages.add(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Harvest Report')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showMidDayAlert)
              AlertDialog(
                title: const Text("Mid-day Reminder"),
                content: const Text(
                    "You're halfway through the day! Keep up the good work."),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showMidDayAlert = false;
                      });
                    },
                    child: const Text("OK"),
                  )
                ],
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today\'s Harvest',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Quantity (tonnes)'),
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          quantity = value!;
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter quantity';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Quality Score (1-5)'),
                        keyboardType: TextInputType.number,
                        onSaved: (value) {
                          quality = value!;
                        },
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              double.tryParse(value)! < 1 ||
                              double.tryParse(value)! > 5) {
                            return 'Please enter a quality score between 1 and 5';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: handleSubmit,
                        child: const Text("Submit"),
                      )
                    ],
                  ),
                ),
              ),
            ),
            if (submitted)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Summary',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(getFeedback(
                              double.parse(quantity), double.parse(quality))),
                          const SizedBox(height: 8),
                          Text(
                              'Bonus earned: RM${getBonus(double.parse(quality))}'),
                          const SizedBox(height: 8),
                          Text('Tip of the day: ${getRandomTip()}'),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Your Progress',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          ...progress.map((day) => Text(
                              'Day ${day['day']}: ${day['quantity']} tonnes, Quality: ${day['quality']} stars')),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            // Image inside the "Raise a Concern" section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TextField for raising a concern
                    Text('Raise a Concern',
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    const SizedBox(height: 24),
                    const SizedBox(height: 8),
                    Image.asset('images/default_img.avif', height: 150),
                    Row(
                      children: [
                        // TextField for describing the concern
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              labelText: 'Describe your concern',
                            ),
                            onChanged: (value) {
                              setState(() {
                                dispute = value;
                              });
                            },
                            controller: TextEditingController(text: dispute),
                          ),
                        ),

                        // Adding a small space between the text field and the voice chat icon
                        const SizedBox(width: 8),

                        // Voice chat icon button
                        IconButton(
                          icon: const Icon(Icons.mic),
                          onPressed: () {
                            // Add your voice chat functionality here
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Submit concern button
                    ElevatedButton(
                      onPressed: handleDisputeSubmit,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flag),
                          SizedBox(width: 8),
                          Text("Submit Concern"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
