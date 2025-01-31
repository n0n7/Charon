import 'package:flutter/material.dart';
import 'game_screen.dart';

class StartGameDialog extends StatelessWidget {
  final String category;

  StartGameDialog({super.key, required this.category});

  final List<int> timeLimitOptions = [90, 120, 180, 240, 300];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      title: Text(category),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select Time Limit:'),
          const SizedBox(height: 10.0),
          Wrap(
            spacing: 10.0, // Space between buttons horizontally
            runSpacing: 10.0, // Space between rows of buttons
            alignment: WrapAlignment.center, // Center align buttons
            children: timeLimitOptions
                .map((timeLimit) => _buildTimeButton(context, timeLimit))
                .toList(),
          )
        ],
      ),
    );
  }

  Widget _buildTimeButton(BuildContext context, int timeLimit) {
    return ElevatedButton(
      onPressed: () {
        Navigator.pop(context);
        // Start the game with the selected category and time limit
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(category: category, timeLimit: timeLimit),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
      ),
      child: Text(timeLimit.toString()),
    );
  }
}
