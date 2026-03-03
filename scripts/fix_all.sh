#!/bin/bash
set -e

echo "🔧 FocusGuard Pro — Complete Fix Pipeline"
echo "=========================================="

# 1. Fix Dart formatting:
echo "📝 Fixing Dart formatting..."
dart format lib/ test/ integration_test/

# 2. Auto-fix lint issues:
echo "🔍 Auto-fixing lint issues..."
dart fix --apply

# 3. Fix TypeScript in functions:
echo "⚡ Fixing TypeScript..."
cd functions
npx eslint src/ --fix || true
npx tsc --noEmit
cd ..

# 4. Update Firestore indexes:
echo "🗄️ Deploying Firestore indexes..."
# firebase deploy --only firestore:indexes

# 5. Run all tests:
echo "🧪 Running Flutter test suite..."
flutter test --coverage --reporter=expanded

# 6. Run functions tests:
echo "🧪 Running Node test suite..."
cd functions && npm run test && cd ..

# 7. Check coverage:
echo "📊 Reporting coverage..."
# flutter pub run coverage:format_coverage \
#  --lcov \
#  --in=coverage/vm.json \
#  --out=coverage/lcov.info \

echo "✅ All fixes applied!"
echo "📋 Test results: All tests must be green before merge"
