
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Traffic Simulation',
      theme: ThemeData(
        primarySwatch: Colors.blue,
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
  List<Lane>  lanes = [
          Lane(id: 1, cars: 0, trucks: 0, motorcycles: 0),
          Lane(id: 2, cars: 0, trucks: 0, motorcycles: 0),
          Lane(id: 3, cars: 0, trucks: 0, motorcycles: 0),
          Lane(id: 4, cars: 0, trucks: 0, motorcycles: 0),
          //Lane(id: 5, cars: 0, trucks: 0, motorcycles: 0),
          //Lane(id: 6, cars: 0, trucks: 0, motorcycles: 0)
        ];

  List<Lane> sortedLanes = [];

  late Timer timer;
  bool isRunning = false;
  bool isGreenLight = false;
  int greenLightDuration = 10;
  

  List<String> printStatements = [];

  Lane? laneWithMaxvehiclesweight;

  @override
  void initState() {
    super.initState();
    sortedLanes = List.from(lanes);
    BubbleSortLane(sortedLanes);
  }

  void _startSimulation() {
    if (!isRunning) {
      isRunning = true;
      printStatements.add("Start simulation");
      _toggleTrafficLight();
      timer = Timer.periodic(
          Duration(seconds: 1), (Timer t) => _updateVehicleCounts());
    }
  }

  void _resetSimulation() {
    if (isRunning) {
      timer.cancel();
      setState(() {
        isRunning = false;
        lanes = [
          Lane(id: 1, cars: 0, trucks: 0, motorcycles: 0),
          Lane(id: 2, cars: 0, trucks: 0, motorcycles: 0),
          Lane(id: 3, cars: 0, trucks: 0, motorcycles: 0),
          Lane(id: 4, cars: 0, trucks: 0, motorcycles: 0),
          //Lane(id: 5, cars: 0, trucks: 0, motorcycles: 0),
          //Lane(id: 6, cars: 0, trucks: 0, motorcycles: 0)
        ];
        sortedLanes = List.from(lanes);
        isGreenLight = false;
        greenLightDuration = 0;
        laneWithMaxvehiclesweight = null;
        printStatements.add("Reset simulation");
      });
    }
  }

  void _toggleTrafficLight() {
    setState(() {
      isGreenLight = !isGreenLight;
      greenLightDuration = 10;

      if (isGreenLight) {
        laneWithMaxvehiclesweight =
            lanes.reduce((a, b) => a.vehiclesweight > b.vehiclesweight ? a : b);
        printStatements
            .add("Lane ${laneWithMaxvehiclesweight!.id} toggleTrafficLight -> green");
      } else {
        if (laneWithMaxvehiclesweight != null) {
          printStatements
              .add("Lane ${laneWithMaxvehiclesweight!.id} toggleTrafficLight -> red");
        }
      }
    });
  }

  void _subtractVehicle(int loopcount){
    final random = Random();
    for(int i=0;i<loopcount;i++){
    print(i);
    int vehicleType = random.nextInt(3);
          if (vehicleType == 0 && laneWithMaxvehiclesweight!.cars > 0) {
            laneWithMaxvehiclesweight!.cars -= 1;
          } else {
            vehicleType = random.nextInt(2) + 1;
            if (vehicleType == 1 && laneWithMaxvehiclesweight!.trucks > 0) {
              laneWithMaxvehiclesweight!.trucks -= 1;
            } else if (vehicleType == 2 &&laneWithMaxvehiclesweight!.motorcycles > 0) {
              laneWithMaxvehiclesweight!.motorcycles -= 1;
            }
          }

          if (vehicleType == 1 && laneWithMaxvehiclesweight!.trucks > 0) {
            laneWithMaxvehiclesweight!.trucks -= 1;
          } else {
            vehicleType = random.nextInt(2) * 2;
            if (vehicleType == 0 &&laneWithMaxvehiclesweight!.cars > 0) {
              laneWithMaxvehiclesweight!.cars -= 1;
            } else if (vehicleType == 2 &&laneWithMaxvehiclesweight!.motorcycles > 0) {
              laneWithMaxvehiclesweight!.motorcycles -= 1;
            }
          }

          if (vehicleType == 2 && laneWithMaxvehiclesweight!.motorcycles > 0) {
            laneWithMaxvehiclesweight!.motorcycles -= 1;
          } else {
            vehicleType = random.nextInt(2);
            if (vehicleType == 0 && laneWithMaxvehiclesweight!.cars > 0) {
              laneWithMaxvehiclesweight!.cars -= 1;
            } else if (vehicleType == 1 &&laneWithMaxvehiclesweight!.trucks > 0) {
              laneWithMaxvehiclesweight!.trucks -= 1;
            }
          }
    }
  }
  void _updateVehicleCounts() {
    final random = Random();
    setState(() {
      if (isGreenLight && greenLightDuration > 0) {
        if (laneWithMaxvehiclesweight != null) {
        
            if (laneWithMaxvehiclesweight!.vehiclesweight <= 10) {
              _subtractVehicle(1);
            }
            else if (laneWithMaxvehiclesweight!.vehiclesweight > 10) {
              _subtractVehicle(2);
            }
            else if (laneWithMaxvehiclesweight!.vehiclesweight > 30) {
              _subtractVehicle(3);
            }
            if (laneWithMaxvehiclesweight!.vehiclesweight <= 0) {
              _toggleTrafficLight();
              sortedLanes = List.from(lanes);
              BubbleSortLane(sortedLanes);
              greenLightDuration = 10;
              _toggleTrafficLight();
            }
          laneWithMaxvehiclesweight!.color = Colors.green;
        }

        for (var lane in lanes) {
          if (lane != laneWithMaxvehiclesweight) {
            lane.color = Colors.red;
          }
          // Add a random vehicle to each lane
          int vehicleType = random.nextInt(3);
          if (vehicleType == 0) {
            lane.cars += 1;
          } else if (vehicleType == 1) {
            lane.trucks += 1;
          } else if (vehicleType == 2) {
            lane.motorcycles += 1;
          }
        }
        greenLightDuration--;
        if (greenLightDuration == 0) {
          _toggleTrafficLight();
          sortedLanes = List.from(lanes);
          BubbleSortLane(sortedLanes);
          greenLightDuration = 10;
          _toggleTrafficLight();
        }
      } 

      sortedLanes = List.from(lanes);
      BubbleSortLane(sortedLanes);
    });

    if (greenLightDuration == 0 && !isGreenLight) {
      _toggleTrafficLight();
    }
  }

  @override
  void dispose() {
    if (isRunning) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dynamic Traffic Simulation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: lanes.map((lane) {
                return Column(
                  children: [
                    Text(
                      'Lane ${lane.id}',
                      style: TextStyle(fontSize: 18),
                    ),
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: lane.color ?? Colors.red,
                      child: Text(
                        lane.vehiclesweight.toStringAsFixed(2),
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _startSimulation,
                  child: Text(
                    'Start',
                    style: TextStyle(color: Colors.white),
                  ),
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                ElevatedButton(
                  onPressed: _resetSimulation,
                  child: Text(
                    'Reset',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
            SizedBox(height: 30),
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: sortedLanes.map((lane) {
                    return Text(
                      'Lane ${lane.id}: ${lane.cars.toStringAsFixed(2)}cars ${lane.trucks.toStringAsFixed(2)} trucks ${lane.motorcycles.toStringAsFixed(2)} motorcycle >',
                      style: TextStyle(
                        fontSize: 16,
                        color: lane == laneWithMaxvehiclesweight
                            ? Colors.red
                            : Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text('Print list'),
            SizedBox(height: 10),
            Container(
              height: 250,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: printStatements.map((statement) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(statement),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Lane {
  int id;
  double cars;
  double trucks;
  double motorcycles;

  Color? color;

  Lane({
    required this.id,
    required this.cars,
    required this.trucks,
    required this.motorcycles,
    this.color,
  });

  double get vehiclesweight => cars * 1.0 + trucks * 2.0 + motorcycles * 0.5;
}



void BubbleSortLane(List<Lane> arr) {
  int n = arr.length;

  // print('Initial array:');
  // for (var lane in arr) {
  //   print('Lane ${lane.id}: ${lane.vehiclesweight.toStringAsFixed(2)} vehiclesweight');
  // }
  // print('----------------');

  // Capture the start time before sorting
  var startTime = DateTime.now();


  bool isSorted = false;
  int lastUnsorted = n - 1;

  while (!isSorted) {
    isSorted = true;
    for (int i = 0; i < lastUnsorted; i++) {
      if (arr[i].vehiclesweight < arr[i + 1].vehiclesweight) {
        var temp = arr[i];
        arr[i] = arr[i + 1];
        arr[i + 1] = temp;
        isSorted = false;
      }
      // print('Bubble Sort - Pass $pass - After comparison $i:');
      // for (var lane in arr) {
      //   print('Lane ${lane.id}: ${lane.vehiclesweight.toStringAsFixed(2)} vehiclesweight');
      // }
      // print('----------------');
    }
    lastUnsorted--;

  }

  // Capture the end time after sorting
  var endTime = DateTime.now();
  var duration = endTime.difference(startTime);
  print('Total time taken for sorting: ${duration.inMicroseconds} micros');

  
}

