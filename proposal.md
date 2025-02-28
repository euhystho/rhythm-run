## Proposal 
**Group Members:** Khoi Nguyen, Michael Santella, Mia Sideris, Isabelle Son, and Eugene Thompson

**Date:** February 5th, 2025

**Application Name:** RhythmRun: A proposal to design and implement a music-centered endurance running application

**GitHub Repository:** [https://github.com/euhystho/rhythm-run](https://github.com/euhystho/rhythm-run)

The following is a proposal to design and implement a music-centered endurance running application. We outline the need, the functional description, the environment and implementation details, and the corresponding business model identifying our schedule and resources required to successfully create this application.

# Why is Pacing so Important?

Whether you are a first-time runner or an elite marathon athlete, pacing runs remains one of the most difficult aspects of endurance running. Knowing how to pace runs effectively is imperative to avoiding injury and upholding long-term goals in the sport. "Pacing" refers to the overall speed at which a runner will cover a specific distance. A runner's pace will alter depending on the desired distance--upholding a 5-minute mile pace may be achievable for a singular mile, but attempting to run 8 miles at this speed requires exceptional talent! Endurance runners often set out to achieve their fastest times by breaking down their "splits," or dividing their run into small portions to gauge performance incrementally. For example, if the goal is to run an 18-minute 5k, the necessary split per mile would be 5:48.39. The challenge resides in the runner's ability to accurately perceive their desired splits during a race, or even a typically easy jog. Of course, most runners may be able to roughly estimate their paces during a run, but keeping mental track of the exact paces is impossible. Misinterpreting an 8:30 mile for an 8:49 mile can easily make or break one's personal goals. Additionally, it is frequent for less-experienced runners to push the pace faster in the beginning of a run, but significantly slow down towards the end. Effectively gauging pace can prevent "running out of fuel" at the end of a run and make the overall running experience feel more feasible and the individual less susceptible to injury. Thus, RhythmRun will offer a unique, entertaining, and engaging way for runners of all levels, regardless of their goals, to make the process of achieving consistency straightforward!

## Stakeholder groups:

The program is designed to cater to a wide range of users, from complete beginners with no prior running experience to seasoned professional runners. RhythmRun aims to revolutionize the way people approach running by leveraging the power of music to enhance endurance, motivation, and performance. For beginners, the app provides a structured yet flexible experience by measuring heart rate and running pace in real-time, automatically adjusting the music tempo and intensity to match their optimal performance zone. This personalized approach helps users achieve their running goals more efficiently compared to traditional methods, making the process less intimidating, more enjoyable, and highly effective. For experienced runners, RhythmRun offers advanced features to fine-tune their training, optimize performance, and break through plateaus.

Accessibility is a key focus of RhythmRun. With just a basic tracking device, such as a smartwatch or fitness tracker paired with a smartphone, users can seamlessly integrate the app into their running routine. The app adapts to individual preferences and fitness levels, offering personalized music playlists, tempo-based coaching, and real-time feedback to keep users motivated and on track. Whether someone is training for a marathon, improving their fitness, or simply looking to enjoy a more engaging running experience, RhythmRun is designed to meet their needs and help them achieve their goals efficiently and enjoyably.

## Roles and Technical Expertise:

Below are the initial roles starting from February 10th to March 3rd.

**Project Lead**: Isabelle Son

- **Responsibilities:** As project lead, Isabelle is responsible for ensuring that everyone remains on schedule and adjusts the schedule with the group as needed.

- **Technical Expertise:**
  - Full Stack Development
  - Languages:
    - C/C++/Java/Python

**Document Lead**: Mia Sideris

- **Responsibilities:** As document lead, Mia is responsible for ensuring that the progress reports are well-organized and written, representing the group.

- **Technical Expertise:**
  - Frontend Development and Data Science
  - Programming Languages:
    - Web Development: CSS/HTML/JavaScript/Node.js/React.js
    - C++/Java/Python/R

**Scrum Lead**: Khoi Nguyen

- **Responsibilities:** As scrum lead, Khoi is responsible for leading project group meetings, preparing meeting agendas, and keeping project meeting minutes that will be included in a periodic scrum reflection report.

- **Technical Expertise:**
  - Backend Development
  - Programming Languages: C/C++/Python/Java/Javascript

**Code Lead**: Eugene Thompson

- **Responsibilities:** As code lead, Eugene is responsible for the codebase and the GitHub repository and ensuring that code coverage is sufficient and that test cases pass.

- **Technical Expertise:**
  - Full Stack Development and Data Science
  - Programming Languages:
    - Web Development: CSS/HTML/JavaScript
    - C++/Java/Python/R

**Administrative Assistant**: Michael Santella

- **Responsibilities:** As an administrative assistant, Michael is responsible for extraneous activities not covered by the previous roles while helping out the scrum and document leads.

- **Technical Expertise:**
  - Full Stack Development
  - Programming Languages:
    - Web Development: CSS/HTML/JavaScript
    - Python/Scheme

### Potential Technical Obstacles and Solutions:

Some of the potential technical obstacles are API integration with popular music streaming services (e.g. Spotify, SoundCloud, Apple Music), leveraging these integrations by adding playlists and finding songs with similar genres, tempos, or lengths. Since this project is most likely going to be a mobile application, then mobile app development tools like Flutter are going to be a learning challenge. Also, because most of the group hasn't taken the course "Digital Music Processing," except for Khoi and Mia, it will be a bit more difficult to do certain tasks like matching running pace to BPM (beats per minute). However, the music limitation can be addressed with careful planning and collaboration with Dr. Chris Tralie on any problems that arise. Lastly, implementing path tracking requires learning how to privately store and track location data through an app and then displaying it on a map environment like Google Maps.

### Role Rotation Schedule:

| Rotation Periods | Project Lead | Document Lead | Scrum Lead | Code Lead | Administrative Assistant |
|------------------|--------------|--------------|------------|-----------|--------------------------|
| February 10 to March 3 | Isabelle | Mia | Khoi | Eugene | Michael |
| March 3 to 7; March 17 to 21 | Eugene | Michael | Mia | Khoi | Isabelle |
| March 24 to April 7 | Michael | Eugene | Isabelle | Mia | Khoi |
| April 7 to April 28 | Mia | Khoi | Michael | Isabelle | Eugene |
| April 28 to May 8 | Khoi | Isabelle | Eugene | Michael | Mia |

## Minimum Scope:

Users will be able to upload their own playlists from local files. The app will then analyze the BPM of each song and aggregate the appropriate songs into a new playlist, considering intensity and length of intensity. The app should offer at least one type of structured workout that will modulate between high-intensity and low-intensity songs. The user will be able to manually input and adjust the tempo of songs if needed.

## Aspirant Scope:

The app will integrate APIs like Spotify and Apple Music to provide a convenient way for the user to upload their desired playlist. There will be multiple workout options, and the user will be able to customize them by adjusting factors like song order, intensity levels, and duration. If there are songs with specific tempos or lengths that are needed for a workout template, the app will make the user aware and suggest potential songs to add to the workout playlist based on the genre of the songs that have already been uploaded. Additionally, if the user chooses, the app will have the ability to subtly adjust the tempos of songs in order to make them more suitable for a specific pace or intensity. The app may also cut off or fade out songs that are too long for a part of a workout. The app may include haptic or voice feedback to notify the user about intensity shifts during their workouts and integrate with devices like smartwatches to track and provide insights on heart rate. Lastly, the app will include GPS-based path tracking that will incorporate details like distance, elevation, speed changes, and split times.

## Timeline of Project Scope:

| Deadline | Process |
|----------|---------|
| Feb 10-Feb 17 | Upload local, playlist features, tempo adjustment |
| Feb 17-Feb 24 | Analyze BPM and filter songs |
| Feb 24-March 3 | Unit test |

## Intellectual Merit:

Running is one of the most fundamental exercises a human can do. In fact, our ability to run for longer periods of time (at least in hot or warm climates) than any other animal in the world is arguably one of the three reasons that humans were able to dominate the natural world (the other two reasons being our throwing capabilities and, of course, our intelligence). Another fundamental human trait is our fondness for music, whether we create it or whether we are "mere" listening enjoyers of it. This aligns well with the fact that many people listen to music as they run; the combination of the two is so basic to humans that it is like putting two Lego bricks together. Yet despite that, seemingly no one has tried to create an app that incorporates the type of music you are listening to with the pace you are running at. This is why RhythmRun was born.

## Broader Impacts:

The purpose of RythmRun may not be apparent to those unfamiliar to the sport of endurance running; after all, it is generally already common to listen to music while running, so what more can be done? Although listening to music while running is already an established tradition, there is currently no consistent or universal way to match the tempo of the song you are listening to with the pace at which you are running. Even if a runner chooses to customize his or her playlist to match his or her intended pace, this song choice may not match the runner's taste in music. Additionally, a relatively low BPM could subconsciously encourage a runner to slow down while a song with a relatively high BPM could cause the runner to speed up, both of which have the potential to sabotage the achievement of personal goals. RhythmRun thus seeks to assist the runner who is concerned about this happening in preventing it before it can start.

[Link to the Proposal PDF](/Proposal.pdf)
