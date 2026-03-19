#!/bin/bash
set -e
git clone https://github.com/flutter/flutter.git --depth 1 -b stable /opt/flutter
export PATH="$PATH:/opt/flutter/bin"
flutter config --enable-web
flutter pub get
flutter build web --release