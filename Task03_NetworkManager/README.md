# 🌐 Network Manager

A **Qt6/QML desktop application** for managing Wi-Fi and Bluetooth connections on Linux, communicating with the OS via **D-Bus** — no file polling, no shell commands, just direct IPC with NetworkManager and BlueZ.

---

## 📸 Demo

> [https://github.com/user-attachments/assets/662210c1-5778-480c-a917-230aff0b5ce9](https://github.com/user-attachments/assets/af20b455-88e2-4f0f-bd7c-e46458a002f3)

---

## ✨ Features

### Wi-Fi
- 🔘 Toggle Wi-Fi on/off — synced with system state in real time
- 📡 Scan for available networks and display them in a scrollable popup
- 🔗 Connect to a known network (auto-detects saved profiles — no password re-entry)
- 🔐 Connect to a new network with SSID + password input
- 🔒 Connect to hidden networks via manual SSID + password entry (`hidden: true`)
- ✂️ Scan deduplication — multiple BSSIDs sharing the same SSID are shown as one entry
- 🚫 No duplicate saved profiles — checks existing profiles before `AddAndActivateConnection`
- 🔴 **Disconnect** from the current network directly from the scan popup
- 🟢 Button shows **Connected** (green) for the active network, **Connect** (red) for others
- 📶 Real-time connection status synced with system via `ActiveConnections` property changes

### Bluetooth
- 🔘 Toggle Bluetooth on/off — synced with adapter state in real time
- 🔍 Scan for nearby devices (8-second discovery window)
- 🔗 Connect to a discovered device
- 🔴 **Disconnect** from a connected device
- 📋 Inline scrollable device list with name and MAC address
- 🟢 4-state button: **Connect → Connecting.. → Disconnect → Disconnecting..**
- 🔄 Syncs with system — if a device connects/disconnects outside the app, the UI updates instantly

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
│   └── BluetoothManager.hpp / .cpp # Bluetooth D-Bus bridge (BlueZ + DeviceWatcher)
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

## ⚙️ Backend Code Workflow

### 🔵 Wi-Fi — `WifiManager`

#### Toggle Wi-Fi
```
QML Switch toggled
  └─► WifiManager::setWifiEnabled(bool)
        └─► org.freedesktop.DBus.Properties.Set("WirelessEnabled")
              └─► PropertiesChanged signal fires
                    └─► onPropertiesChanged() → emit wifiEnabledChanged()
                          └─► QML Connections updates Switch silently
```

#### Scan Networks
```
QML "Scan" button clicked
  └─► WifiManager::scanNetworks()
        ├─► NM.GetDevices() → find device with DeviceType == 2 (WiFi)
        ├─► Device.RequestScan()
        ├─► Device.GetAllAccessPoints()
        │     └─► read Ssid property per AP
        │           └─► QSet<QString> deduplication — skip duplicate SSIDs ✅
        └─► emit scanFinished(QStringList)
              └─► QML populates network popup ListView
```

#### Connect to Network (from scan popup)
```
User selects a network from popup
  └─► WifiManager::connectToSelectedNetwork(ssid)
        ├─► NM.Settings.ListConnections()
        │     └─► foreach connection: GetSettings() → match Ssid (as QByteArray) ✅
        │           ├─► [found]  NM.ActivateConnection() → watchActiveConnection()
        │           │             └─► PropertiesChanged on ActiveConnection path
        │           │                   ├─► State == 2 → emit connectSuccess()
        │           │                   └─► State == 4 → emit connectFailed()
        │           └─► [not found] emit passwordRequired(ssid)
        │                 └─► QML opens password popup

User enters password → clicks Connect
  └─► WifiManager::connectToNetwork(ssid, password)
        ├─► Check existing profiles first (avoids creating duplicate saved connections) ✅
        │     └─► [found] NM.ActivateConnection() → no new profile created
        ├─► [not found] Build NMConnectionSettings (a{sa{sv}}) map
        │     ├─► wirelessSettings["hidden"] = true  ← works for hidden + visible ✅
        │     └─► NM.AddAndActivateConnection()
        └─► watchActiveConnection(activeConnPath, ssid)
              └─► same state-watching flow as above
```

#### Disconnect from Network
```
User clicks "Disconnect" on connected network in popup
  └─► WifiManager::disconnectFromNetwork()
        ├─► NM.ActiveConnections property → find Type == "802-11-wireless"
        └─► NM.DeactivateConnection(activeConnPath)
              └─► ActiveConnections changes → onPropertiesChanged()
                    └─► updateConnectedSsid() → m_connectedSsid = ""
                          └─► emit connectedSsidChanged("") → QML shows toast
```

#### Connected SSID Tracking
```
App startup / ActiveConnections changes
  └─► WifiManager::updateConnectedSsid()
        ├─► NM.ActiveConnections → foreach active connection
        │     └─► Type == "802-11-wireless" → GetSettings() → read ssid bytes
        │           └─► m_connectedSsid = ssid → emit connectedSsidChanged()
        │                 └─► QML: WifiManager.connectedSsid binding
        │                       └─► scan popup button: green "Connected" / red "Connect"
        └─► [none found] m_connectedSsid = "" → emit connectedSsidChanged("")
```

---

### 🔵 Bluetooth — `BluetoothManager`

#### Startup Initialization
```
BluetoothManager constructor
  ├─► getAdapterPath() → try /org/bluez/hci0, hci1
  ├─► read Adapter1.Powered → m_bluetoothEnabled
  ├─► connect PropertiesChanged → onAdapterPropertiesChanged()
  └─► subscribeToAllKnownDevices()
        └─► GetManagedObjects() → foreach Device1
              ├─► subscribeToDevice(path, address)
              │     ├─► create DeviceWatcher(path, address)
              │     ├─► connect DeviceWatcher.connectionChanged → deviceConnectionChanged()
              │     ├─► QDBusConnection.connect PropertiesChanged → DeviceWatcher slot
              │     └─► read current Connected property → emit deviceConnectionChanged()
              └─► if already Connected → emit deviceConnectionChanged(address, true)
                    └─► QML adds address to connectedAddresses[]
```

#### Toggle Bluetooth
```
QML Switch toggled (guarded by updatingFromBackend flag)
  └─► BluetoothManager::setBluetoothEnabled(bool)
        ├─► guard: if m_bluetoothEnabled == enabled → return
        └─► org.freedesktop.DBus.Properties.Set(Adapter1, "Powered", value)
              └─► PropertiesChanged fires on adapter path
                    └─► onAdapterPropertiesChanged()
                          └─► emit bluetoothEnabledChanged()
                                └─► QML sets updatingFromBackend=true
                                    → updates Switch silently
                                    → updatingFromBackend=false
```

#### Scan Devices
```
QML "Scan" button clicked
  └─► BluetoothManager::scanDevices()
        ├─► Adapter1.StartDiscovery()
        ├─► emit scanStarted() → QML shows toast
        └─► QTimer::singleShot(8000ms)
              ├─► Adapter1.StopDiscovery()
              ├─► GetManagedObjects() → foreach Device1
              │     ├─► read Name, Address, Connected
              │     ├─► append "Name|Address|0or1" to list
              │     └─► subscribeToDevice(path, address)
              └─► emit scanFinished(QStringList)
                    └─► QML: deviceListModel.clear() + append each device
                              + populate connectedAddresses[] from "1" entries
```

#### Connect to Device
```
QML "Connect" button clicked
  └─► btPage.connectingAddress = address  ← delegate shows "Connecting.." immediately
  └─► BluetoothManager::connectDevice(address)
        ├─► findDevicePath(address) via GetManagedObjects()
        ├─► devIface.asyncCall("Connect")  ← non-blocking, UI stays responsive
        └─► QDBusPendingCallWatcher::finished
              ├─► [success] emit connectSuccess(name)
              │     └─► QML: connectedAddresses.slice() + push + reassign
              │               connectingAddress = ""
              │               delegate shows "Disconnect" (green)
              └─► [failure] emit connectFailed(reason)
                    └─► QML: connectingAddress = ""
                              delegate reverts to "Connect" (red)
```

#### Disconnect from Device
```
QML "Disconnect" button clicked
  └─► btPage.disconnectingAddress = address  ← delegate shows "Disconnecting.." immediately
  └─► BluetoothManager::disconnectDevice(address)
        ├─► findDevicePath(address) via GetManagedObjects()
        ├─► devIface.asyncCall("Disconnect")  ← non-blocking ✅
        └─► QDBusPendingCallWatcher::finished
              ├─► [success] emit disconnectSuccess(name)
              │     └─► QML: disconnectingAddress = ""
              │               toast "Disconnected from <name>"
              │               DeviceWatcher fires → connectedAddresses updated
              └─► [failure] emit disconnectFailed(reason)
                    └─► QML: disconnectingAddress = ""
                              shows error toast
```

#### Real-Time Connection Sync
```
Device connects/disconnects from outside the app (e.g. system settings)
  └─► BlueZ emits PropertiesChanged on device path
        └─► DeviceWatcher::onPropertiesChanged()
              └─► emit connectionChanged(address, connected)
                    └─► BluetoothManager::deviceConnectionChanged() forwarded to QML
                          └─► QML Connections.onDeviceConnectionChanged()
                                ├─► connectedAddresses.slice() → modify → reassign
                                │   (slice() forces new array reference = QML re-evaluates)
                                ├─► clears connectingAddress / disconnectingAddress if match
                                └─► all delegates re-check indexOf(address)
                                      → button color + text update instantly
```

---

## 📡 D-Bus Interfaces Used

### Wi-Fi — NetworkManager
| Interface | Usage |
|---|---|
| `org.freedesktop.NetworkManager` | Toggle `WirelessEnabled`, get devices, `ActivateConnection`, `DeactivateConnection` |
| `org.freedesktop.NetworkManager.Device.Wireless` | `RequestScan`, `GetAllAccessPoints` |
| `org.freedesktop.NetworkManager.AccessPoint` | Read `Ssid` property |
| `org.freedesktop.NetworkManager.Settings` | `ListConnections` for saved profiles |
| `org.freedesktop.NetworkManager.Settings.Connection` | `GetSettings` to match SSID |
| `org.freedesktop.NetworkManager.Connection.Active` | Read `Type`, `Connection` for active connection tracking |
| `org.freedesktop.DBus.Properties` | `PropertiesChanged` signal for real-time sync |

### Bluetooth — BlueZ
| Interface | Usage |
|---|---|
| `org.bluez.Adapter1` | Toggle `Powered`, `StartDiscovery`, `StopDiscovery` |
| `org.bluez.Device1` | `Connect`, `Disconnect`, read `Name` / `Address` / `Connected` |
| `org.freedesktop.DBus.ObjectManager` | `GetManagedObjects` for device enumeration |
| `org.freedesktop.DBus.Properties` | `PropertiesChanged` for real-time connection sync |

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
`connectToSelectedNetwork` checks for saved profiles and calls `ActivateConnection` — no password needed. `connectToNetwork` handles new networks only, calling `AddAndActivateConnection` with full credentials. This mirrors how a real network settings panel behaves.

### Why check for existing profiles inside `connectToNetwork`?
Calling `AddAndActivateConnection` unconditionally creates a new saved profile every time — resulting in duplicate entries in NetworkManager (e.g. "2001", "2001 1", "2001 2"). Checking `ListConnections` first and calling `ActivateConnection` if a match exists prevents this entirely.

### Why `hidden: true` in wireless settings?
Without this flag, NetworkManager treats the connection as a visible network and won't send directed probe requests for that SSID. Setting `hidden: true` forces directed probing, which is required for hidden networks. It has no negative effect on visible networks.

### Why compare SSID as `QByteArray` not `QString`?
NetworkManager stores SSIDs as raw bytes (`ay` D-Bus type), not strings. Calling `.toString()` on the variant may fail or produce garbage for non-ASCII SSIDs. Always use `.toByteArray()` then `QString::fromUtf8()`.

### Why `connectedSsid` as a `Q_PROPERTY`?
Exposing the connected SSID as a property lets QML delegates bind to it directly with `WifiManager.connectedSsid === model.name` — no extra signal handlers needed. The scan popup button color and text update automatically whenever the property changes.

### Why `NMConnectionSettings` (`QMap<QString, QVariantMap>`) instead of `QVariantMap`?
NetworkManager's `AddAndActivateConnection` expects D-Bus type `a{sa{sv}}`. A plain `QVariantMap` marshals to `a{sv}` which causes a type mismatch error. The custom typedef with `qDBusRegisterMetaType` ensures correct marshalling.

### Why async `Connect()` and `Disconnect()` for Bluetooth?
BlueZ's `Connect()` and `Disconnect()` are blocking — they wait until the operation completes or fails. Using `asyncCall` + `QDBusPendingCallWatcher` lets the call return immediately so QML can show **"Connecting..."** / **"Disconnecting..."** states while waiting, giving proper visual feedback.

### Why `DeviceWatcher` helper class instead of a shared slot?
`QDBusConnection::connect()` only accepts `const char*` slot strings — it does not support lambdas. A small `DeviceWatcher` object is created per device, capturing its path and address, with a proper `Q_SLOT` that forwards to `BluetoothManager::deviceConnectionChanged`.

### Why `.slice()` when modifying `connectedAddresses` in QML?
QML's property binding system compares object references. Calling `.push()` or `.splice()` directly on the array mutates it in place — the reference stays the same, so QML sees no change and skips re-evaluation. Using `.slice()` first creates a new array, forcing QML to detect the change and update all dependent delegates.

### Why `Component.onCompleted` for the Bluetooth Switch instead of a direct binding?
A direct `checked: BluetoothManager.bluetoothEnabled` binding fires `onCheckedChanged` during component initialization before `updatingFromBackend` is set, sending a spurious `setBluetoothEnabled(false)` D-Bus call. Using `Component.onCompleted` sets the initial state silently after the component is fully constructed.

### Why deduplicate scan results with `QSet`?
`GetAllAccessPoints` returns one entry per BSSID (physical radio), not per SSID. A mesh network or office with many access points can return 5–10 entries for the same network name. A `QSet<QString>` seen tracker ensures each SSID appears exactly once in the list.

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
| `connectedSsidChanged(QString)` | Active WiFi connection changed | Updates button states in popup; toast on disconnect |

### BluetoothManager
| Signal | When emitted | QML handler |
|---|---|---|
| `bluetoothEnabledChanged(bool)` | Adapter toggled | Updates switch silently via flag |
| `scanStarted()` | Discovery started | Shows toast |
| `scanFinished(QStringList)` | Discovery stopped | Populates device list |
| `scanFailed(QString)` | Discovery error | Shows error toast |
| `connectSuccess(QString)` | Connected | Updates connectedAddresses + toast |
| `connectFailed(QString)` | Connection failed | Clears connectingAddress + toast |
| `disconnectSuccess(QString)` | Disconnected | Clears disconnectingAddress + toast |
| `disconnectFailed(QString)` | Disconnect error | Clears disconnectingAddress + error toast |
| `deviceConnectionChanged(QString, bool)` | System state changed | Updates connectedAddresses in real time |

---
