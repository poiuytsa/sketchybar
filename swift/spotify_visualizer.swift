import Foundation

// MARK: - Configuration

private enum Config {
    static let frameRate: Double = 30.0                  // how often we push updates to sketchybar
    static let frameInterval: TimeInterval = 1.0 / frameRate
    static let spotifyPollInterval: TimeInterval = 0.5    // how often we ask Spotify for its state
    static let animationSpeed: Double = 2.4               // radians/sec
    static let sketchybarPath = "/opt/homebrew/bin/sketchybar"
    static let barCount = 9
}

private let barGlyphs = ["▁", "▂", "▃", "▄", "▅", "▆", "▇"]

// Spotify-inspired gradient endpoints (deep forest green -> signature bright green)
private let colorDark: (r: Double, g: Double, b: Double) = (15, 61, 38)     // 0x0F3D26
private let colorBright: (r: Double, g: Double, b: Double) = (40, 235, 122) // near 0x1ED760

// MARK: - Small locking helper

private extension NSLock {
    func synchronized<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }
}

// MARK: - Spotify polling (runs on its own background thread)

/// Polls Spotify's playback state off the render loop so a slow AppleScript
/// call never stalls the animation. Exposes the latest result thread-safely.
final class SpotifyMonitor {
    private let lock = NSLock()
    private var _isPlaying = false

    var isPlaying: Bool { lock.synchronized { _isPlaying } }

    init(pollInterval: TimeInterval) {
        Thread.detachNewThread { [weak self] in
            while let self {
                let playing = Self.queryPlaybackState()
                self.lock.synchronized { self._isPlaying = playing }
                Thread.sleep(forTimeInterval: pollInterval)
            }
        }
    }

    private static func queryPlaybackState() -> Bool {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
        task.arguments = ["-e", "tell application \"Spotify\" to get player state"]

        let stdout = Pipe()
        task.standardOutput = stdout
        task.standardError = Pipe() // swallow "Spotify isn't running" noise

        do {
            try task.run()
        } catch {
            return false
        }
        task.waitUntilExit()

        let data = stdout.fileHandleForReading.readDataToEndOfFile()
        let state = String(data: data, encoding: .utf8)?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        return state == "playing"
    }
}

// MARK: - Bar

/// A single rendered bar: which glyph to show and what color to show it in.
/// Independent items each get one of these per frame.
struct Bar: Equatable {
    let glyph: String
    let color: String
}

// MARK: - Visualizer

/// Generates the bar array from a continuously-advancing phase, driven by
/// real elapsed time rather than a fixed per-frame increment, so it stays
/// smooth even if a frame takes longer than expected.
final class BarVisualizer {
    private(set) var phase: Double = 0

    private static let idleBars: [Bar] = {
        let idleColor = colorHex(brightness: 0.0)
        return Array(repeating: Bar(glyph: "▁", color: idleColor), count: Config.barCount)
    }()

    func advance(by dt: TimeInterval) {
        phase += dt * Config.animationSpeed
    }

    func idle() -> [Bar] {
        Self.idleBars
    }

    func bars() -> [Bar] {
        let amplitude = 1.6 + 0.55 * sin(phase * 0.22)
        let breathing = (sin(phase * 0.22) + 1) / 2   // 0...1, same wave that drives amplitude

        var output: [Bar] = []
        output.reserveCapacity(Config.barCount)

        for i in 0..<Config.barCount {
            let x = Double(i) - 4.0
            let offset = Double(i) * 0.17

            let wave1 = sin(phase + x * 0.55 + offset)
            let wave2 = 0.55 * sin(phase * 2.8 - x * 1.15 + offset * 2.0)
            let wave3 = 0.28 * sin(phase * 6.0 + Double(i))

            let rawHeight = 3.0 + amplitude * wave1 + wave2 + wave3
            let height = max(0.0, min(6.0, rawHeight))

            let heightT = height / 6.0
            let centerT = 1.0 - Double(abs(i - 4)) / 4.0   // 1 at center, 0 at edges
            let brightness = min(1.0, max(0.0,
                0.35 * heightT +
                0.35 * centerT +
                0.30 * breathing
            ))

            output.append(Bar(
                glyph: barGlyphs[Int(height.rounded())],
                color: colorHex(brightness: brightness)
            ))
        }

        return output
    }
}

/// Lerps between the dark and bright gradient endpoints and formats as an
/// ARGB hex string sketchybar understands.
private func colorHex(brightness: Double) -> String {
    let t = min(1.0, max(0.0, brightness))
    let r = Int(colorDark.r + (colorBright.r - colorDark.r) * t)
    let g = Int(colorDark.g + (colorBright.g - colorDark.g) * t)
    let b = Int(colorDark.b + (colorBright.b - colorDark.b) * t)
    return String(format: "0xff%02X%02X%02X", r, g, b)
}

// MARK: - SketchyBar

/// Pushes all 9 bars to sketchybar in a single batched process call, and
/// skips the spawn entirely if nothing changed since the last frame.
enum SketchyBar {
    private static var lastBars: [Bar]?

    static func update(bars: [Bar]) {
        guard bars != lastBars else { return }
        lastBars = bars

        var args: [String] = []
        for (i, bar) in bars.enumerated() {
            args += [
                "--set", "spotify.vis\(i + 1)",
                "label=\(bar.glyph)",
                "label.color=\(bar.color)"
            ]
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: Config.sketchybarPath)
        process.arguments = args

        do {
            try process.run() // fire-and-forget: no waitUntilExit, keeps the loop unblocked
        } catch {
            FileHandle.standardError.write(Data("sketchybar update failed: \(error)\n".utf8))
        }
    }
}

// MARK: - Main loop

let monitor = SpotifyMonitor(pollInterval: Config.spotifyPollInterval)
let visualizer = BarVisualizer()
var lastFrameTime = Date()

while true {
    let now = Date()
    let dt = now.timeIntervalSince(lastFrameTime)
    lastFrameTime = now

    let bars: [Bar]
    if monitor.isPlaying {
        visualizer.advance(by: dt)
        bars = visualizer.bars()
    } else {
        bars = visualizer.idle()
    }

    SketchyBar.update(bars: bars)

    Thread.sleep(forTimeInterval: Config.frameInterval)
}
