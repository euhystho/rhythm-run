import 'package:flutter/material.dart';
import '6_intensity_page.dart';
import 'theme.dart';


class DurationPage extends StatelessWidget {
  const DurationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Select Duration", style: Theme.of(context).textTheme.headlineLarge),
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
                "Approximately how long do you want your workout to be?",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  // TODO: store that choice was short
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IntensityPage()),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Text(
                  "Short: 10-15 minutes", // subject to change just placeholder for now
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  // TODO: store that choice was medium
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IntensityPage()),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Text(
                  "Medium: 15-20 minutes", // subject to change just placeholder for now
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  // TODO: store that choice was long
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => IntensityPage()),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Text(
                  "Long: 20-25 minutes", // subject to change just placeholder for now
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