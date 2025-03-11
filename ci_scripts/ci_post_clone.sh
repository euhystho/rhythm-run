#!/bin/bash

# Navigate to the Flutter project directory
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Install Homebrew (if not already installed)
if ! command -v brew >/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Install Flutter using Homebrew
if ! command -v flutter >/dev/null; then
    echo "Installing Flutter..."
    brew install --cask flutter
fi

# Install CocoaPods (required for iOS dependencies)
if ! command -v pod >/dev/null; then
    echo "Installing CocoaPods..."
    brew install cocoapods
fi

# Run Flutter doctor to check setup
flutter doctor

# Get Flutter dependencies
flutter pub get

# Build the iOS app (without code signing, as Xcode Cloud handles it)
flutter build ios --release --no-codesign