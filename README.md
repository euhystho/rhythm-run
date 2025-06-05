# RhythmRun 🏃‍♂️🎵

*Running Pacing Through Music Synchronization*

Whether you're a first-time runner or elite marathon athlete, pacing runs remains one of the most difficult aspects of endurance running. Knowing how to pace effectively is imperative to avoiding injury and achieving long-term goals. **RhythmRun** offers a unique, entertaining, and engaging way for runners of all levels to make consistent pacing straightforward.
  
## 🎯 The Problem

- **Inconsistent pacing** leads to burnout, injury, and poor performance
- **Traditional pacing methods** (GPS watches, apps) are reactive, not proactive
- **Lack of engagement** makes maintaining steady pace mentally challenging
- **One-size-fits-all** solutions don't adapt to individual music preferences

## ✨ The Solution

RhythmRun uses **real-time music tempo analysis** to match your running cadence with your favorite songs, creating an immersive experience that naturally guides your pace through your favorite music!

## 🎯 Target Audience

- **Beginner Runners**: Learn proper pacing without expensive equipment
- **Casual Fitness Enthusiasts**: Make workouts more enjoyable
- **Competitive Athletes**: Fine-tune pacing for race preparation
- **Music Lovers**: Combine passion for music with fitness goals

## 🚀 Key Features

### 🎵 Music Integration
- **Spotify API Integration**: Access your personal playlists and music library
- **Last.FM Integration**: Discover new music based on your music preferences
- **Real-time BPM Analysis**: Automatic tempo detection and matching
- **Dynamic Playlist Generation**: Songs curated for your target pace

### 📱 Cross-Platform Authentication
- **Sign in with Apple**: Seamless iOS integration
- **Google Authentication**: Universal access across devices
- **Email/Password**: Traditional signup option
- **Supabase Backend**: Secure user data management

### 🏃‍♀️ Training Features (*future implementation*)
- **Target Pace Setting**: Customize based on your fitness goals
- **Progressive Training**: Gradually improve your pacing consistency
- **Workout History**: Track your improvement over time

## 📊 How It Works

1. **Setup**: Connect your Spotify account and set target pace
2. **Analysis**: App analyzes your music library for BPM patterns
3. **Matching**: Songs are selected to match your target running cadence

## 🛠️ Technical Stack

### Frontend
- **Flutter 3.x**: Cross-platform mobile development
- **Dart**: Primary programming language

### Backend & APIs
- **Supabase**: Authentication and database management
- **Spotify Web API**: Music streaming and playlist access
- **Last.FM API**: Music discovery and recommendations
- **Python Scripts**: Backend data processing and API orchestration

### Development Tools
- **GitHub Projects**: Agile project management with Kanban boards
- **Gantt Charts**: Timeline planning and milestone tracking
- **Team Collaboration**: Multi-developer workflow management

## 📋 Prerequisites

Before running this project, ensure you have:

- **JDK v17** or higher
- **Android NDK ≥ v27**
- **Flutter SDK** (latest stable version)
- **iOS Development Environment** (Xcode, iOS Simulator)
- **API Keys** for Spotify and Last.FM (see setup guide)

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone https://github.com/euhystho/rhythm-run.git
cd rhythm-run
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Setup
```bash
# Copy environment template
cd assets
cp .env.example .env

# Add your API keys to .env
SPOTIFY_CLIENT_ID=your_spotify_client_id
SPOTIFY_CLIENT_SECRET=your_spotify_client_secret
LASTFM_API_KEY=your_lastfm_api_key
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
BPM_API_KEY=your_get_song_bpm_key
```

### 4. Run the App
```bash
# iOS Simulator
flutter run -d ios

# Physical device
flutter run --release
```

## 🤝 Contributing

This project was developed as part of a Software Engineering course at Ursinus College. We welcome external contributions, feedback, and suggestions!

### Development Team
- **iOS Developer & Backend Integrator**: [Eugene](https://github.com/euhystho) - iOS development, Spotify API integration, Supabase authentication & database
- **Android & File Management Developer**: [Khoi](https://github.com/nanodu2604) - Localfile mangement systems, Android platform development, BPM analysis
- **UI/UX Designer**: [Isabelle](https://github.com/isabelleson) - App design, user interface mockups, proof-of-concept development
- **QA Engineer**: [Michael](https://github.com/WorryMichael) - Unit testing and quality control
- **Technical Documentation Lead**: [Mia](https://github.com/misideris) - Project documentation and user guides

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📝 Feedback

Have suggestions? We'd love to hear from you:
- **Issues**: [GitHub Issues Page](https://github.com/euhystho/rhythm-run/issues)

---

*Developed by the Hopper Hackers Software Development Team at Ursinus College*
