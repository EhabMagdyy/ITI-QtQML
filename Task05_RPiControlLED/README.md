# Cross-Compiling Qt6 QML For Controlling RPi3b+ LED

This guide documents the full steps to cross-compile a Qt6 QML project that uses `libgpiod` on a host Ubuntu x86_64 machine and run it on a Raspberry Pi 3B+ (aarch64, Raspberry Pi OS Bookworm 64-bit).

---

## Project Overview

| Item | Detail |
|---|---|
| Host OS | Ubuntu x86_64 |
| Target | Raspberry Pi 3B+ (aarch64) |
| Qt version (Pi) | 6.8.2 (via apt) |
| Qt version (Host) | 6.8.3 (Qt Maintenance Tool) |
| Cross-compiler | crosstool-ng `aarch64-rpi3-linux-gnu` GCC 13.2.0 |
| GPIO library | libgpiod v2 |

---

## Part 1 — Raspberry Pi Setup

SSH into the Pi and install all required development packages:

```bash
sudo apt update
sudo apt install \
  libgpiod-dev libc6-dev libstdc++-12-dev \
  qt6-base-dev qt6-declarative-dev \
  libqt6quick6 \
  qml6-module-qtquick \
  qml6-module-qtquick-controls
```

---

## Part 2 — Host Machine Setup

### Step 1 — Install Qt 6.8.3 Host Tools

Open the Qt Maintenance Tool:

Navigate to **Customize → Qt → Qt 6.8.3** and check **Desktop gcc 64-bit**, then install.

> ⚠️ The host Qt version must match the Pi's Qt minor version. Pi has 6.8.2, so host 6.8.3 works fine (same minor version = compatible ABI and `qmlcachegen` output).

---

### Step 2 — Create the Sysroot

Pull the required headers and libraries from the Pi:

```bash
mkdir -p ~/rpi-sysroot/usr

rsync -avz pi@192.168.50.2:/usr/include ~/rpi-sysroot/usr/
rsync -avz pi@192.168.50.2:/usr/lib     ~/rpi-sysroot/usr/
rsync -avz pi@192.168.50.2:/lib         ~/rpi-sysroot/
rsync -avz pi@192.168.50.2:/usr/share/qt6 ~/rpi-sysroot/usr/share/ 2>/dev/null || true
```

---

### Step 3 — Fix the `/lib` Symlink

On Raspberry Pi OS Bookworm, `/lib` is a symlink to `usr/lib`. `rsync` copies it as a real directory, which breaks the linker. Fix it manually:

```bash
cp -a ~/rpi-sysroot/lib/aarch64-linux-gnu/. ~/rpi-sysroot/usr/lib/aarch64-linux-gnu/
cp -a ~/rpi-sysroot/lib/gcc               ~/rpi-sysroot/usr/lib/
rm -rf ~/rpi-sysroot/lib
ln -sf usr/lib ~/rpi-sysroot/lib
```

---

### Step 4 — Fix `libstdc++` Version Mismatch

The Pi's Qt6 was compiled against `libstdc++.so.6.0.33`, but the crosstool-ng toolchain ships with `6.0.32`. The linker fails with:

```
undefined reference to `__cxa_call_terminate@CXXABI_1.3.15'
```

Fix by replacing the CT sysroot's `libstdc++` with the Pi's version:

```bash
# Pull Pi's libstdc++ into the RPi sysroot
rsync -avz pi@192.168.50.2:/usr/lib/aarch64-linux-gnu/libstdc++* \
  ~/rpi-sysroot/usr/lib/aarch64-linux-gnu/

# Copy into the CT sysroot/lib (where the linker searches first)
sudo cp ~/rpi-sysroot/usr/lib/aarch64-linux-gnu/libstdc++.so.6.0.33 \
   ~/x-tools/aarch64-rpi3-linux-gnu/aarch64-rpi3-linux-gnu/sysroot/lib/

sudo ln -sf libstdc++.so.6.0.33 \
   ~/x-tools/aarch64-rpi3-linux-gnu/aarch64-rpi3-linux-gnu/sysroot/lib/libstdc++.so.6

sudo ln -sf libstdc++.so.6.0.33 \
   ~/x-tools/aarch64-rpi3-linux-gnu/aarch64-rpi3-linux-gnu/sysroot/lib/libstdc++.so
```

---

### Step 5 — Create the CMake Toolchain File

```bash
cat > ~/rpi-toolchain.cmake << 'EOF'
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(CT_SYSROOT  "$ENV{HOME}/x-tools/aarch64-rpi3-linux-gnu/aarch64-rpi3-linux-gnu/sysroot")
set(RPI_SYSROOT "$ENV{HOME}/rpi-sysroot")

# Compiler uses the CT sysroot so pthread.h matches the CT's libstdc++ internal headers
set(CMAKE_SYSROOT ${CT_SYSROOT})

