import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "";
  int happinessLevel = 50;
  int hungerLevel = 50;
  Timer? _hungerTimer;
  Timer? _happinessTimer;
  int happinessTimerSeconds = 0;
  final TextEditingController myController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100).toInt();
      _updateHunger();
      _checkGameOver();
      _startHappinessTimerIfNeeded();
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100).toInt();
      _updateHappiness();
      _checkGameOver();
      _startHappinessTimerIfNeeded();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100).toInt();
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100).toInt();
    }
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100).toInt();
  }

  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 10).clamp(0, 100).toInt();
        _checkGameOver();
      });
    });
  }

  void _startHappinessTimerIfNeeded() {
    if (happinessLevel >= 80 && _happinessTimer == null) {
      happinessTimerSeconds = 0;
      _happinessTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          happinessTimerSeconds++;
          _checkGameOver();
        });
      });
    }
  }

  void _checkGameOver() {
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _hungerTimer?.cancel();
      _happinessTimer?.cancel();
      _showGameOverDialog('Game Over', 'Your pet is too unhappy or hungry!');
    } else if (happinessTimerSeconds >= 180) {
      _hungerTimer?.cancel();
      _happinessTimer?.cancel();
      _showGameOverDialog('You Win', 'Your pet is very happy!');
    }
  }

  void _showGameOverDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("Restart"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  happinessLevel = 50;
                  hungerLevel = 50;
                  _happinessTimer?.cancel();
                  _happinessTimer = null; // Reset happiness timer
                  _startHungerTimer();
                });
              },
            ),
          ],
        );
      },
    );
  }

  Color _getPetColor() {
    if (happinessLevel > 70) {
      return Colors.green; // Happy
    } else if (happinessLevel >= 30) {
      return Colors.yellow; // Neutral
    } else {
      return Colors.red; // Unhappy
    }
  }

  MouthType _getMouthType() {
    if (happinessLevel > 70) {
      return MouthType.smile; // Happy face
    } else if (happinessLevel >= 30) {
      return MouthType.neutral; // Neutral face
    } else {
      return MouthType.frown; // Sad face
    }
  }
  String _getMoodText(){
    if (happinessLevel > 80){
      return "Happy";
    } else if (happinessLevel >= 30){
      return "Neutral";
    } else {
      return "Unhappy";
    }
  }

  void _setPetName(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newName = petName;
        return AlertDialog(
          title: Text('Set Pet Name'),
          content: TextField(
            onChanged: (value) {
              newName = value;
            },
            decoration: InputDecoration(hintText: "Enter your pet's name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                setState(() {
                  petName = newName;
                });
                Navigator.of(context).pop();
              },
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
        title: Text('Digital Pet'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _setPetName(context),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: _getPetColor(),
                    shape: BoxShape.circle,
                  ),
                ),
                // Eyes
                Positioned(
                  top: 50,
                  left: 50,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.black,
                  ),
                ),
                Positioned(
                  top: 50,
                  right: 50,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.black,
                  ),
                ),
                // Mouth
                Positioned(
                  bottom: 40,
                  child: CustomPaint(
                    size: Size(100, 50),
                    painter: MouthPainter(mouthType: _getMouthType()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Text('Name: $petName', style: TextStyle(fontSize: 20.0)),
            Text('Mood: ${_getMoodText()}', style: TextStyle(fontSize: 20.0),),
            Text('Happiness Level: $happinessLevel', style: TextStyle(fontSize: 20.0)),
            Text('Hunger Level: $hungerLevel', style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
            TextField(
              controller: myController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Custom pet name',
              ),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
            onPressed: () {
              setState(() {

                petName = myController.text;

              });
            },
            child: Text('submit'),
          ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _happinessTimer?.cancel();
    super.dispose();
  }
}
enum MouthType { smile, neutral, frown }
class MouthPainter extends CustomPainter {
  final MouthType mouthType;

  MouthPainter({required this.mouthType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (mouthType == MouthType.smile) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi/4, 
        pi/2, 
        false, 
        paint,
      );
    } else if (mouthType == MouthType.neutral) {
     
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
    } else if (mouthType == MouthType.frown) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(center.dx, center.dy + 50), radius: radius), 
            pi,  // Start angle (top of the circle)
           pi,  // Sweep angle (half circle to create a frown)
           false, 
           paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
