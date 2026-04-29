import AppKit

/// Installs a CGEventTap at the HID level that intercepts keyDown events and
/// replaces each printable character with its encoded counterpart.
///
/// Replacement events are posted at `.cgAnnotatedSessionEventTap`, which is
/// *after* our tap at `.cghidEventTap`, so they are never re-intercepted.
final class EventTapController {

    var currentMode: TranslationMode = .off

    // Exposed as `fileprivate` so the C-style tap callback (same file) can
    // re-enable the tap if it gets disabled by a timeout.
    fileprivate var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    init() { setupTap() }
    deinit { teardown() }

    // MARK: - Setup / teardown

    private func setupTap() {
        let mask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        guard let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: mask,
            callback: tapCallback,
            userInfo: selfPtr
        ) else {
            // This happens when Accessibility permission hasn't been granted yet.
            // AppDelegate will have already prompted the user, so just log here.
            print("[KeyBender] CGEvent.tapCreate failed – Accessibility permission required.")
            return
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)
    }

    private func teardown() {
        if let tap = eventTap { CGEvent.tapEnable(tap: tap, enable: false) }
        if let src = runLoopSource { CFRunLoopRemoveSource(CFRunLoopGetMain(), src, .commonModes) }
    }

    // MARK: - Event handling

    /// Called from the tap callback. Returns the original event to pass it
    /// through unchanged, or `nil` to swallow it (because we posted a replacement).
    func handle(event: CGEvent) -> CGEvent? {
        guard currentMode != .off else { return event }

        var length = 0
        var chars = [UniChar](repeating: 0, count: 4)
        event.keyboardGetUnicodeString(maxStringLength: 4, actualStringLength: &length, unicodeString: &chars)
        guard length > 0 else { return event }

        let str = String(utf16CodeUnits: chars, count: length)
        guard let char = str.first, isPrintable(char) else { return event }
        guard let encoded = currentMode.encode(char) else { return event }

        postText(encoded)
        return nil // swallow original keystroke
    }

    // MARK: - Helpers

    private func isPrintable(_ char: Character) -> Bool {
        guard let v = char.unicodeScalars.first?.value else { return false }
        // Printable ASCII (0x20–0x7E) plus extended Unicode (above C1 controls)
        return (v >= 0x20 && v <= 0x7E) || v > 0x9F
    }

    private func postText(_ text: String) {
        let src = CGEventSource(stateID: .combinedSessionState)

        for scalar in text.unicodeScalars {
            var c = UniChar(scalar.value & 0xFFFF)

            let down = CGEvent(keyboardEventSource: src, virtualKey: 0, keyDown: true)
            down?.keyboardSetUnicodeString(stringLength: 1, unicodeString: &c)
            down?.post(tap: .cgAnnotatedSessionEventTap)

            let up = CGEvent(keyboardEventSource: src, virtualKey: 0, keyDown: false)
            up?.keyboardSetUnicodeString(stringLength: 1, unicodeString: &c)
            up?.post(tap: .cgAnnotatedSessionEventTap)
        }
    }
}

// MARK: - C-style tap callback (must be a free function for CGEvent API)

private let tapCallback: CGEventTapCallBack = { _, type, event, userInfo -> Unmanaged<CGEvent>? in
    guard let userInfo else { return Unmanaged.passRetained(event) }
    let controller = Unmanaged<EventTapController>.fromOpaque(userInfo).takeUnretainedValue()

    // Re-enable the tap if macOS disabled it (e.g. event delivery was too slow)
    if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
        if let tap = controller.eventTap { CGEvent.tapEnable(tap: tap, enable: true) }
        return Unmanaged.passRetained(event)
    }

    guard type == .keyDown else { return Unmanaged.passRetained(event) }

    if let passThrough = controller.handle(event: event) {
        return Unmanaged.passRetained(passThrough)
    }
    return nil // swallowed – replacement was posted
}
