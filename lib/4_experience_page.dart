import 'package:flutter/material.dart';
import '5_duration_page.dart';
import 'theme.dart';

class ExperienceLevelPage extends StatelessWidget {
  const ExperienceLevelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Experience Level", style: Theme.of(context).textTheme.headlineLarge),
        backgroundColor: RhythmRunTheme.scaffoldBackgroundColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              RhythmRunTheme.scaffoldBackgroundColor,
              Theme.of(context).colorScheme.primary,
            ],
            stops: const [0, 1],
            begin: AlignmentDirectional(0, 1),
            end: AlignmentDirectional(0, -1),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "How experienced are you as a runner?",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  // TODO: store that choice was beginner
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DurationPage()),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Text(
                  "Beginner",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  // TODO: store that choice was intermediate
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DurationPage()),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Text(
                  "Intermediate",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  // TODO: store that choice was advanced
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => DurationPage()),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Text(
                  "Advanced",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
