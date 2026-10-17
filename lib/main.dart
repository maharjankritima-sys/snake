
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const SnakeGame());
}

class SnakeGame extends StatelessWidget {
  const SnakeGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🐍 SNAKE GAME',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Are you ready to play?',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
           ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GameScreen(),
      ),
    );
  },
  child: const Text('START GAME'),
),
          ],
        ),
      ),
    );
  }
}


class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const int gridSize = 20;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<int> snakeCells = [210, 211, 212];
  int direction = -20;
  Timer? gameTimer;
  @override
  void initState() {
    super.initState();

    gameTimer = Timer.periodic(
      const Duration(milliseconds: 300),
      (timer) {
        moveSnake();
      },
    );
  }
  void moveSnake() {
    setState(() {
      final newHead = snakeCells.last + direction ;
      snakeCells.add(newHead);
      snakeCells.removeAt(0);
    });
  }
  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        title: const Text('Snake Game'),
        backgroundColor: const Color(0xFF101820),
        foregroundColor: Colors.greenAccent,
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838),
              border: Border.all(
                color: Colors.greenAccent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: GameScreen.gridSize * GameScreen.gridSize,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: GameScreen.gridSize,
              ),
              itemBuilder: (context, index) {
                const foodCell = 150;

                if (snakeCells.contains(index)) {
                  return Container(
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }

                if (index == foodCell) {
                  return const Center(
                    child: Text(
                      '🍎',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF263747),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}