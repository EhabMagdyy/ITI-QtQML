# Media Player (Radio Streaming / Audio & Video Player via multiple sources)

## 1. Qt MediaPlayer

### Properties

| Property | Type | Description |
|---|---|---|
| `source` | `url` | File path or stream URL |
| `playbackState` | `enum` | `PlayingState` / `PausedState` / `StoppedState` |
| `mediaStatus` | `enum` | `NoMedia` / `LoadingMedia` / `BufferingMedia` / `BufferedMedia` / `InvalidMedia` / `StalledMedia` / `EndOfMedia` |
| `position` | `int` | Current position in ms |
| `duration` | `int` | Total duration in ms (0 for live streams) |
| `bufferProgress` | `real` | 0.0 → 1.0 buffer fill level |
| `hasAudio` | `bool` | Source has an audio track |
| `hasVideo` | `bool` | Source has a video track |
| `loops` | `int` | `-1` = infinite, `1` = once |
| `playbackRate` | `real` | `1.0` = normal speed, `2.0` = 2x speed |
| `error` | `enum` | Last error type |
| `errorString` | `string` | Human readable error description |

---

### Methods

| Method | Description |
|---|---|
| `play()` | Start or resume playback |
| `pause()` | Pause playback |
| `stop()` | Stop and reset position to 0 |
| `seek(position)` | Seek to position in ms |

---

### Signals

| Signal | When it fires |
|---|---|
| `playbackStateChanged` | Play / pause / stop |
| `mediaStatusChanged` | Buffer / load / stall state changes |
| `positionChanged` | Every position tick while playing |
| `durationChanged` | Duration becomes known after load |
| `bufferProgressChanged` | Buffer level updates |
| `errorOccurred(error, errorString)` | Any playback error |
| `metaDataChanged` | Stream metadata arrives |
| `hasAudioChanged` | Audio track detected |
| `hasVideoChanged` | Video track detected |
| `loopsChanged` | Loop setting changed |
| `playbackRateChanged` | Speed changed |

---

### playbackState Values

| Value | Meaning |
|---|---|
| `MediaPlayer.PlayingState` | Currently playing |
| `MediaPlayer.PausedState` | Paused |
| `MediaPlayer.StoppedState` | Stopped |

---

### mediaStatus Values

| Value | Meaning |
|---|---|
| `MediaPlayer.NoMedia` | No source set |
| `MediaPlayer.LoadingMedia` | Loading / connecting |
| `MediaPlayer.LoadedMedia` | Loaded and ready |
| `MediaPlayer.BufferingMedia` | Filling buffer |
| `MediaPlayer.BufferedMedia` | Buffer full, playing normally |
| `MediaPlayer.StalledMedia` | Network too slow, rebuffering |
| `MediaPlayer.EndOfMedia` | Reached end of file |
| `MediaPlayer.InvalidMedia` | Bad URL or unsupported format |

---

### error Values

| Value | Meaning |
|---|---|
| `MediaPlayer.NoError` | No error |
| `MediaPlayer.ResourceError` | Invalid URL or not found |
| `MediaPlayer.FormatError` | Unsupported format |
| `MediaPlayer.NetworkError` | Cannot reach server |
| `MediaPlayer.AccessDeniedError` | Server rejected request |

---

### Most Useful Combo in Practice

```qml
MediaPlayer {
    id: player

    onPlaybackStateChanged: // update UI play/pause button
    onMediaStatusChanged:   // show buffering / error states
    onPositionChanged:      // update progress bar
    onDurationChanged:      // set progress bar max
    onErrorOccurred:        // show error message
    onMetaDataChanged:      // update song title / album art
}
```

---

### AudioOutput Properties

| Property | Type | Description |
|---|---|---|
| `volume` | `real` | 0.0 → 1.0 |
| `muted` | `bool` | Mute/unmute |

