# 🌐 Network Manager

A cross-platform **Qt6/QML desktop application** for managing Wi-Fi and Bluetooth connections on Linux, communicating with the OS via **D-Bus** — no file polling, no shell commands, just direct IPC with NetworkManager and BlueZ.

---

## 📸 Video

> 

---

## ✨ Features

### Wi-Fi
- 🔘 Toggle Wi-Fi on/off — synced with system state in real time
- 📡 Scan for available networks and display them in a scrollable popup
- 🔗 Connect to a known network (auto-detects saved profiles — no password re-entry)
- 🔐 Connect to a new network with SSID + password input
- 🔒 Connect to hidden networks manually
- 📶 Real-time connection status feedback via toast notifications

### Bluetooth
- 🔘 Toggle Bluetooth on/off — synced with adapter state in real time
- 🔍 Scan for nearby devices (8-second discovery window)
- 🤝 Pair with a discovered device
- 🔗 Connect to a paired device
- 📋 Inline scrollable device list with name and MAC address

### General
- 🎨 Custom dark-red gradient UI built entirely in QML
- 🔔 Toast notification system for success and error feedback
- 🧭 StackView-based navigation with animated page transitions
- ↩️ Back button on every page

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────┐
│              QML Frontend               │
│  Main.qml / WiFiPage.qml / BtPage.qml  │
│         (UI + Connections{})            │
└────────────────┬────────────────────────┘
                 │  Q_PROPERTY / signals / Q_INVOKABLE
┌────────────────▼────────────────────────┐
│           C++ Backend Layer             │
│   WifiManager.cpp / BluetoothManager    │
│      (QObject + QtDBus bridge)          │
└────────────────┬────────────────────────┘
                 │  D-Bus (System Bus)
┌────────────────▼────────────────────────┐
│            Linux System                 │
│  NetworkManager          BlueZ          │
│  org.freedesktop.NM      org.bluez      │
└─────────────────────────────────────────┘
```

---

## 🗂️ Project Structure

```
Task03_NetworkManager/
├── main.cpp                        # App entry point, context property registration
├── CMakeLists.txt                  # Build configuration
├── Main.qml                        # Root window + StackView + navigation cards
│
├── Backend/
│   ├── WifiManager.hpp / .cpp      # Wi-Fi D-Bus bridge (NetworkManager)
│   └── BluetoothManager.hpp / .cpp # Bluetooth D-Bus bridge (BlueZ)
│
├── Pages/
│   ├── WiFiPage.qml                # Wi-Fi settings page
│   └── BluetoothPage.qml          # Bluetooth settings page
│
├── Widgets/
│   └── NetworkCard.qml            # Reusable home screen card widget
│
└── images/
    ├── wifi.png
    └── bt.png
```

---

## 🔧 Tech Stack

| Layer | Technology |
|---|---|
| Language | C++17 + QML |
| Framework | Qt 6.8 |
| UI Engine | Qt Quick (QML) |
| IPC | D-Bus via `QtDBus` |
| Wi-Fi Backend | NetworkManager (`org.freedesktop.NetworkManager`) |
| Bluetooth Backend | BlueZ (`org.bluez`) |
| Build System | CMake 3.16+ |
| Target OS | Linux (Ubuntu 22.04 / Raspberry Pi OS) |

---

## 📡 D-Bus Interfaces Used

### Wi-Fi — NetworkManager
| Interface | Usage |
|---|---|
| `org.freedesktop.NetworkManager` | Toggle `WirelessEnabled`, get devices |
| `org.freedesktop.NetworkManager.Device.Wireless` | `RequestScan`, `GetAllAccessPoints` |
| `org.freedesktop.NetworkManager.AccessPoint` | Read `Ssid` property |
| `org.freedesktop.NetworkManager.Settings` | `ListConnections` for saved profiles |
| `org.freedesktop.DBus.Properties` | `PropertiesChanged` signal for real-time sync |

### Bluetooth — BlueZ
| Interface | Usage |
|---|---|
| `org.bluez.Adapter1` | Toggle `Powered`, `StartDiscovery`, `StopDiscovery` |
| `org.bluez.Device1` | `Pair`, `Connect`, read `Name` / `Address` / `Paired` |
| `org.freedesktop.DBus.ObjectManager` | `GetManagedObjects` for device enumeration |
| `org.freedesktop.DBus.Properties` | `PropertiesChanged` signal for real-time sync |

---

## 🚀 Build & Run

### Prerequisites

```bash
# Qt 6.8+
sudo apt install qt6-base-dev qt6-declarative-dev qt6-tools-dev