set(CMAKE_C_COMPILER   $ENV{HOME}/x-tools/aarch64-rpi3-linux-gnu/bin/aarch64-rpi3-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER $ENV{HOME}/x-tools/aarch64-rpi3-linux-gnu/bin/aarch64-rpi3-linux-gnu-g++)

# -B tells the linker where to find crt1.o / crti.o (from the Pi's libc6-dev)
set(CMAKE_C_FLAGS_INIT   "-B${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu")
set(CMAKE_CXX_FLAGS_INIT "-B${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu")

# Linker uses the RPi sysroot to resolve .so absolute paths from linker scripts
set(CMAKE_EXE_LINKER_FLAGS_INIT
    "-Wl,--sysroot=${RPI_SYSROOT} \
     -Wl,-rpath-link,${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu \
     -L${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu")
set(CMAKE_SHARED_LINKER_FLAGS_INIT
    "-Wl,--sysroot=${RPI_SYSROOT} \
     -Wl,-rpath-link,${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu \
     -L${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu")

# CMake searches RPi sysroot first for packages/libs/includes
set(CMAKE_FIND_ROOT_PATH ${RPI_SYSROOT} ${CT_SYSROOT})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Host Qt tools (moc, rcc, qmlcachegen) — must match Pi's Qt minor version
set(QT_HOST_PATH "$ENV{HOME}/Qt/6.8.3/gcc_64")
set(QT_HOST_PATH_CMAKE_DIR "$ENV{HOME}/Qt/6.8.3/gcc_64/lib/cmake")

set(ENV{PKG_CONFIG_SYSROOT_DIR} ${RPI_SYSROOT})
set(ENV{PKG_CONFIG_PATH} "${RPI_SYSROOT}/usr/lib/aarch64-linux-gnu/pkgconfig")
EOF
```

---

### Step 6 — Configure & Build

```bash
cd /path/to/Task05_RPiControlLED

cmake -S . -B build-rpi \
  -G Ninja \
  -DCMAKE_TOOLCHAIN_FILE=~/rpi-toolchain.cmake \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build-rpi -- -j$(nproc)
```

Verify the output binary is an aarch64 ELF:

```bash
file build-rpi/appTask05_RPiControlLED
# Expected: ELF 64-bit LSB executable, ARM aarch64 ...
```

---

### Step 7 — Deploy to the Pi

```bash
scp build-rpi/appTask05_RPiControlLED pi@192.168.50.2:~/Documents/ITI_9Months/Qt/Task05_RPiControlLED/
```

---

## Part 3 — Running on the Pi

Connect via VNC Viewer, then run:

```bash
cd ~/Documents/ITI_9Months/Qt/Task05_RPiControlLED/
export DISPLAY=:0
./appTask05_RPiControlLED
```

> **GPIO permission:** If the app can't access GPIO17, add your user to the `gpio` group:
> ```bash
> sudo usermod -aG gpio pi
> # Log out and back in
> ```

---

## Hardware: LED Wiring

The app controls **GPIO17 (physical pin 11)** via `libgpiod` v2.

```
RPi Pin 11 (GPIO17) ─ 220Ω ─ LED (+)
RPi Pin 9  (GND)    ──────── LED (-)
```

---

## Troubleshooting Summary

| Error | Cause | Fix |
|---|---|---|
| `cannot find crt1.o` | `libc6-dev` not installed on Pi | `sudo apt install libc6-dev` on Pi, re-rsync `/usr/lib` |
| `/lib` not found after rsync | rsync copies symlink target as real dir | Merge `/lib` into `/usr/lib`, recreate as symlink |
| `__gthread_cond_t` type error | RPi `pthread.h` pulled in via `-isystem`, mismatches CT's libstdc++ | Use CT sysroot for `CMAKE_SYSROOT`; let linker use RPi sysroot via `-Wl,--sysroot` |
| QML AOT API mismatch (`setLocals`, `mark` missing) | Host `qmlcachegen` 6.10.x generating code incompatible with Pi's Qt 6.8.x headers | Install Qt **6.8.x** host tools via Maintenance Tool |
| `cannot find libm.so.6` at link | Linker resolving absolute paths against wrong sysroot | Add `-Wl,--sysroot=${RPI_SYSROOT}` to linker flags |
| `CXXABI_1.3.15` undefined reference | CT toolchain has `libstdc++ 6.0.32`, Pi's Qt needs `6.0.33` | Copy Pi's `libstdc++.so.6.0.33` into CT `sysroot/lib/` and update symlinks |

---

## Key Design Decisions in the Toolchain File

```
Compiler --sysroot  →  CT sysroot   (pthread.h matches GCC 13 libstdc++ internals)
Linker   --sysroot  →  RPi sysroot  (resolves libm, libc, Qt .so absolute paths)
-B flag             →  RPi sysroot  (crt1.o, crti.o from Pi's libc6-dev)
QT_HOST_PATH        →  Host Qt 6.8.3 (qmlcachegen must match target Qt version)
```
