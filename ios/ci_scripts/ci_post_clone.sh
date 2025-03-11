#!/bin/sh

# Fail this script if any subcommand fails.
set -e

# Change to the repository root
cd "$CI_PRIMARY_REPOSITORY_PATH"

# Install Flutter using git.
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Install Flutter artifacts for iOS (--ios), or macOS (--macos) platforms.
flutter precache --ios
echo "Running flutter pub get..."
flutter pub get

# Install CocoaPods
echo "Installing CocoaPods via Homebrew..."
HOMEBREW_NO_AUTO_UPDATE=1 brew install cocoapods

# Run pod install with error checking
echo "Running pod install..."
pod install || {
    echo "Error: pod install failed."
    exit 1
}

# Verify Pods_Runner framework existence
echo "Checking for Pods_Runner framework..."
if [ -d "Pods/Runner" ]; then
    echo "Pods_Runner framework found at ios/Pods/Runner."
    ls -la "Pods/Runner"
else
    echo "Error: Pods_Runner framework not found in ios/Pods."
    exit 1
fi

# Ensure framework search paths (optional diagnostic step)
echo "Pods directory contents:"
ls -la Pods

exit 0