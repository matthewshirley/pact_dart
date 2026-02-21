# Contributing to pact_dart

Thanks for contributing! Here’s how to get started:

---

## Run Tests

1. Clone and create a new branch:

```bash
git clone https://github.com/pact-foundation/pact-dart.git
cd pact-dart
git checkout -b my-change
```

2. Install dependencies:

```bash
dart pub get
dart run pact_dart:install
# Or use custom lib download path
PACT_DART_LIB_DOWNLOAD_PATH=. dart run pact_dart:install
```

3. Run tests:

```bash
dart test
# Or use custom lib download path
PACT_DART_LIB_DOWNLOAD_PATH=. dart test -j 1
```

## Generate Bindings with ffigen

1. Download Pact FFI headers

```bash
# Ubuntu
VERSION=0.4.27
wget "https://github.com/pact-foundation/pact-reference/releases/download/libpact_ffi-v$VERSION/pact.h"
# MacOS
VERSION=0.4.27
curl -O "https://github.com/pact-foundation/pact-reference/releases/download/libpact_ffi-v$VERSION/pact.h"
# Windows
$VERSION = "0.4.27"
Invoke-WebRequest -Uri "https://github.com/pact-foundation/pact-reference/releases/download/libpact_ffi-v$VERSION/pact.h" -OutFile "pact.h"
```

2. Install LLVM

```bash
# Ubuntu
sudo apt-get install libclang-dev
# Windows
winget install -e --id LLVM.LLVM
# MacOS
xcode-select --install
```

3. Regenerate bindings:

```bash
dart run ffigen
```

This will update the generated Dart bindings under `lib/gen/library.dart`.
