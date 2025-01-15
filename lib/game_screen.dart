import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'word_list.dart';
import 'dart:async';
import 'dart:math';

enum GameState { START, GUESSING, CORRECT, SKIP, END }

class GameScreen extends StatefulWidget {
  final String category;
  final int timeLimit;

  const GameScreen(
      {super.key, required this.category, required this.timeLimit});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Duration _countDownDuration = const Duration(seconds: 3);
  String _countDownDisplayText = 'Ready?';
  Timer? _countDownTimer;

  late final List<String> _words = wordlist[widget.category]!;

  String _currentWord = '';
  List<Word> _guessedWords = [];
  final Random _random = Random();

  late Duration _gameDuration = Duration(seconds: widget.timeLimit);
  late int _gameCurrentTime = widget.timeLimit;
  Timer? _gameTimer;

  String currentWord = '';

  GameState _gameState = GameState.START;

  // late String _displayText;

  @override
  void initState() {
    super.initState();
    updateCurrentWord();
    _startCountDownTimer();
    _setPreferredOrientation();
  }

  void _setPreferredOrientation() {
    if (_gameState == GameState.END) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitUp,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  void _startCountDownTimer() {
    _countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countDownDisplayText = _countDownDuration.inSeconds.toString();
        _countDownDuration = _countDownDuration - const Duration(seconds: 1);
      });

      if (_countDownDuration.inSeconds <= 0) {
        _countDownTimer?.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            _gameState = GameState.GUESSING;
            _startGameTimer();
          });
        });
      }
    });
  }

  void _startGameTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameDuration.inSeconds <= 0) {
        setState(() {
          _gameState = GameState.END;

          _guessedWords.add(Word(word: _currentWord, canGuess: false));
          _setPreferredOrientation();
        });
        // Countdown is finished
        _gameTimer?.cancel();
        // Perform any desired action when the countdown is completed
      } else {
        // Update the countdown value and decrement by 1 second
        setState(() {
          _gameCurrentTime = _gameDuration.inSeconds;
          _gameDuration = _gameDuration - const Duration(seconds: 1);
        });
      }
    });
  }

  void updateCurrentWord() {
    setState(() {
      _currentWord = _words[_random.nextInt(_words.length)];
    });
  }

  void _handleLeftPress() {
    if (_gameState != GameState.GUESSING) {
      return;
    }

    setState(() {
      _gameState = GameState.CORRECT;
      _guessedWords.add(Word(word: _currentWord, canGuess: true));
    });
    updateCurrentWord();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _gameState = GameState.GUESSING;
      });
    });
  }

  void _handleRightPress() {
    if (_gameState != GameState.GUESSING) {
      return;
    }
    setState(() {
      _gameState = GameState.SKIP;
      _guessedWords.add(Word(word: _currentWord, canGuess: false));
    });
    updateCurrentWord();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _gameState = GameState.GUESSING;
      });
    });
  }

  void resetGame() {
    setState(() {
      _countDownDuration = const Duration(seconds: 3);
      _countDownDisplayText = 'Ready?';
      _gameDuration = Duration(seconds: widget.timeLimit);
      _gameCurrentTime = widget.timeLimit;
      _guessedWords = [];
      _gameState = GameState.START;
    });
    updateCurrentWord();
    _startCountDownTimer();
    _setPreferredOrientation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _gameState == GameState.END
          ? AppBar(
              title: Text(widget.category),
            )
          : null,
      body: GestureDetector(
        onTapUp: (details) {
          // Detect left or right side of the screen tap
          double width = MediaQuery.of(context).size.width;
          if (details.localPosition.dx < width / 2) {
            _handleLeftPress();
          } else {
            _handleRightPress();
          }
        },
        child: SizedBox(
          width: double.infinity, // Ensures full screen width
          height: double.infinity, // Ensures full screen height
          child: Stack(
            children: [
              // Background divided into two halves
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.green.withOpacity(0.0),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(
                      color: Colors.red.withOpacity(0.0),
                    ),
                  ),
                ],
              ),
              // Content on top of the background
              Center(
                child: Builder(
                  builder: (context) {
                    switch (_gameState) {
                      case GameState.START:
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _countDownDisplayText,
                              style: const TextStyle(
                                fontSize: 60.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      case GameState.GUESSING:
                        return Stack(
                          children: [
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                '$_gameCurrentTime',
                                style: const TextStyle(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                _currentWord,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:
                                      (_currentWord.length) > 20 ? 40.0 : 60.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        );
                      case GameState.SKIP:
                        return const Center(
                          child: Text(
                            'SKIP',
                            style: TextStyle(
                              fontSize: 60.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        );
                      case GameState.CORRECT:
                        return const Center(
                          child: Text(
                            'Correct!',
                            style: TextStyle(
                              fontSize: 60.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        );
                      case GameState.END:
                        return buildEndScreen(context);
                      default:
                        return Container();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEndScreen(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
            itemCount: _guessedWords.length,
            itemBuilder: (context, index) {
              final word = _guessedWords[index].word;
              final canGuess = _guessedWords[index].canGuess;

              return ListTile(
                leading: Icon(
                  canGuess ? Icons.check_circle : Icons.cancel,
                  color: canGuess ? Colors.green : Colors.red,
                ),
                title: Text(
                  word,
                  style: const TextStyle(fontSize: 20),
                ),
              );
            }),
        Positioned(
          bottom: 20,
          right: 20,
          child: Row(
            children: [
              TextButton(
                onPressed: () {
                  // Add logic to restart the game
                  resetGame();
                },
                child: const Text(
                  'Restart',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20), // Space between the buttons
              TextButton(
                onPressed: () {
                  // Add logic to navigate to the home screen or main menu
                  Navigator.pop(
                      context); // For example, going back to the previous screen
                },
                child: const Text(
                  'Home',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Word {
  final String word;
  final bool canGuess;

  Word({required this.word, this.canGuess = true});
}