```qml
MediaPlayer {
    id: audioPlayer
    source: "https://example.com/audio.mp3"
    audioOutput: AudioOutput {
        id: audioOut
        volume: 0.8
        muted: false
    }
}
```

---

### VideoOutput Properties


| Property | Type | Values / Default | Description |
|---|---|---|---|
| `fillMode` | `enum` | `PreserveAspectFit` | How video fits the item |
| `orientation` | `int` | `0` | Rotation in degrees (0/90/180/270) |
| `mirrored` | `bool` | `false` | Flip horizontally |
| `sourceRect` | `rect` | `Qt.rect(0,0,0,0)` | Crop region of source (0=full) |
| `contentRect` | `rect` | read-only | Actual rendered video area |

#### fillMode Values

| Value | Behavior |
|---|---|
| `VideoOutput.PreserveAspectFit` | Letterboxed — full video visible |
| `VideoOutput.PreserveAspectCrop` | Fills area, crops edges |
| `VideoOutput.Stretch` | Stretches to fill, ignores aspect ratio |

```qml
VideoOutput {
    id: videoOut
    anchors.fill: parent
    fillMode: VideoOutput.PreserveAspectFit
}
```


---
 
## 2. Bluetooth Manager
 
Handles Bluetooth A2DP audio streaming and AVRCP media control via BlueZ D-Bus.
 
### Architecture
 
```
Phone (music app)
    ↓ Bluetooth A2DP profile
Linux BlueZ Stack (D-Bus)
    ↓
PulseAudio / PipeWire (audio routed automatically)
    ↓
BluetoothManager (polls BlueZ every 0.5s)
    ↓
QML UI (reacts to property changes)
```
 
### Bluetooth Profiles Used
 
| Profile | UUID | Purpose |
|---|---|---|
| A2DP Source | `0000110a` | Streams audio from phone to Linux |
| AVRCP Target | `0000110c` | Receives media commands |
| AVRCP Controller | `0000110e` | Sends play/pause/next to phone |
 
---
 
### QML-Exposed Properties
 
| Property | Type | Description |
|---|---|---|
| `connected` | `bool` | Whether a BT device is currently connected |
| `deviceName` | `string` | Name of connected device (e.g. "Ehab") |
| `deviceAddress` | `string` | MAC address (e.g. "F0:65:AE:CF:34:F9") |
| `trackTitle` | `string` | Current song title via AVRCP |
| `trackArtist` | `string` | Current artist via AVRCP |
| `trackAlbum` | `string` | Current album via AVRCP |
| `playerStatus` | `string` | `"playing"` / `"paused"` / `"stopped"` |
| `trackImageUrl` | `string` | Album art URL (fetched from iTunes API) |
 
---
 
### QML-Invokable Methods (AVRCP Controls)
 
| Method | Description |
|---|---|
| `play()` | Send play command to phone |
| `pause()` | Send pause command to phone |
| `stop()` | Send stop command to phone |
| `next()` | Skip to next track on phone |
| `previous()` | Go to previous track on phone |
| `setVolume(int percent)` | Set system volume via amixer (0–100) |
 
---
 
### Signals
 
| Signal | When it fires |
|---|---|
| `connectedChanged` | Device connects or disconnects |
| `deviceNameChanged` | Device name becomes available |
| `deviceAddressChanged` | Device address becomes available |
| `trackInfoChanged` | Track title / artist / album / image changes |
| `playerStatusChanged` | Playback status changes (playing/paused/stopped) |
| `errorOccurred(message)` | Any D-Bus or AVRCP error |
 
---
 
### How It Works
 
- Polls BlueZ `GetManagedObjects` every **2 seconds** via D-Bus
- Uses raw `QDBusArgument` parsing to handle BlueZ's nested `a{oa{sa{sv}}}` type
- Emits signals **only when values actually change** to avoid redundant QML updates
- `MediaPlayer1` interface only appears in BlueZ **after the phone starts playing audio**
- Audio routing happens automatically via PulseAudio/PipeWire — no extra code needed
 
