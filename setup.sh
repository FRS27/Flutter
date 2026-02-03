#!/bin/bash

echo "🚀 IntelliResearch AI - Flutter App Setup"
echo "=========================================="
echo ""

# Check Flutter installation
if ! command -v flutter &> /dev/null
then
    echo "❌ Flutter is not installed!"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter found!"
flutter --version
echo ""

# Get dependencies
echo "📦 Installing dependencies..."
flutter pub get

if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed successfully!"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo ""
echo "⚙️  Configuration needed:"
echo "1. Open lib/services/research_service.dart"
echo "2. Update the 'baseUrl' with your backend URL"
echo ""
echo "For local testing, find your IP address:"
echo "  - Windows: ipconfig"
echo "  - Mac/Linux: ifconfig"
echo ""
echo "Then use: http://YOUR_IP:8000"
echo ""
echo "🎉 Setup complete! Run with: flutter run"
