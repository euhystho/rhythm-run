#!/bin/bash

# Exit on any error
set -e

# Print debug information to confirm script execution
echo "Running ci_post_clone.sh script..."
echo "Current directory: $(pwd)"
echo "Listing contents of current directory:"
ls -la

# Navigate to the Flutter project directory (repository root)
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Print current directory again for debugging
echo "Current directory after cd: $(pwd)"

# Verify that we are in the Flutter project root
if [ ! -f "pubspec.yaml" ]; then
    echo "Error: pubspec.yaml not found in $(pwd). Are we in the correct directory?"
    exit 1
fi

# Install Homebrew (if not already installed)
if ! command -v brew >/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Install Flutter using Homebrew (or ensure it's installed)
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
echo "Running flutter pub get..."
flutter pub get

# Ensure Generated.xcconfig is created
echo "Building iOS app to generate Generated.xcconfig..."
flutter build ios --release --no-codesign || {
    echo "Error: Failed to generate Generated.xcconfig. Check Flutter setup."
    exit 1
}

# Verify Generated.xcconfig exists
if [ ! -f "ios/Flutter/Generated.xcconfig" ]; then
    echo "Error: Generated.xcconfig not found in ios/Flutter/"
    ls -la ios/Flutter/
    exit 1
else
    echo "Generated.xcconfig found successfully."
fi

# Navigate to the ios directory and run pod install
echo "Running pod install..."
cd ios
pod install