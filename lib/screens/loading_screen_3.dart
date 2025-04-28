import 'package:flutter/material.dart';
import 'experience_screen_4.dart';
import '../utils/theme.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    
    // TODO: implement BPM analysis here
    // TODO: navigate to the user selection screen after processing... TEMPORARY BUTTON BELOW
    // ElevatedButton(
    //   onPressed: () {
    //     Navigator.push(
    //         context,
    //         MaterialPageRoute(builder: (context) => ExperienceLevelPage()),
    //       );
    //   },
    //   style: ElevatedButton.styleFrom(
    //     backgroundColor: Theme.of(context).colorScheme.tertiary,
    //   ),
    //   child: Text("Experience (temp button)",
    //       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
    //             color: Theme.of(context).colorScheme.onTertiary,
    //           )),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Loading Text
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Analyzing BPM...",
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
            ),

            // Container(
            //   width: 200,
            //   height: 200,
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Image.asset(
            //     'running.gif', // TODO: replace with actual path, most likely from an assets folder
            //     fit: BoxFit.cover,
            //   ),
            // ),

            const SizedBox(height: 30),

            // can do heart spinner option also
            loadingIndicator(context),
          ],
        ),
      ),
    );
  }
}
