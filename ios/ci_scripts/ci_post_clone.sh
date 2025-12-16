#!/bin/sh

# ci_post_clone.sh
# This script runs on Xcode Cloud after cloning your repository
# It sets up Flutter and builds the iOS app

set -e  # Exit on error

echo "🔧 Starting Xcode Cloud post-clone setup..."

# Install Flutter
echo "📥 Installing Flutter..."
git clone https://github.com/flutter/flutter.git --depth 1 -b stable $HOME/flutter
export PATH="$PATH:$HOME/flutter/bin"

# Verify Flutter installation
echo "✅ Verifying Flutter installation..."
flutter --version

# Enable Flutter for iOS
flutter precache --ios

# Navigate to project root
cd $CI_PRIMARY_REPOSITORY_PATH

# Get Flutter dependencies
echo "📦 Getting Flutter dependencies..."
flutter pub get

# Build Flutter iOS app
echo "🔨 Building Flutter iOS app..."
flutter build ios --config-only --no-codesign

echo "✅ Flutter build completed successfully!"