# D-Bus development headers
sudo apt install libqt6dbus6 qt6-base-dev

# System services (should already be running)
sudo systemctl enable --now NetworkManager
sudo systemctl enable --now bluetooth
```

### Build

```bash
git clone https://github.com/<your-username>/Task03_NetworkManager.git
cd Task03_NetworkManager
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build . -- -j$(nproc)
```

### Run

```bash
./appTask03_NetworkManager
```

---

## 🍓 Running on Raspberry Pi

### 1. Install dependencies on the Pi

```bash
sudo apt update
sudo apt install -y libqt6core6 libqt6gui6 libqt6qml6 libqt6quick6 \
                   libqt6dbus6 qt6-qpa-plugins \
                   bluetooth bluez network-manager
```

### 2. Copy and run

```bash
# From your dev machine
scp build/appTask03_NetworkManager pi@<PI_IP>:~/

# On the Pi
QT_QPA_PLATFORM=eglfs ./appTask03_NetworkManager
```

### 3. D-Bus permissions

```bash
sudo usermod -aG netdev,bluetooth pi
sudo systemctl restart NetworkManager bluetooth
```

---

## 🔑 Key Design Decisions

### Why D-Bus instead of reading files?
D-Bus gives **push notifications** via signals — the UI updates the moment the system state changes, with no polling. Reading files like `/proc/net/wireless` would require a timer and could miss rapid state transitions.

### Why separate `connectToSelectedNetwork` from `connectToNetwork`?
- `connectToSelectedNetwork` checks for existing saved profiles and calls `ActivateConnection` if found — no password needed
- `connectToNetwork` is for new networks only — calls `AddAndActivateConnection` with full credentials
- This mirrors how a real network settings panel behaves

### Why `NMConnectionSettings` (`QMap<QString, QVariantMap>`) instead of `QVariantMap`?
NetworkManager's `AddAndActivateConnection` expects D-Bus type `a{sa{sv}}`. A plain `QVariantMap` marshals to `a{sv}` which causes a type mismatch error. The custom typedef with `qDBusRegisterMetaType` ensures correct marshalling.

### Why async connection monitoring with `watchActiveConnection`?
`AddAndActivateConnection` returns immediately — it doesn't wait for the connection to succeed or fail. By subscribing to `PropertiesChanged` on the returned `ActiveConnection` object and watching for `State == 2` (Activated) or `State == 4` (Deactivated), the app reports accurate connection results.

---

## 📋 Signal/Slot Map

### WifiManager
| Signal | When emitted | QML handler |
|---|---|---|
| `wifiEnabledChanged(bool)` | System Wi-Fi toggled | Updates switch state |
| `scanStarted()` | Scan initiated | Shows toast |
| `scanFinished(QStringList)` | Scan complete | Opens network popup |
| `scanFailed(QString)` | Scan error | Shows error toast |
| `passwordRequired(QString)` | New network selected | Opens password popup |
| `connectSuccess(QString)` | Connection confirmed | Shows success toast |
| `connectFailed(QString)` | Connection failed | Shows error toast |

### BluetoothManager
| Signal | When emitted | QML handler |
|---|---|---|
| `bluetoothEnabledChanged(bool)` | Adapter toggled | Updates switch state |
| `scanStarted()` | Discovery started | Shows toast |
| `scanFinished(QStringList)` | Discovery stopped | Populates device list |
| `scanFailed(QString)` | Discovery error | Shows error toast |
| `pairSuccess(QString)` | Pairing complete | Shows success toast |
| `pairFailed(QString)` | Pairing failed | Shows error toast |
| `connectSuccess(QString)` | Connected | Shows success toast |
| `connectFailed(QString)` | Connection failed | Shows error toast |

---
