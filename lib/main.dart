
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  int foodCell = 150;
  int score = 0;
  int highScore = 0;

  Timer? gameTimer;
  bool gameOver = false;

  final FocusNode gameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    loadHighScore();

    gameTimer = Timer.periodic(
      const Duration(milliseconds: 300),
      (timer) => moveSnake(),
    );
  }

  // LOAD SAVED HIGH SCORE
  Future<void> loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    final savedScore = prefs.getInt('highScore') ?? 0;

    if (!mounted) return;

    setState(() {
      highScore = savedScore;
    });
  }

  // SAVE HIGH SCORE
  Future<void> saveHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('highScore', highScore);
  }

  // CHANGE DIRECTION
  void changeDirection(int newDirection) {
    if (gameOver) return;
    if (newDirection == -direction) return;

    setState(() {
      direction = newDirection;
    });
  }

  // KEYBOARD CONTROLS
  void handleKeyPress(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowUp:
        changeDirection(-20);
        break;
      case LogicalKeyboardKey.arrowDown:
        changeDirection(20);
        break;
      case LogicalKeyboardKey.arrowLeft:
        changeDirection(-1);
        break;
      case LogicalKeyboardKey.arrowRight:
        changeDirection(1);
        break;
      default:
        break;
    }
  }

  // MOVE SNAKE AND CHECK COLLISIONS
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

        // Save a new record when the player beats it.
        if (score > highScore) {
          highScore = score;
          saveHighScore();
        }

        // Spawn food outside the snake.
        do {
          foodCell = Random().nextInt(400);
        } while (snakeCells.contains(foodCell));
      } else {
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
      foodCell = 150;
      score = 0;
      gameOver = false;
    });

    gameFocusNode.requestFocus();

    gameTimer = Timer.periodic(
      const Duration(milliseconds: 300),
      (timer) => moveSnake(),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    gameFocusNode.dispose();
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
      body: KeyboardListener(
        focusNode: gameFocusNode,
        autofocus: true,
        onKeyEvent: handleKeyPress,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    'Score: $score',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Best: $highScore',
                    style: const TextStyle(
                      fontSize: 22,
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
                                  const SizedBox(height: 12),
                                  Text(
                                    'Score: $score',
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(
                                    'Best Score: $highScore',
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 20,
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
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Use keyboard arrow keys to control the snake',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
