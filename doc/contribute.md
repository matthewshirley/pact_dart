# Contributing to pact_dart

Thanks for contributing! Here’s how to get started:

---

## Run Tests

1. Clone and create a new branch:

```bash
git clone https://github.com/matthewshirley/pact_dart.git
cd pact_dart
git checkout -b my-change
```

2. Install dependencies:

```bash
dart pub get
dart run pact_dart:install
# Or use custom lib download path
PACT_DART_LIB_DOWNLOAD_PATH=. dart run pact_dart:install --include-headers
```

3. Run tests:

```bash
dart test
# Or use custom lib download path
PACT_DART_LIB_DOWNLOAD_PATH=. dart test -j 1
```

## Generate Bindings with ffigen

1. Install LLVM

```bash
# Ubuntu
sudo apt-get install libclang-dev
# Windows
winget install -e --id LLVM.LLVM
# MacOS
xcode-select --install
```

2. Regenerate bindings:

```bash
dart run ffigen
```

This will update the generated Dart bindings under `lib/gen/library.dart`.

## Analyze and Format code

```bash
dart analyze
dart format .
```
