# Media Player (Radio Streaming / Audio & Video Player via multiple sources)

## Qt MediaPlayer

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
