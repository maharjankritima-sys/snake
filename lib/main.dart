
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

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

// HOME SCREEN
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

// GAME SCREEN
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  static const int gridSize = 20;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  List<int> snakeCells = [210, 211, 212];
  int direction = -20;
  int foodCell =150;
  int score = 0;

  Timer? gameTimer;
  bool gameOver = false;

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

  // CHANGE DIRECTION
  void changeDirection(int newDirection) {
    if (gameOver) return;

    // Prevent the snake from reversing into itself.
    if (newDirection == -direction) return;

    setState(() {
      direction = newDirection;
    });
  }

  // MOVE SNAKE AND CHECK WALL COLLISION
  void moveSnake() {
    if (gameOver) return;

    final head = snakeCells.last;
    final newHead = head + direction;

    final hitsTop = direction == -20 && head < 20;
    final hitsBottom = direction == 20 && head >= 380;
    final hitsLeft = direction == -1 && head % 20 == 0;
    final hitsRight = direction == 1 && head % 20 == 19;

    if (newHead < 0 ||
        newHead >= 400 ||
        hitsTop ||
        hitsBottom ||
        hitsLeft ||
        hitsRight) {
      gameTimer?.cancel();

      setState(() {
        gameOver = true;
      });

      return;
    }

    setState(() {
      snakeCells.add(newHead);
      if (newHead == foodCell) {
        score++;
        foodCell = Random().nextInt(400);
      }
      else{
        snakeCells.removeAt(0);
      }
    });
  }

  // RESTART GAME
  void restartGame() {
    gameTimer?.cancel();

    setState(() {
      snakeCells = [210, 211, 212];
      direction = -20;
      gameOver = false;
    });

    gameTimer = Timer.periodic(
      const Duration(milliseconds: 300),
      (timer) {
        moveSnake();
      },
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      appBar: AppBar(
        title: const Text('🐍 Snake Game'),
        backgroundColor: const Color(0xFF101820),
        foregroundColor: Colors.greenAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Score: $score',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.greenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
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
                  child: Stack(
                    children: [
                      GridView.builder(
                        physics:
                            const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: GameScreen.gridSize *
                            GameScreen.gridSize,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: GameScreen.gridSize,
                        ),
                        itemBuilder: (context, index) {

                          if (snakeCells.contains(index)) {
                            return Container(
                              margin: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: Colors.greenAccent,
                                borderRadius:
                                    BorderRadius.circular(3),
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
                              borderRadius:
                                  BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),

                      if (gameOver)
                        Container(
                          color: Colors.black87,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'GAME OVER',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: restartGame,
                                  child: const Text('PLAY AGAIN'),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Text(
            'Use the arrows to control the snake',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          IconButton(
            onPressed: () => changeDirection(-20),
            icon: const Icon(Icons.arrow_upward),
            color: Colors.greenAccent,
            iconSize: 36,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => changeDirection(-1),
                icon: const Icon(Icons.arrow_back),
                color: Colors.greenAccent,
                iconSize: 36,
              ),
              const SizedBox(width: 32),
              IconButton(
                onPressed: () => changeDirection(20),
                icon: const Icon(Icons.arrow_downward),
                color: Colors.greenAccent,
                iconSize: 36,
              ),
              const SizedBox(width: 32),
              IconButton(
                onPressed: () => changeDirection(1),
                icon: const Icon(Icons.arrow_forward),
                color: Colors.greenAccent,
                iconSize: 36,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}