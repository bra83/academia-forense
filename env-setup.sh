#!/bin/bash
# Environment setup for Academia Forense
export FLUTTER_ROOT="/home/antigravity/tools/flutter"
export PATH="/home/antigravity/tools/flutter/bin:/home/antigravity/tools/flutter/bin/cache/dart-sdk/bin:$PATH"

echo "Flutter $(flutter --version | head -n 1) is configured in PATH."
